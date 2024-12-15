# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="Binary-decimal and decimal-binary conversion routines for IEEE doubles"
HOMEPAGE="https://github.com/google/double-conversion/"
SRC_URI="
	https://github.com/google/double-conversion/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.tar.gz
"

LICENSE="BSD"
SLOT="0/3"
KEYWORDS="~alpha amd64 arm arm64 hppa ~ia64 ~loong ~m68k ~mips ppc ppc64 ~riscv ~s390 sparc x86 ~amd64-linux ~x86-linux"
IUSE="test static-libs"
RESTRICT="!test? ( test )"

S="${WORKDIR}/${P}"

src_shared_configure() {
	local mycmakeargs=(
		-DBUILD_TESTING=$(usex test)
	)

	cmake_src_configure
}

src_static_configure() {
	local mycmakeargs=(
	-DBUILD_TESTING=$(usex test)
	-DBUILD_SHARED_LIBS=OFF
)
	cmake_src_configure
}

src_configure() {
	:;
}

src_compile() {
	src_shared_configure
	default
	if use static-libs; then
		src_static_configure
		default
	fi
}

src_install() {
	[[ "${PV}" == "3.3.0" ]] && [ -f "${S}/libdouble-conversion.so.3.2.0" ] && mv "${S}/libdouble-conversion.so.3.2.0" "${S}/libdouble-conversion.so.${PV}"

	if use static-libs; then
		insinto /usr/lib64
		newins "${S}/libdouble-conversion.a" libdouble-conversion.a
		newins "${S}/libdouble-conversion_pic.a" libdouble-conversion_pic.a
	fi

	exeinto /usr/lib64
        doexe "${S}/libdouble-conversion.so.${PV}"
	dosym /usr/lib64/libdouble-conversion.so.${PV} /usr/lib64/libdouble-conversion.so
	dosym /usr/lib64/libdouble-conversion.so.${PV} "/usr/lib64/libdouble-conversion.so.$(echo "$PV" | cut -d '.' -f1)"
}
