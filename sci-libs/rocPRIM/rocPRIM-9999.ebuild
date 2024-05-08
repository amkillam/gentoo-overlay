# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ROCM_VERSION=${PV}
inherit cmake rocm

DESCRIPTION="HIP parallel primitives for developing performant GPU-accelerated code on ROCm"
HOMEPAGE="https://github.com/ROCm/rocPRIM"

if [[ "${PV}" == *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI=https://github.com/ROCm/rocPRIM.git
	S="${WORKDIR}/${P}"
else
	SRC_URI="https://github.com/ROCm/rocPRIM/archive/rocm-${PV}.tar.gz -> rocPRIM-${PV}.tar.gz"
	S="${WORKDIR}/rocPRIM-rocm-${PV}"
fi

LICENSE="MIT"
KEYWORDS="~amd64"
SLOT="0/$(ver_cut 1-2)"
IUSE="benchmark test"
REQUIRED_USE="${ROCM_REQUIRED_USE}"

RDEPEND="dev-util/hip
	benchmark? ( dev-cpp/benchmark )
	test? ( dev-cpp/gtest )"
BDEPEND="dev-build/rocm-cmake
	>=dev-build/cmake-3.22"
DEPEND="${RDEPEND}"

RESTRICT="!test? ( test )"

PATCHES=("${FILESDIR}"/${PN}-5.7.1-expand-isa-compatibility.patch)

src_prepare() {
	# install benchmark files
	if use benchmark; then
		sed -e "/get_filename_component/s,\${BENCHMARK_SOURCE},${PN}_\${BENCHMARK_SOURCE}," \
			-e "/add_executable/a\  install(TARGETS \${BENCHMARK_TARGET})" -i benchmark/CMakeLists.txt || die
	fi

	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_SKIP_RPATH=ON
		-DAMDGPU_TARGETS="$(get_amdgpu_flags)"
		-DBUILD_TEST=$(usex test ON OFF)
		-DBUILD_BENCHMARK=$(usex benchmark ON OFF)
		-DBUILD_FILE_REORG_BACKWARD_COMPATIBILITY=OFF
		-DROCM_SYMLINK_LIBS=OFF
	)

	CXX=hipcc cmake_src_configure
}

src_test() {
	check_amdgpu
	# uses HMM to fit tests to default <512M iGPU VRAM
	ROCPRIM_USE_HMM="1" cmake_src_test -j1
}
