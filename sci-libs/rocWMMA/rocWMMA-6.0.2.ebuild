# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
ROCM_SKIP_GLOBALS=1

inherit cmake rocm flag-o-matic

DESCRIPTION="library for accelerating mixed precision matrix multiply-accumulate operations"
HOMEPAGE="https://github.com/ROCm/rocWMMA"
SRC_URI="https://github.com/ROCm/rocWMMA/archive/rocm-${PV}.tar.gz -> rocWMMA-${PV}.tar.gz"

LICENSE="MIT"
KEYWORDS="~amd64"
SLOT="0/$(ver_cut 1-2)"

DEPEND=">=dev-util/hip-6"

BDEPEND="
	test? (
		dev-cpp/gtest
	)
	dev-build/rocm-cmake
"

IUSE_TARGETS=(gfx908 gfx90a gfx940 gfx941 gfx942 gfx1100 gfx1101 gfx1102)
IUSE_TARGETS=("${IUSE_TARGETS[@]/#/amdgpu_targets_}")

IUSE="${IUSE_TARGETS[@]/#/+} test"

REQUIRED_USE="|| ( ${IUSE_TARGETS[*]} )"

RESTRICT="!test? ( test )"

S="${WORKDIR}/rocWMMA-rocm-${PV}"

PATCHES=(
	"${FILESDIR}"/${PN}-6.0.2-use-system-googletest.patch
	"${FILESDIR}"/${PN}-6.0.2-add-iostream.patch
)

src_configure() {
	# ld.lld bug https://github.com/llvm/llvm-project/issues/61101
	filter-lto

	local mycmakeargs=(
		-DCMAKE_SKIP_RPATH=ON
		-DAMDGPU_TARGETS="$(get_amdgpu_flags)"
		-DROCM_SYMLINK_LIBS=OFF
		-DROCWMMA_BUILD_SAMPLES=OFF
		-DROCWMMA_BUILD_TESTS=$(usex test ON OFF)
	)
	use test && mycmakeargs+=(-DROCWMMA_USE_SYSTEM_GOOGLETEST=ON)
	CC=hipcc CXX=hipcc cmake_src_configure
}

src_test() {
	check_amdgpu
	cmake_src_test -j1
}
