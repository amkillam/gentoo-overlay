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
opencl? ( !metal !rocm )
rocm? ( !metal !opencl )
metal? ( !rocm !opencl !vulkan !sycl )
"

S="${WORKDIR}/${P}"

BDEPEND="
acct-group/ollama
acct-user/ollama
dev-python/poetry
virtual/pkgconfig
dev-lang/go
sys-devel/gcc:12
cuda? ( >=dev-util/nvidia-cuda-toolkit-12.4.1 )
rocm? ( 
>=dev-libs/rocm-opencl-runtime-9999
>=sci-libs/hipBLAS-9999
>=dev-util/hip-9999
)
rocm? (
	virtual/opencl
	sci-libs/clblast
	)
opencl? (
	virtual/opencl
	sci-libs/clblast
	)
sycl? (
	virtual/opencl
	sci-libs/clblast
	)
vulkan? ( || ( dev-util/vulkan-loader  media-libs/mesa[vulkan] ) )
vulkan? ( dev-util/vulkan-headers )
kompute? ( || ( dev-util/vulkan-loader  media-libs/mesa[vulkan] ) )
kompute? ( dev-util/vulkan-headers )
"
RDEPEND="
cuda? ( >=dev-util/nvidia-cuda-toolkit-12.4.1 )
rocm? ( 
>=dev-util/nvidia-cuda-toolkit-12.4.1
>=dev-libs/rocm-opencl-runtime-9999
>=sci-libs/hipBLAS-9999
>=dev-util/hip-9999
)
rocm? ( 
	virtual/opencl 
	sci-libs/clblast
	) 
opencl? (
	virtual/opencl
	sci-libs/clblast
	)
