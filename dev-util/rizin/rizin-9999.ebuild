# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=(python3_{10..13})

inherit meson python-any-r1 git-r3

DESCRIPTION="reverse engineering framework for binary analysis"
HOMEPAGE="https://rizin.re/"

EGIT_REPO_URI="https://github.com/rizinorg/rizin.git"
EGIT_SUBMODULES=('*')
S="${WORKDIR}/${PN}-${PV}"

LICENSE="Apache-2.0 BSD LGPL-3 MIT"
SLOT="0/${PV}"
KEYWORDS="amd64 ~arm64 ~x86"
IUSE=""

# Need to audit licenses of the binaries used for testing
RESTRICT="fetch"

# TODO: unbundle dev-libs/blake3
RDEPEND="
	app-arch/lz4:0=
	app-arch/xz-utils
	app-arch/zstd:=
	>=dev-libs/capstone-5:0=
	dev-libs/libmspack
	dev-libs/libpcre2:0=[jit]
	dev-libs/libzip:0=
	dev-libs/openssl:0=
	>=dev-libs/tree-sitter-0.19.0:=
	dev-libs/xxhash
	sys-apps/file
	sys-libs/zlib:0=
"
DEPEND="${RDEPEND}"
BDEPEND="${PYTHON_DEPS}"

PATCHES=(
	"${FILESDIR}/${PN}-0.4.0-never-rebuild-parser.patch"
)

src_unpack() {
	git-r3_src_unpack

	for wrap in libdemangle rizin-grammar-c tree-sitter blake3 capstone-next capstone-v4 capstone-v5 capstone-v6 pcre2 softfloat; do
		if [[ "$wrap" == "tree-sitter" ]]; then
			url="https://github.com/tree-sitter/tree-sitter.git"
			revision="refs/tags/v0.21.0"
		else
			url=$(grep '^url =' "${S}/subprojects/${wrap}.wrap" | sed 's/.*= //g')
			revision=$(grep '^revision =' "${S}/subprojects/${wrap}.wrap" | sed 's/.*= //g')
		fi
		dir="${S}/subprojects/$wrap"
		dir_grep="$(grep "^directory =" "${S}/subprojects/${wrap}.wrap")"
		if [ -n "${dir_grep}" ]; then
			dir="${S}/subprojects/$(echo "$dir_grep" | sed 's/.*= //g')"
		fi

		[[ ${revision:0:1} == v ]] && revision="refs/heads/${revision}"
		git-r3_fetch "${url}" "${revision}" "${wrap}"
		git-r3_checkout "${url}" "${dir}" "${wrap}"
		# if [ ! -f "${dir}/meson.build" ]; then
		patchdir="${S}/subprojects/packagefiles/$(basename "$dir")"
		[ ! -d "$patchdir" ] && patchdir="${S}/subprojects/packagefiles/${wrap}"
		if [ -d "$patchdir" ]; then
			for file in "$patchdir"/*; do
				cp -r "${file}" "${dir}" || die
			done
		fi
		# fi
	done
}

src_prepare() {
	default

	local py_to_mangle=(
		librz/core/cmd_descs/cmd_descs_generate.py
		sys/clang-format.py
		test/fuzz/scripts/fuzz_rz_asm.py
		test/scripts/gdbserver.py
	)

	python_fix_shebang "${py_to_mangle[@]}"

	# https://github.com/rizinorg/rizin/issues/3459
	sed -ie '/dyld_chained_ptr_arm64e_auth/d' test/unit/test_bin_mach0.c || die

}

src_configure() {
	local emesonargs=(
		-Dcli=enabled
		-Duse_sys_capstone=enabled
		-Duse_sys_libmspack=enabled
		-Duse_sys_libzip=enabled
		-Duse_sys_libzstd=enabled
		-Duse_sys_lz4=enabled
		-Duse_lzma=true
		-Duse_zlib=true
		-Duse_sys_lzma=enabled
		-Duse_sys_magic=enabled
		-Duse_sys_openssl=enabled
		-Duse_sys_pcre2=enabled
		-Duse_sys_tree_sitter=disabled
		-Duse_sys_xxhash=enabled
		-Duse_sys_zlib=enabled
		-Duse_sys_softfloat=disabled
		-Denable_tests=false
		-Denable_rz_test=false
	)
	meson_src_configure
}
