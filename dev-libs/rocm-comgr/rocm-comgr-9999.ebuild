# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake prefix

if [[ ${PV} == *9999 ]]; then
	EGIT_REPO_URI=https://github.com/ROCm/llvm-project.git
	inherit git-r3
	S="${WORKDIR}/${P}/amd/comgr"
else
	SRC_URI="https://github.com/ROCm/ROCm-CompilerSupport/archive/rocm-${PV}.tar.gz -> ${P}.tar.gz"
	S="${WORKDIR}/ROCm-CompilerSupport-rocm-${PV}/lib/comgr"
	KEYWORDS="~amd64"
fi

IUSE="test"
RESTRICT="!test? ( test )"

PATCHES=(
	#	"${FILESDIR}/${PN}-5.1.3-rocm-path.patch"
	"${FILESDIR}/0001-Find-CLANG_RESOURCE_DIR-using-clang-print-resource-d.patch"
	"${FILESDIR}/${PN}-6.0.0-extend-isa-compatibility-check.patch"
)

DESCRIPTION="Radeon Open Compute Code Object Manager"
HOMEPAGE="https://github.com/ROCm/ROCm-CompilerSupport"
LICENSE="MIT"
SLOT="0/$(ver_cut 1-2)"

RDEPEND=">=dev-libs/rocm-device-libs-6.1.2
	llvm-core/clang-runtime:=
	llvm-core/clang:20
	sys-devel/lld:20
"
DEPEND="${RDEPEND}"

CMAKE_BUILD_TYPE=Release

get_llvm_prefix() {
	echo /usr/lib/llvm/20
}

src_prepare() {
	sed '/sys::path::append(HIPPath/s,"hip","",' -i src/comgr-env.cpp || die
	sed "/return LLVMPath;/s,LLVMPath,llvm::SmallString<128>(\"$(get_llvm_prefix)\")," -i src/comgr-env.cpp || die
	eapply $(prefixify_ro "${FILESDIR}"/${PN}-5.0-rocm_path.patch)
	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DLLVM_DIR="$(get_llvm_prefix)"
		-DCMAKE_STRIP="" # disable stripping defined at lib/comgr/CMakeLists.txt:58
		-DBUILD_TESTING=$(usex test ON OFF)
	)
	cmake_src_configure
}
