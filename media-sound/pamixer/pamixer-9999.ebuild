EAPI=8

inherit meson
DESCRIPTION="Pulseaudio command line mixer."
HOMEPAGE="https://github.com/cdemoulins/pamixer"

if [[ ${PV} == *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/cdemoulins/pamixer"
else
	SRC_URI="https://github.com/cdemoulins/pamixer/archive/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

RESTRICT="mirror"
LICENSE="GPL-3"
SLOT="0"
IUSE=""

BDEPEND="
media-libs/libpulse
dev-libs/cxxopts
"
RDEPEND="
	dev-libs/boost
	media-sound/pulseaudio"

DEPEND="${RDEPEND}"

src_configure() {
	meson_src_configure
}

src_install() {
	meson_src_install
}

