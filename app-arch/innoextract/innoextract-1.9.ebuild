# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="A tool to unpack installers created by Inno Setup"
HOMEPAGE="https://constexpr.org/innoextract/"
SRC_URI="https://constexpr.org/innoextract/files/${P}.tar.gz"

LICENSE="ZLIB"
SLOT="0"
KEYWORDS="amd64 ~arm arm64 ~m68k ppc64 x86"
IUSE="debug +iconv +lzma"

RDEPEND="
	>=dev-libs/boost-1.85.0-r1
	iconv? ( virtual/libiconv )
	lzma? ( app-arch/xz-utils )"
DEPEND="${RDEPEND}"

PATCHES=(
	"${FILESDIR}/${PN}-1.9-fix-linkage.patch"
	"${FILESDIR}/${PN}-1.9-boost-1.85.0.patch"
)

src_configure() {
	local mycmakeargs=(
		-DDEBUG=$(usex debug)
		-DSET_OPTIMIZATION_FLAGS=OFF
		-DSTRICT_USE=ON
		-DUSE_LZMA=$(usex lzma)
		-DWITH_CONV=$(usex iconv iconv builtin)
	)

	cmake_src_configure
}
