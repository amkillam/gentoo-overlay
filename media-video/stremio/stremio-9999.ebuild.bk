# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit qmake-utils git-r3

DESCRIPTION="A hub for content aggregation"
HOMEPAGE="https://www.stremio.com/"
#SRC_URI="https://github.com/Stremio/stremio-shell/archive/$PV.tar.gz -> $P.tar.gz"
EGIT_REPO_URI="https://github.com/Stremio/stremio-shell.git"

LICENSE="GPL-3"
SLOT="0"
#KEYWORDS="~amd64"
IUSE=""

DEPEND="
	dev-libs/openssl:0
	dev-qt/qtcore:5
	dev-qt/qtdeclarative:5
	dev-qt/qtgui:5
	dev-qt/qtnetwork:5
	dev-qt/qtwebengine:5
	dev-qt/qtwidgets:5
	media-video/mpv[libmpv]

	dev-qt/qtwebchannel:5
	dev-qt/qtquickcontrols:5
	dev-qt/qtquickcontrols2:5
	net-libs/nodejs
"
RDEPEND="${DEPEND}"
monospaceBDEPEND=""

#S=$WORKDIR/stremio-shell-$PV

src_configure() {
  eqmake5
}

src_install() {
  emake INSTALL_ROOT="$D" DESTDIR="${D}" install
}
