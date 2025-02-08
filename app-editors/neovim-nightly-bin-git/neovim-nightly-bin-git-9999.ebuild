# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# RelWithDebInfo sets -Og -g
CMAKE_BUILD_TYPE=Release
LUA_COMPAT=(lua5-{1..2} luajit)
inherit lua-single optfeature xdg

DESCRIPTION="Vim-fork focused on extensibility and agility"
HOMEPAGE="https://neovim.io"
SRC_URI="https://github.com/neovim/neovim/releases/download/nightly/nvim-linux64.tar.gz"
KEYWORDS="~amd64 ~arm ~arm64 ~ppc64 ~riscv ~x86 ~x64-macos"
LICENSE="Apache-2.0 vim"
SLOT="0"
IUSE="+nvimpager test"
S=${WORKDIR}/nvim-linux64
D="/"
FEATURES="-collision-protect -protect-owned"

# Upstream say the test library needs LuaJIT
# https://github.com/neovim/neovim/blob/91109ffda23d0ce61cec245b1f4ffb99e7591b62/CMakeLists.txt#L377
REQUIRED_USE="${LUA_REQUIRED_USE} test? ( lua_single_target_luajit )"
# TODO: Get tests running
RESTRICT="!test? ( test ) test"

# Upstream build scripts invoke the Lua interpreter
BDEPEND="${LUA_DEPS}
	>=dev-util/gperf-3.1
	>=sys-devel/gettext-0.20.1
	virtual/libiconv
	virtual/libintl
	virtual/pkgconfig
"
# Check https://github.com/neovim/neovim/blob/master/third-party/CMakeLists.txt for
# new dependency bounds and so on on bumps (obviously adjust for right branch/tag).
DEPEND="${LUA_DEPS}
	>=dev-lua/luv-1.45.0[${LUA_SINGLE_USEDEP}]
	$(lua_gen_cond_dep '
		dev-lua/lpeg[${LUA_USEDEP}]
		dev-lua/mpack[${LUA_USEDEP}]
	')
	$(lua_gen_cond_dep '
		dev-lua/LuaBitOp[${LUA_USEDEP}]
	' lua5-{1,2})
	>=dev-libs/libuv-1.46.0:=
	>=dev-libs/libvterm-0.3.3
	>=dev-libs/msgpack-3.0.0:=
	dev-libs/tree-sitter
	>=dev-libs/libtermkey-0.22
	>=dev-libs/unibilium-2.0.0:0=
"
RDEPEND="
	${DEPEND}
	app-eselect/eselect-vi
"
BDEPEND+="
	test? (
		$(lua_gen_cond_dep 'dev-lua/busted[${LUA_USEDEP}]')
	)
"

src_install() {
	# install a default configuration file
	exeinto /usr/bin
	doexe "${WORKDIR}"/nvim-linux64/bin/*

	mkdir -p /lib/nvim/parser
	into /lib/nvim/parser
	for lib in "${WORKDIR}"/nvim-linux64/lib/nvim/parser/*; do
		dolib.so "$lib"
	done

	insinto /usr/share/applications
	doins "${WORKDIR}"/nvim-linux64/share/applications/nvim.desktop

	insinto /usr/share/icons/hicolor/128x128/apps/
	doins "${WORKDIR}"/nvim-linux64/share/icons/hicolor/128x128/apps/nvim.png

	for locale in "${WORKDIR}"/nvim-linux64/share/locale/*; do
		locale_dir=/usr/share/locale/"$(basename "$locale")"/LC_MESSAGES
		dodir "$locale_dir"
		insinto "$locale_dir"
		doins "${locale}"/LC_MESSAGES/nvim.mo
	done

	insinto /usr/share/man/man1/
	insinto "${WORKDIR}/nvim-linux64/share/man/man1/nvim.1"

	# rsync -av "${WORKDIR}/nvim-linux64/share/nvim" /usr/share
	insinto /usr/share
	doins -r "${WORKDIR}/nvim-linux64/share/nvim"

	# conditionally install a symlink for nvimpager
	if use nvimpager; then
		dosym /usr/share/nvim/runtime/macros/less.sh /usr/bin/nvimpager
	fi
}

pkg_postinst() {
	xdg_pkg_postinst

	optfeature "clipboard support" x11-misc/xsel x11-misc/xclip gui-apps/wl-clipboard
	optfeature "Python plugin support" dev-python/pynvim
	optfeature "Ruby plugin support" dev-ruby/neovim-ruby-client
	optfeature "remote/nvr support" dev-python/neovim-remote
}
