# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake llvm

LLVM_MAX_SLOT=17

if [[ ${PV} == *9999 ]] ; then
	EGIT_REPO_URI="https://github.com/RadeonOpenCompute/ROCm-Device-Libs/"
	inherit git-r3
	S="${WORKDIR}/${P}/src"
else
	SRC_URI="https://github.com/RadeonOpenCompute/ROCm-Device-Libs/archive/rocm-${PV}.tar.gz -> ${P}.tar.gz"
	S="${WORKDIR}/ROCm-Device-Libs-rocm-${PV}"
	KEYWORDS="~amd64"
fi

DESCRIPTION="Radeon Open Compute Device Libraries"
HOMEPAGE="https://github.com/RadeonOpenCompute/ROCm-Device-Libs"

LICENSE="MIT"
SLOT="0/$(ver_cut 1-2)"
IUSE="test"
RESTRICT="!test? ( test )"

RDEPEND="sys-devel/clang:${LLVM_MAX_SLOT}"
DEPEND="${RDEPEND}"

CMAKE_BUILD_TYPE=Release

PATCHES=(
	"${FILESDIR}/${PN}-5.5.1-fix-llvm-link.patch"
	"${FILESDIR}/${PN}-5.7.1-test-bitcode-dir.patch"
)

src_prepare() {
	sed -e "s:amdgcn/bitcode:lib/amdgcn/bitcode:" -i "${S}/cmake/OCL.cmake" || die
	sed -e "s:amdgcn/bitcode:lib/amdgcn/bitcode:" -i "${S}/cmake/Packages.cmake" || die
	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DLLVM_DIR="$(get_llvm_prefix "${LLVM_MAX_SLOT}")"
	)
	# do not trust CMake with autoselecting Clang, as it autoselects the latest one
	# producing too modern LLVM bitcode and causing linker errors in other packages
	CC="$(get_llvm_prefix "${LLVM_MAX_SLOT}")/bin/clang" \
	CXX="$(get_llvm_prefix "${LLVM_MAX_SLOT}")/bin/clang++" cmake_src_configure
}

src_test() {
	local CMAKE_SKIP_TESTS=(
		# LLVM in Gentoo generates different assembly
		compile_atan2__gfx700
		compile_atan2pi__gfx700
		compile_frexp__gfx600
	)
	cmake_src_test
}
