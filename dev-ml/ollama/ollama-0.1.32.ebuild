EAPI=8

inherit go-module
DESCRIPTION="Get up and running with large language models locally."
HOMEPAGE="https:/github.com/ollama/ollama"

if [[ ${PV} == *9999 ]]; then
	inherit git-r3
	if [[ "$USE" == *vulkan* ]]; then
		export EGIT_OVERRIDE_BRANCH_GGERGANOV_LLAMA_CPP="0cc4m/vulkan-improvements"
		export EGIT_OVERRIDE_COMMIT_GGERGANOV_LLAMA_CPP="0cc4m/vulkan-improvements"
		export OLLAMA_SKIP_PATCHING=ON
	fi
	EGIT_REPO_URI="https://github.com/ollama/ollama.git"
else
	SRC_URI="https://github.com/ollama/ollama/archive/${PV}.tar.gz -> ${P}.tar.gz"
	SRC_URI+="${P}-vendor.tar.xz"
	SRC_URI+="${P}-deps.tar.xz"

	KEYWORDS="~amd64 ~x86"
fi

RESTRICT="mirror"
LICENSE="GPL-3"
SLOT="0"
IUSE="metal cuda rocm opencl vulkan sycl kompute mpi uma hbm ccache test lto static-libs cpu_flags_x86_avx cpu_flags_x86_avx2 cpu_flags_x86_avx512 cpu_flags_x86_avx512vbmi cpu_flags_x86_avx512_vnni cpu_flags_x86_fma3 cpu_flags_x86_fma4"

REQUIRED_USE="
sycl? ( !metal !opencl !rocm )
vulkan? ( !metal !opencl !rocm !sycl !kompute )
opencl? ( !metal rocm )
rocm? ( !metal opencl )
metal? ( !rocm !opencl !vulkan !sycl )
"

S="${WORKDIR}/${P}"

BDEPEND="
acct-group/ollama
acct-user/ollama
dev-python/poetry
virtual/pkgconfig
dev-lang/go
cuda? ( dev-util/nvidia-cuda-toolkit )
rocm? ( 
>=dev-libs/rocm-opencl-runtime-9999
>=sci-libs/hipBLAS-9999
)
rocm? ( || (
	virtual/opencl
	sci-libs/clblast
	sci-libs/clblas
	) )
opencl? ( || (
	virtual/opencl
	sci-libs/clblast
	sci-libs/clblas
	) )
sycl? ( || (
	virtual/opencl
	sci-libs/clblast
	sci-libs/clblas
	) )
vulkan? ( || ( dev-util/vulkan-loader  media-libs/mesa[vulkan] ) )
vulkan? ( dev-util/vulkan-headers )
kompute? ( || ( dev-util/vulkan-loader  media-libs/mesa[vulkan] ) )
kompute? ( dev-util/vulkan-headers )
"
RDEPEND="
cuda? ( dev-util/nvidia-cuda-toolkit )
rocm? ( 
>=dev-libs/rocm-opencl-runtime-9999
>=sci-libs/hipBLAS-9999
)
rocm? ( || ( 
	virtual/opencl 
	sci-libs/clblast
	sci-libs/clblas
	) 
)
opencl? ( || (
	virtual/opencl
	sci-libs/clblast
	sci-libs/clblas
	) )
sycl? ( || (
	virtual/opencl
	sci-libs/clblast
	sci-libs/clblas
	) )
vulkan? ( || ( dev-util/vulkan-loader  media-libs/mesa[vulkan] ) )
vulkan? ( dev-util/vulkan-headers )
kompute? ( || ( dev-util/vulkan-loader  media-libs/mesa[vulkan] ) )
kompute? ( dev-util/vulkan-headers )
dev-python/poetry
acct-user/ollama
acct-group/ollama
"

