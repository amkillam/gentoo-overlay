# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-fs/dmg2img/dmg2img-1.6.2.ebuild,v 1.0 2010/07/17 10:34:24 menelkir Exp $

EAPI=8
inherit toolchain-funcs

DESCRIPTION="Converts Apple DMG files to standard HFS+ images"
HOMEPAGE="http://vu1tur.eu.org/tools"
SRC_URI="http://vu1tur.eu.org/tools/${P}.tar.gz"
#SRC_URI="mirror://gentoo/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE=""

RDEPEND="dev-libs/openssl
	app-arch/bzip2
	sys-libs/zlib"
DEPEND="${RDEPEND}
	sys-apps/sed"
S="${WORKDIR}/${P}"

src_prepare() {
	cd "${S}" || die "Failed to enter ${S}"
	patch -Np1 --ignore-whitespace -i "${FILESDIR}/0001-openssl-1.1-compatibility.patch" || die "patch failed"
	sed -i -e 's:-s:$(LDFLAGS):g' Makefile || die "sed failed"
	eapply_user
}

src_compile() {
	tc-export CC
	emake CFLAGS="${CFLAGS}" || die "emake failed"
}

src_install() {
	dosbin dmg2img vfdecrypt || die "dosbin failed"
	dodoc README
}