sycl? (
	virtual/opencl
	sci-libs/clblast
	)
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
	eapply_user
}
src_compile() {

	export CFLAGS="${CFLAGS} -Wno-unused-command-line-argument -fcf-protection=none --rocm-device-lib-path=/usr/lib/amdgcn/bitcode"
	export CXXFLAGS="${CXXFLAGS} -Wno-unused-command-line-argument -fcf-protection=none --rocm-device-lib-path=/usr/lib/amdgcn/bitcode"
	export CPPFLAGS="${CPPFLAGS} -Wno-unused-command-line-argument -fcf-protection=none --rocm-device-lib-path=/usr/lib/amdgcn/bitcode"
	export CGO_CFLAGS="${CFLAGS}"
	export CGO_CXXFLAGS="${CXXFLAGS}"
	export CGO_CPPFLAGS="${CPPFLAGS}"
	export CGO_LDFLAGS="${LDFLAGS}"

	export CMAKE_DEFS="-DLLAMA_NATIVE=on -DCMAKE_BUILD_TYPE=Release -DCMAKE_CUDA_ARCHITECTURES=all"

	export NVCC_PREPEND_FLAGS='-ccbin /usr/bin/gcc-12'

	use ccache && export CMAKE_DEFS+=" -DLLAMA_CCACHE=on"
	use lto && export CMAKE_DEFS+=" -DLLAMA_LTO=on"
	use static-libs && export CMAKE_DEFS+=" -DLLAMA_STATIC=on"

	use metal &&
		export CMAKE_DEFS+=" -DLLAMA_METAL=on -DLLAMA_ACCELERATE=on -DGGML_USE_METAL=ON"

	if use opencl; then
		export CMAKE_DEFS="${CMAKE_DEFS} -DLLAMA_CLBLAST=on -DGGML_USE_CLBLAST=ON"
		export CGO_LDFLAGS="${CGO_LDFLAGS} -lOpenCL -lclblast"
		export CLBlast_DIR=/usr/lib64/cmake/CLBLast
	fi

	if use rocm; then
		export CMAKE_DEFS+=" -DLLAMA_HIPBLAS=on"
		export ROCM_PATH=/usr
		export HIP_PATH="$ROCM_PATH"
		export CLBlast_DIR=/usr/lib64/cmake/CLBLast
		HIP_LIBS="-lhipblas -lrocblas -lamdhip64 -lrocsolver -lamd_comgr -lhsa-runtime64 -lrocsparse -ldrm -ldrm_amdgpu"
		export EXTRA_LIBS="-L/usr/lib64 ${HIP_LIBS}"
		export CGO_LDFLAGS="${CGO_LDFLAGS} ${HIP_LIBS}"
		use uma && export CMAKE_DEFS="${CMAKE_DEFS} -DLLAMA_HIP_UMA=on"
	fi

	use cuda &&
		export CMAKE_DEFS="${CMAKE_DEFS} -DLLAMA_CUDA=on -DLLAMA_CUDA_FORCE_DMMV=on \
		-DLLAMA_CUDA_FORCE_MMQ=on -DLLAMA_CUDA_F16=ON -DGGML_USE_CUDA=ON"

	if use vulkan; then
		export CMAKE_DEFS="${CMAKE_DEFS} -DLLAMA_VULKAN=ON -DGGML_USE_VULKAN=ON \
			-DGGML_VULKAN_CHECK_RESULTS=ON -DLLAMA_CUDA=OFF"
		export GGML_USE_VULKAN=ON
		export GGML_VULKAN_CHECK_RESULTS=ON
		export EXTRA_LIBS="-lvulkan"
		export CGO_LDFLAGS="${CGO_LDFLAGS} -lvulkan"
	fi

	if use sycl; then
		export CMAKE_DEFS="${CMAKE_DEFS} -DLLAMA_SYCL=on -DGGML_USE_SYCL=ON"
		export CGO_CFLAGS="${CGO_CFLAGS} -fsycl"
		export CGO_CXXFLAGS="${CGO_CXXFLAGS} -fsycl"
		export CGO_CPPFLAGS="${CGO_CPPFLAGS} -fsycl"
	fi

	use mpi && export CMAKE_DEFS="${CMAKE_DEFS} -DLLAMA_MPI=on"
	use hbm && export CMAKE_DEFS="${CMAKE_DEFS} -DLLAMA_CPU_HBM=on"
	use kompute &&
		export CMAKE_DEFS="${CMAKE_DEFS} -DLLAMA_KOMPUTE=on -DKOMPUTE_OPT_USE_BUILT_IN_SPDLOG=OFF \
		-DKOMPUTE_OPT_USE_BUILT_IN_FMT=OFF -DKOMPUTE_OPT_USE_BUILT_IN_GOOGLE_TEST=OFF \
		-DKOMPUTE_OPT_USE_BUILT_IN_PYBIND11=OFF -DKOMPUTE_OPT_USE_BUILT_IN_VULKAN_HEADER=OFF \
		-DKOMPUTE_OPT_DISABLE_VULKAN_VERSION_CHECK=ON -DGGML_USE_CLBLAST=ON"

	use cpu_flags_x86_avx && export CMAKE_DEFS="$CMAKE_DEFS -DLLAMA_AVX=on"
	use cpu_flags_x86_avx2 && export CMAKE_DEFS="$CMAKE_DEFS -DLLAMA_AVX2=on"
	use cpu_flags_x86_avx512 && export CMAKE_DEFS="$CMAKE_DEFS -DLLAMA_AVX512=on"
	use cpu_flags_x86_avx512vbmi && export CMAKE_DEFS="$CMAKE_DEFS -DLLAMA_AVX512_VBMI=on"
	use cpu_flags_x86_avx512_vnni && export CMAKE_DEFS="$CMAKE_DEFS -DLLAMA_AVX512_VNNI=on"
	use cpu_flags_x86_fma3 && export CMAKE_DEFS="$CMAKE_DEFS -DLLAMA_FMA=on"
	use cpu_flags_x86_fma4 && export CMAKE_DEFS="$CMAKE_DEFS -DLLAMA_FMA=on"

	use test && export CMAKE_DEFS="$CMAKE_DEFS -DLLAMA_BUILD_TESTS=on -DKOMPUTE_OPT_BUILD_TESTS=ON"

	export OLLAMA_CUSTOM_CPU_DEFS="${CMAKE_DEFS}"
	export CMAKE_COMMON_DEFS="${CMAKE_DEFS}"
	export CGO_CFLAGS="$CGO_CFLAGS ${CMAKE_DEFS}"
	export CGO_CPPFLAGS="$CGO_CPPFLAGS ${CMAKE_DEFS}"
	export CGO_CXXFLAGS="$CGO_CXXFLAGS ${CMAKE_DEFS}"

	sed -i 's,/sys/module/amdgpu/version,/usr/share/ollama/gentoo_amdgpu_version,g' "${S}/discover/amd_linux.go"
	sed -i 's,/usr/share/ollama/lib/rocm,/lib64,g' "${S}/discover/amd_linux.go"

	if use rocm; then
		sed -i 's,/opt/rocm,/usr,g' "${S}/llama/Makefile"
		sed -i 's/-parallel-jobs=2//g' "${S}/llama/make/Makefile.rocm"
		sed -i 's,$(HIP_PATH)/lib",$(HIP_PATH)/lib64",g' "${S}/llama/make/Makefile.rocm"
		sed -i 's,$(HIP_PATH)/lib$,$(HIP_PATH)/lib64,g' "${S}/llama/make/Makefile.rocm"
		# sed -i 's/\/lib\/librocblas.so/\/librocblas.so/g' "${S}/llm/generate/gen_linux.sh"
		# sed -i 's/\$rocm_path\/llvm\/bin\/clang/\/usr\/lib\/llvm\/19\/bin\/clang/g' "${S}/llm/generate/gen_linux.sh"
		# sed -i 's/\${rocm_path}\/lib/\${rocm_path}/g' "${S}/llm/generate/gen_linux.sh"
		# sed -i 's/grep -e rocm -e amdgpu -e libtinfo/grep -i "roc\\|hsa-runtime\\|hip\\|drm\\|tinfo\\|comgr"/g' "${S}/llm/generate/gen_linux.sh"
	fi

	sed -i 's/g++/clang++-19/g' llama/make/common-defs.make
	sed -i 's/gcc/clang-19/g' llama/make/common-defs.make

	ego generate ./...
	for file in ${S}/llm/llama.cpp/Makefile ${S}/llm/llama.cpp/CMakeLists.txt; do
		sed -i 's/ -Werror=implicit-function-declaration//g' "${file}"
		sed -i 's/-Werror//g' "${file}"
	done

	if use kompute; then
		ar rcs "${S}/llm/build/linux/x86_64_static/libllama.a" \
			"${S}/llm/build/linux/x86_64_static/kompute/src/CMakeFiles/kompute.dir/"*.o
		ar rcs "${S}/llm/build/linux/x86_64_static/libllama.a" \
			"${S}/llm/build/linux/x86_64_static/kompute/src/logger/CMakeFiles/kp_logger.dir/Logger.cpp.o"
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