src_unpack() {
	[[ -n "${EGIT_REPO_URI}" ]] && git-r3_src_unpack
	go-module_src_unpack
	[[ -n "${EGIT_REPO_URI}" ]] && go-module_live_vendor
	sed -i 's/ -Werror//g' "${S}/llm/llama.cpp/kompute/CMakeLists.txt"
}

src_prepare() {
	use vulkan && eapply "${FILESDIR}/${P}-vulkan-support.patch"
	eaply "${FILESDIR}/${P}-buildgen.patch"
	eapply_user
}
src_compile() {

	export CGO_CFLAGS="${CFLAGS} -Wno-unused-command-line-argument --rocm-device-lib-path=/usr/lib/amdgcn/bitcode"
	export CGO_CXXFLAGS="${CXXFLAGS} -Wno-unuse-command-line-argument --rocm-device-lib-path=/usr/lib/amdgcn/bitcode"
	export CGO_CPPFLAGS="${CPPFLAGS} -Wno-unused-command-line-argument --rocm-device-lib-path=/usr/lib/amdgcn/bitcode"
	export CGO_LDFLAGS="${LDFLAGS}"

	export CMAKE_DEFS="-DLLAMA_FAST=on -DLLAMA_NATIVE=on \
		-DLLAMA_F16C=off -DCMAKE_BUILD_TYPE=Release"

	use ccache && export CMAKE_DEFS+=" -DLLAMA_CCACHE=on"
	use lto && export CMAKE_DEFS+=" -DLLAMA_LTO=on"
	use static-libs && export CMAKE_DEFS+=" -DLLAMA_STATIC=on"

	use metal &&
		export CMAKE_DEFS+=" -DLLAMA_METAL=on -DLLAMA_ACCELERATE=on -DGGML_USE_METAL=ON"

	if use opencl; then
		export CMAKE_DEFS+=" -DLLAMA_CLBLAST=on -DGGML_USE_CLBLAST=ON"
		export CGO_LDFLAGS+=" -lOpenCL"
		if [ -f /lib64/libclblast.so ]; then
			export CGO_LDFLAGS+=" -lclblast"
		elif [ -f /lib64/libclBLAS.so ]; then
			export CGO_LDFLAGS+=" -lclBLAS"
		else
			einfo "opencl USE flag requested but neither clBLAS nor clblast libraries installed! Exiting..."
			exit 0
		fi
	fi

	if use rocm; then
		export CMAKE_DEFS+=" -DLLAMA_HIPBLAS=on"
		export CGO_LDFLAGS+=" -lhip"
		use uma && export CMAKE_DEFS+=" -DLLAMA_HIP_UMA=on"
	fi

	use cuda &&
		export CMAKE_DEFS+=" -DLLAMA_CUDA=on -DLLAMA_CUDA_FORCE_DMMV=on \
		-DLLAMA_CUDA_FORCE_MMQ=on -DLLAMA_CUDA_F16=off -DGGML_USE_CUDA=ON"

	if use vulkan; then
		export CMAKE_DEFS+=" -DLLAMA_VULKAN=ON -DGGML_USE_VULKAN=ON \
			-DGGML_VULKAN_CHECK_RESULTS=ON"
		export GGML_USE_VULKAN=ON
		export GGML_VULKAN_CHECK_RESULTS=ON
		export EXTRA_LIBS="-lvulkan"
		export CGO_LDFLAGS+=" -lvulkan"
	fi

	if use sycl; then
		export CMAKE_DEFS+=" -DLLAMA_SYCL=on -DGGML_USE_SYCL=ON"
		export CGO_CFLAGS+=" -fsycl"
		export CGO_CXXFLAGS+=" -fsycl"
		export CGO_CPPFLAGS+=" -fsycl"
	fi

	use mpi && export CMAKE_DEFS+=" -DLLAMA_MPI=on"
	use hbm && export CMAKE_DEFS+=" -DLLAMA_CPU_HBM=on"
	use kompute &&
		export CMAKE_DEFS+=" -DLLAMA_KOMPUTE=on -DKOMPUTE_OPT_USE_BUILT_IN_SPDLOG=OFF \
		-DKOMPUTE_OPT_USE_BUILT_IN_FMT=OFF -DKOMPUTE_OPT_USE_BUILT_IN_GOOGLE_TEST=OFF \
		-DKOMPUTE_OPT_USE_BUILT_IN_PYBIND11=OFF -DKOMPUTE_OPT_USE_BUILT_IN_VULKAN_HEADER=OFF \
		-DKOMPUTE_OPT_DISABLE_VULKAN_VERSION_CHECK=ON -DGGML_USE_CLBLAST=ON"

	use cpu_flags_x86_avx && export CMAKE_DEFS+=" -DLLAMA_AVX=on"
	use cpu_flags_x86_avx2 && export CMAKE_DEFS+=" -DLLAMA_AVX2=on"
	use cpu_flags_x86_avx512 && export CMAKE_DEFS+=" -DLLAMA_AVX512=on"
	use cpu_flags_x86_avx512vbmi && export CMAKE_DEFS+=" -DLLAMA_AVX512_VBMI=on"
	use cpu_flags_x86_avx512_vnni && export CMAKE_DEFS+=" -DLLAMA_AVX512_VNNI=on"
	use cpu_flags_x86_fma3 && export CMAKE_DEFS+=" -DLLAMA_FMA=on"
	use cpu_flags_x86_fma4 && export CMAKE_DEFS+=" -DLLAMA_FMA=on"

	use test && export CMAKE_DEFS+=" -DLLAMA_BUILD_TESTS=on -DKOMPUTE_OPT_BUILD_TESTS=ON"

	export OLLAMA_CUSTOM_CPU_DEFS="${CMAKE_DEFS}"
	export CMAKE_COMMON_DEFS="${CMAKE_DEFS}"
	export CGO_CFLAGS+=" ${CMAKE_DEFS}"
	export CGO_CPPFLAGS+=" ${CMAKE_DEFS}"
	export CGO_CXXFLAGS+=" ${CMAKE_DEFS}"

	sed -i 's/\/sys\/module\/amdgpu\/version/\/usr\/share\/ollama\/gentoo_amdgpu_version/g' "${S}/gpu/amd_linux.go"
	sed -i 's/\/usr\/share\/ollama\/lib\/rocm/\/lib64/g' "${S}/gpu/amd_linux.go"

	ego generate ./...
	for file in ${S}/llm/llama.cpp/Makefile ${S}/llm/llama.cpp/CMakeLists.txt; do
		sed -i 's/ -Werror=implicit-function-declaration//g' "${file}"
		sed -i 's/-Werror//g' "${file}"
	done

	if use kompute; then
		ar rcs ${S}/llm/build/linux/x86_64_static/libllama.a \
			${S}/llm/build/linux/x86_64_static/kompute/src/CMakeFiles/kompute.dir/*.o
		ar rcs ${S}/llm/build/linux/x86_64_static/libllama.a \
			${S}/llm/build/linux/x86_64_static/kompute/src/logger/CMakeFiles/kp_logger.dir/Logger.cpp.o
	fi

	ego build .
}

src_install() {
	if [ ! -d "/etc/systemd/system" ]; then
		dodir "/etc/systemd/system"
	fi
	insinto "/etc/systemd/system"
	newins "${FILESDIR}/ollama.service" "ollama.service"

	insinto /usr/share/ollama
	newins "${FILESDIR}/gentoo_amdgpu_version" "gentoo_amdgpu_version"

	exeinto /usr/bin
	doexe "${S}/ollama"

}

pkg_postinstall() {
	einfo "To start the service run: systemctl start ollama"
	einfo "To enable the service to start on boot run: systemctl enable ollama"
	einfo "For more information see: https:/github.com/ollama/ollama"
}
