# Copyright 2002-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="HDiffPatch is a C\C++ library and command-line tools for diff & patch between binary files or directories(folder); cross-platform; fast running; create small delta/differential; support large files and limit memory requires when diff & patch."
HOMEPAGE="https://github.com/sisong/HDiffPatch"
if [[ ${PV} == *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/sisong/HDiffPatch.git"
	EGIT_REPO_URI+=" https://github.com/sisong/lzma.git"
else
	SRC_URI="https://github.com/sisong/HDiffPatch/releases/download/v${PV}/${PN}_v${PV}_sources.tar.gz -> ${P}.tar.gz"

	KEYWORDS="~amd64 ~x86"
fi
S="${WORKDIR}/${P}"

LICENSE="GPL-2"
SLOT="3"
KEYWORDS="~alpha amd64 ~arm64 ~hppa ~ia64 ~loong ppc ppc64 ~riscv sparc x86"
IUSE="lzma zstd md5 bzip2"

RDEPEND="
lzma? ( app-arch/xz-utils:= )
zstd? ( app-arch/zstd:= )
bzip2? ( app-arch/bzip2:= )
"
DEPEND="${RDEPEND}"

src_compile() {

	export LZMA=0
	export ZSTD=0
	export MD5=0
	export BZIP2=0

	make_str="emake"
	use lzma && make_str+=" LZMA=1"
	use zstd && make_str+=" ZSTD=1"
	use md5 && make_str+=" MD5=1"
	use bzip2 && make_str+=" BZIP2=1"

	$make_str
}

src_install() {
	emake DESTDIR="${D}" install
}
