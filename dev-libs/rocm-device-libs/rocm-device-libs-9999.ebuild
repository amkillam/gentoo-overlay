# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

if [[ ${PV} == *9999 ]]; then
	EGIT_REPO_URI="https://github.com/ROCm/llvm-project.git"
	inherit git-r3
	S="${WORKDIR}/${P}/amd/device-libs"
else
	SRC_URI="https://github.com/ROCm/ROCm-Device-Libs/archive/rocm-${PV}.tar.gz -> ${P}.tar.gz"
	S="${WORKDIR}/ROCm-Device-Libs-rocm-${PV}"
	KEYWORDS="~amd64"
fi

DESCRIPTION="Radeon Open Compute Device Libraries"
HOMEPAGE="https://github.com/ROCm/ROCm-Device-Libs"

LICENSE="MIT"
SLOT="0/$(ver_cut 1-2)"
IUSE="test"
RESTRICT="!test? ( test )"

BDEPEND="
	dev-build/rocm-cmake
		sys-devel/clang:19
		sys-devel/lld:19
"

CMAKE_BUILD_TYPE=Release

PATCHES=(
	"${FILESDIR}/${PN}-5.5.1-fix-llvm-link.patch"
)

src_prepare() {
	sed -e "s:amdgcn/bitcode:lib/amdgcn/bitcode:" -i "${S}/cmake/OCL.cmake" || die
	sed -e "s:amdgcn/bitcode:lib/amdgcn/bitcode:" -i "${S}/cmake/Packages.cmake" || die
	cmake_src_prepare
}

get_llvm_prefix() {
	echo /usr/lib/llvm/19
}

src_configure() {
	local mycmakeargs=(
		-DLLVM_DIR="$(get_llvm_prefix)"
	)
	# do not trust CMake with autoselecting Clang, as it autoselects the latest one
	# producing too modern LLVM bitcode and causing linker errors in other packages
	CC="$(get_llvm_prefix)/bin/clang" CXX="$(get_llvm_prefix)/bin/clang++" cmake_src_configure
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
