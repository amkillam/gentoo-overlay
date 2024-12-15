# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake-multilib

DESCRIPTION="Small, safe and fast formatting library"
HOMEPAGE="https://github.com/fmtlib/fmt"

if [[ ${PV} == *9999 ]]; then
	EGIT_REPO_URI="https://github.com/fmtlib/fmt.git"
	inherit git-r3
else
	SRC_URI="https://github.com/fmtlib/fmt/archive/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~loong ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc ~x86"
	S="${WORKDIR}/fmt-${PV}"
fi

LICENSE="MIT"
SLOT="0/${PV}"
IUSE="test static-libs"
RESTRICT="!test? ( test )"

multilib_src_configure() {
	local mycmakeargs=(
		-DFMT_CMAKE_DIR="$(get_libdir)/cmake/fmt"
		-DFMT_LIB_DIR="$(get_libdir)"
		-DFMT_TEST=$(usex test)
	)
	cmake_src_configure
	cmake_src_compile

	if use static-libs; then
		mycmakeargs+=(-DBUILD_SHARED_LIBS=OFF)
		cmake_src_configure
		cmake_src_compile
	fi
}

multilib_src_install() {

	#	exeinto $(get_libdir)
	#	doexe "${BUILD_DIR}/${PN}.so.${PV}"
	#	dosym "$(get_libdir)/${PN}.so.${PV}" "$(get_libdir)/${PN}.so.$(echo $PV | cut -d '.' -f1)"
	#	dosym "$(get_libdir)/${PN}.so.${PV}" "$(get_libdir)/${PN}.so"

	extension_libdir() {
		local extension=$1
		local libdir
		libdir="/$(get_libdir)"
		if [[ ${extension} == ".a" ]]; then
			libdir="usr${libdir}"
		fi
		echo "${libdir}"
	}

	default_src_install
	cmake_src_install

	extensions=".so"
	use static-libs && extensions=".so .a"
	for extension in ${extensions}; do
		insinto "$(extension_libdir $extension)" || die
		doins "${BUILD_DIR}/${PN}${extension}" || die
		dosym "$(extension_libdir $extension)/${PN}${extension}" "$(extension_libdir $extension)/${PN}${extension}.$(echo $PV | cut -d '.' -f1)" || die
		dosym "$(extension_libdir $extension)/${PN}${extension}" "$(extension_libdir $extension)/${PN}${extension}.${PV}" || die
	done

	#Install is not using our cmake file here - it must be cached somewhere. Force using ours.
	if use static-libs; then
		sed -i 's/add_library(fmt::fmt STATIC IMPORTED)/add_library(fmt::fmt SHARED IMPORTED)/' "${BUILD_DIR}/fmt-targets.cmake" || die
		sed -i "s,${BUILD_DIR},/usr/$(get_libdir),g" "${BUILD_DIR}/fmt-targets.cmake" || die
		sed -i "s,${S},/usr,g" "${BUILD_DIR}/fmt-targets.cmake" || die
		sed -i 's,set_target_properties(fmt::fmt PROPERTIES,set_target_properties(fmt::fmt PROPERTIES\n INTERFACE_COMPILE_DEFINITIONS "FMT_SHARED",g' "${BUILD_DIR}/fmt-targets.cmake" || die

		cat <<'EOF' >"${BUILD_DIR}/fmt-targets-relwithdebinfo.cmake" || die
	  #----------------------------------------------------------------
# Generated CMake target import file for configuration "RelWithDebInfo".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "fmt::fmt" for configuration "RelWithDebInfo"
set_property(TARGET fmt::fmt APPEND PROPERTY IMPORTED_CONFIGURATIONS RELWITHDEBINFO)
set_target_properties(fmt::fmt PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES_RELWITHDEBINFO "CXX"
  IMPORTED_LOCATION_RELWITHDEBINFO "${_IMPORT_PREFIX}/lib/libfmt.a"
  )

list(APPEND _cmake_import_check_targets fmt::fmt )
list(APPEND _cmake_import_check_files_for_fmt::fmt "${_IMPORT_PREFIX}/lib/libfmt.a" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
EOF

		for cmake_file in fmt-targets.cmake fmt-targets-relwithdebinfo.cmake; do
			sed -i "s,libfmt\.a,libfmt.so.$(echo "${PV}" | sed 's/-.*//g'),g" "${BUILD_DIR}/${cmake_file}" || die
			sed -i "s,IMPORTED_LOCATION_RELWITHDEBINFO,IMPORTED_SONAME_RELWITHDEBINFO \"libfmt.so.$(echo "$PV" | cut -d '.' -f1)\"\n  IMPORTED_LOCATION_RELWITHDEBINFO,g" "${BUILD_DIR}/${cmake_file}" || die
		done

		dodir "/usr/$(get_libdir)/cmake/fmt"
		insinto "/usr/$(get_libdir)/cmake/fmt"
		for cmake_file in fmt-targets.cmake fmt-targets-relwithdebinfo.cmake; do
			doins "${BUILD_DIR}/${cmake_file}"
		done
	fi
}
