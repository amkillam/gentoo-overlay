EAPI=8

inherit go-module
DESCRIPTION="Get up and running with large language models locally."
HOMEPAGE="https:/github.com/ollama/ollama"

if [[ ${PV} == *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/ollama/ollama"
else
	SRC_URI="https://github.com/ollama/ollama/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	SRC_URI+=" ${P}-vendor.tar.xz"
	SRC_URI+=" ${P}-deps.tar.xz"

	KEYWORDS="~amd64 ~x86"
fi

RESTRICT="mirror"
LICENSE="GPL-3"
SLOT="0"
IUSE="metal cuda rocm opencl vulkan sycl kompute mpi uma hbm ccache test lto static cpu_flags_x86_avx cpu_flags_x86_avx2 cpu_flags_x86_avx512 cpu_flags_x86_avx512vbmi cpu_flags_x86_avx512_vnni cpu_flags_x86_fma3 cpu_flags_x86_fma4"

S="${WORKDIR}/${P}"

BDEPEND="
dev-python/poetry
virtual/pkgconfig
dev-lang/go
cuda? ( dev-util/nvidia-cuda-toolkit )
rocm? (
dev-util/hip
sci-libs/hipCUB
sci-libs/hipFFT
sci-libs/hipRAND
sci-libs/hipSOLVER
sci-libs/hipSPARSE
sci-libs/hipBLAS
dev-libs/rocm-opencl-runtime
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
dev-util/hip
sci-libs/hipCUB
sci-libs/hipFFT
sci-libs/hipRAND
sci-libs/hipSOLVER
sci-libs/hipSPARSE
sci-libs/hipBLAS
dev-libs/rocm-opencl-runtime  
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

PATCHES=(
	"${FILESDIR}/${P}-buildgen.patch"
)

src_unpack() {
	[[ -n "${EGIT_REPO_URI}" ]] && git-r3_src_unpack
	go-module_src_unpack
	[[ -n "${EGIT_REPO_URI}" ]] && go-module_live_vendor
	sed -i 's/ -Werror//g' "${S}/llm/llama.cpp/kompute/CMakeLists.txt"
}

src_compile() {

	export MK_CFLAGS="${CFLAGS}"
	export MK_CXXFLAGS="${CXXFLAGS}"
	export MK_CPPFLAGS="${CPPFLAGS}"
	export MK_LDFLAGS="${LDFLAGS}"

	export CGO_CFLAGS="${MK_CFLAGS} -Wno-unused-command-line-argument"
	export CGO_CXXFLAGS="${MK_CXXFLAGS} -Wno-unuse-command-line-argument"
	export CGO_CPPFLAGS="${MK_CPPFLAGS} -Wno-unused-command-line-argument"
	export CGO_LDFLAGS="${MK_LDFLAGS}"

	#CGO does not work well with line breaks in env vars
	export CMAKE_DEFS="-DLLAMA_FAST=on -DBUILD_SHARED_LIBS=off -DLLAMA_NATIVE=on -DLLAMA_F16=off -DLLAMA_CURL=on -DCMAKE_BUILD_TYPE=Release -DLLAMA_SERVER_VERBOSE=off"

	use ccache && export CMAKE_DEFS+=" -DLLAMA_CCACHE=on"
	use lto && export CMAKE_DEFS+=" -DLLAMA_LTO=on"
	use static && export CMAKE_DEFS+=" -DLLAMA_STATIC=on"

	use metal && export CMAKE_DEFS+=" -DLLAMA_METAL=on -DLLAMA_ACCELERATE=on _DGGML_USE_METAL=ON"

	#	use opencl && export CMAKE_DEFS+=" -DLLAMA_CLBLAST=on -DGGML_USE_CLBLAST=ON"
	use rocm && export CMAKE_DEFS+=" -DLLAMA_HIPBLAS=on" &&
		use uma && export CMAKE_DEFS+=" -DLLAMA_HIP_UMA=on"

	use cuda && export CMAKE_DEFS+=" -DLLAMA_CUDA=on -DLLAMA_CUDA_FORCE_DMMV=on -DLLAMA_CUDA_FORCE_MMQ=on -DLLAMA_CUDA_F16=off -DGGML_USE_CUDA=ON"

	use vulkan && export CMAKE_DEFS+=" -DLLAMA_VULKAN=yes -DGGML_USE_VULKAN=ON"
	use mpi && export CMAKE_DEFS+=" -DLLAMA_MPI=on"
	use sycl && export CMAKE_DEFS+=" -DLLAMA_SYCL=on -DGGML_USE_SYCL=ON"
	use kompute && export CMAKE_DEFS+=" -DLLAMA_KOMPUTE=on -DKOMPUTE_OPT_USE_BUILT_IN_SPDLOG=OFF -DKOMPUTE_OPT_USE_BUILT_IN_FMT=OFF -DKOMPUTE_OPT_USE_BUILT_IN_GOOGLE_TEST=OFF -DKOMPUTE_OPT_USE_BUILT_IN_PYBIND11=OFF -DKOMPUTE_OPT_USE_BUILT_IN_VULKAN_HEADER=OFF -DKOMPUTE_OPT_DISABLE_VULKAN_VERSION_CHECK=ON -DGGML_USE_CLBLAST=ON"
	use hbm && export CMAKE_DEFS+=" -DLLAMA_CPU_HBM=on"

	use cpu_flags_x86_avx && export CMAKE_DEFS+=" -DLLAMA_AVX=on"
	use cpu_flags_x86_avx2 && export CMAKE_DEFS+=" -DLLAMA_AVX2=on"
	use cpu_flags_x86_avx512 && export CMAKE_DEFS+=" -DLLAMA_AVX512=on"
	use cpu_flags_x86_avx512vbmi && export CMAKE_DEFS+=" -DLLAMA_AVX512_VBMI=on"
	use cpu_flags_x86_avx512_vnni && export CMAKE_DEFS+=" -DLLAMA_AVX512_VNNI=on"
	use cpu_flags_x86_fma3 && export CMAKE_DEFS+=" -DLLAMA_FMA=on"
	use cpu_flags_x86_fma4 && export CMAKE_DEFS+=" -DLLAMA_FMA=on"

	use test && export CMAKE_DEFS+=" -DLLAMA_BUILD_TESTS=on -DKOMPUTE_OPT_BUILD_TESTS=ON"

	export OLLAMA_SKIP_CPU_GENERATE=yes
	export CMAKE_COMMON_DEFS="${CMAKE_DEFS}"
	export CGO_CFLAGS+=" ${CMAKE_DEFS}"
	export CGO_CPPFLAGS+=" ${CMAKE_DEFS}"
	export CGO_CXXFLAGS+=" ${CMAKE_DEFS}"

	ego generate ./...

	#sed -i 's/build\/linux\/\*\/\*\/bin\/\*/build\/linux\/*\/bin\/*/g' "${S}/llm/llm_linux.go"
	ego build .
}

src_install() {
	for dir in /home/*; do
		if [ ! -d "${dir}/etc/systemd/system" ]; then
			dodir "${dir}/etc/systemd/system"
		fi
		insinto "${dir}/etc/systemd/system"
		newins "${FILESDIR}/ollama.service" "ollama.service"
	done

	insinto /usr/lib64
	doins -r "${S}/llm/build/linux/x86_64_static/libllama.so"

	exeinto /usr/bin
	doexe "${S}/ollama"

}

pkg_postinstall() {
	einfo "To start the service run: systemctl start ollama"
	einfo "To enable the service to start on boot run: systemctl enable ollama"
	einfo "For more information see: https:/github.com/ollama/ollama"
}