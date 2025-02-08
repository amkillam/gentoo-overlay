# Copyright 2022-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

HASH_CUBEB=54217bca3f3e0cd53c073690a23dd25d83557909

DESCRIPTION="Cross-platform audio library"
HOMEPAGE="https://github.com/mozilla/cubeb/"
SRC_URI="
	https://github.com/mozilla/cubeb/archive/${HASH_CUBEB}.tar.gz
		-> ${P}.tar.gz
"
S=${WORKDIR}/${PN}-${HASH_CUBEB}

LICENSE="ISC"
SLOT="0"
KEYWORDS="amd64 ~arm64 ~x86"
IUSE="alsa doc jack pulseaudio sndio test static-libs"
RESTRICT="!test? ( test )"

RDEPEND="
	media-libs/speexdsp
	alsa? ( media-libs/alsa-lib )
	jack? ( virtual/jack )
	pulseaudio? ( media-libs/libpulse )
	sndio? ( media-sound/sndio:= )
"
DEPEND="
	${RDEPEND}
	test? ( dev-cpp/gtest )
"
BDEPEND="doc? ( app-text/doxygen )"

PATCHES=(
	"${FILESDIR}"/${PN}-0.2_p20231121-automagic.patch
)

CMAKE_SKIP_TESTS=(
	# need access to real audio devices, and without sandbox
	audio
	callback_ret
	devices
	latency
	sanity
	tone
	# fragile unless all backends are enabled
	device_changed_callback
	duplex
	record
)

src_prepare() {
	cmake_src_prepare

	# test currently does not build unless use static libs
	sed -i '/cubeb_add_test(logging)/d' CMakeLists.txt || die
}

repeated_configure() {
	static_libs="$1"
	local mycmakeargs=(
		-DBUILD_RUST_LIBS=no # leaving out unless becomes really needed
		-DBUILD_TESTS=$(usex test)
		-DBUILD_TOOLS=no # semi-broken without most backends and not needed
		-DCHECK_ALSA=$(usex alsa)
		-DCHECK_JACK=$(usex jack)
		-DCHECK_PULSE=$(usex pulseaudio)
		-DCHECK_SNDIO=$(usex sndio)
		-DLAZY_LOAD_LIBS=no
		-DUSE_SANITIZERS=no
		-DBUILD_SHARED_LIBS=$static_libs
		$(cmake_use_find_package doc Doxygen)
	)

	cmake_src_configure
}

src_configure() {
	:
}

src_compile() {
	repeated_configure "OFF"
	cmake_src_compile

	if use static-libs; then
		repeated_configure "ON"
		cmake_src_compile
	fi
}

src_install() {

	exeinto /usr/lib64
	doexe "${BUILD_DIR}/libcubeb.so.0.0.0"
	dosym "/usr/lib64/libcubeb.so.0.0.0" "/usr/lib64/libcubeb.so.$(echo $PV | cut -d '.' -f1)"
	dosym "/usr/lib64/libcubeb.so.0.0.0" "/usr/lib64/libcubeb.so"

	if use static-libs; then
		insinto /usr/lib64
		doins "${BUILD_DIR}/libcubeb.a"
		dosym "/usr/lib64/libcubeb.a" "/usr/lib64/libcubeb.a.$(echo ${PV} | cut -d '.' -f 1)"
		dosym "/usr/lib64/libcubeb.a" "/usr/lib64/libcubeb.a.0.0.0"
	fi

	use doc && dodoc -r "${BUILD_DIR}"/docs/html
	cmake_src_install
	default_src_install
}
