# Copyright 2020-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit flag-o-matic cmake toolchain-funcs xdg

DESCRIPTION="An emulator for Nintendo Switch"
HOMEPAGE="https://yuzu-emu.org"

#KNOWN WORKING
#EGIT_OVERRIDE_COMMIT_GPUOPEN_LIBRARIESANDSDKS_VULKANMEMORYALLOCATOR="de8e65796ae5bf780a828c47376e6744bf1f4336"
#EGIT_OVERRIDE_COMMIT_KHRONOSGROUP_VULKAN_HEADERS="c6391a7b8cd57e79ce6b6c832c8e3043c4d9967b"
#EGIT_OVERRIDE_COMMIT_KHRONOSGROUP_VULKAN_UTILITY_LIBRARIES="7ea05992a52e96426bd4c56ea12d208e0d6c9a5f"
#EGIT_OVERRIDE_COMMIT_FFMPEG_FFMPEG="3f9ca51015020d6d60a48923c55d66cc3ea04e9b"
#EGIT_OVERRIDE_COMMIT_KHRONOSGROUP_SPIRV_HEADERS="efb6b4099ddb8fa60f62956dee592c4b94ec6a49"
#EGIT_OVERRIDE_COMMIT_KHRONOSGROUP_SPIRV_TOOLS="b21dda0ee7a3ea4e0192a7b2b09db1df1de9d5e7"

EGIT_OVERRIDE_COMMIT_GPUOPEN_LIBRARIESANDSDKS_VULKANMEMORYALLOCATOR="HEAD"
EGIT_OVERRIDE_COMMIT_KHRONOSGROUP_VULKAN_HEADERS="HEAD"
EGIT_OVERRIDE_COMMIT_KHRONOSGROUP_VULKAN_UTILITY_LIBRARIES="HEAD"
EGIT_OVERRIDE_COMMIT_FFMPEG_FFMPEG="HEAD"
EGIT_OVERRIDE_COMMIT_KHRONOSGROUP_SPIRV_HEADERS="HEAD"
EGIT_OVERRIDE_COMMIT_KHRONOSGROUP_SPIRV_TOOLS="HEAD"

EGIT_REPO_TOR_URI="http://vub63vv26q6v27xzv2dtcd25xumubshogm67yrpaz2rculqxs7jlfqad.onion/torzu-emu/torzu.git"
EGIT_REPO_HTTPS_URI="https://notabug.org/litucks/torzu.git"

EGIT_SUBMODULES=('externals/simpleini' 'externals/nx_tzdb/tzdb_to_nx' 'externals/VulkanMemoryAllocator' 'externals/xbyak')
# Dynarmic is not intended to be generic, it is tweaked to fit emulated processor
# TODO wait 'xbyak' waiting version bump. see #860816

LICENSE="|| ( Apache-2.0 GPL-2+ ) 0BSD BSD GPL-2+ ISC MIT
	!system-vulkan? ( Apache-2.0 )"
SLOT="0"
KEYWORDS="amd64"
IUSE="+compatibility-list +cubeb discord +qt5 qt6 sdl +system-vulkan +system-ffmpeg test webengine +webservice lto +system-spirv bundled-qt bundled-sdl remove-rebrand shared-libs static tor wayland X opengl prefer-static-libs"

RDEPEND="
	net-libs/mbedtls[cmac]
	>=app-arch/zstd-1.5
	>=dev-libs/inih-52
	>=dev-libs/libfmt-9:=
	>=dev-libs/openssl-1.1:=
	system-ffmpeg? (
		>=media-video/ffmpeg-4.3:=
	)
	!system-ffmpeg? (
		>=media-libs/nv-codec-headers-12.1.14.0
	)
	>=net-libs/enet-1.3
	app-arch/lz4:=
	dev-libs/boost:=[context]
	media-libs/opus
	media-libs/vulkan-loader
	sys-libs/zlib
	virtual/libusb:1
	cubeb? ( !static? ( media-libs/cubeb ) )
	qt5? (
		>=dev-qt/qtcore-5.15:5
		>=dev-qt/qtgui-5.15:5
		>=dev-qt/qtmultimedia-5.15:5
		>=dev-qt/qtwidgets-5.15:5
	)
	qt6? (
		>=dev-qt/qtbase-6.6.0:6[gui,widgets]
	)
	bundled-qt? (
		media-libs/harfbuzz
		dev-libs/icu
		media-libs/freetype
		media-libs/libpng
		media-libs/libjpeg-turbo
		dev-libs/libpcre
		sys-libs/zlib
		app-arch/zstd
		static? (
			dev-libs/icu[static-libs]
			app-arch/zstd[static-libs]
			media-libs/freetype[static-libs]
			media-libs/libpng[static-libs]
			media-libs/libjpeg-turbo[static-libs]
			dev-libs/libpcre[static-libs]
			sys-libs/zlib[static-libs]
		)
	)
	sdl? (
		>=media-libs/libsdl2-2.0.18
	)
"
DEPEND="${RDEPEND}
	dev-cpp/cpp-httplib
	dev-cpp/cpp-jwt
	system-vulkan? (
		>=dev-util/vulkan-headers-1.3.236
		>=dev-util/vulkan-utility-libraries-1.3.236
	)
	test? ( >=dev-cpp/catch-3:0 )
"
BDEPEND="
	>=dev-cpp/nlohmann_json-3.8.0
	dev-cpp/robin-map
	dev-util/glslang
	discord? ( >=dev-libs/rapidjson-1.1.0 )
	dev-vcs/git
	static? ( 
		net-libs/enet[static-libs]
		app-arch/zstd[static-libs]
		dev-libs/libusb[static-libs]
	)
	tor? ( net-vpn/tor )
"
REQUIRED_USE="|| ( qt5 qt6 sdl bundled-qt bundled-sdl ) discord? ( webservice )"
RESTRICT="
!test? ( test )
network-sandbox
"
#PATCHES=( "${FILESDIR}/${P}-optional-externals-vulkan-memory-allocator.patch" )
PATCHES_EARLY_APPLY=("${FILESDIR}/${P}-use-yuzu-app-name.patch")
S="${WORKDIR}/${P}"

git_wrapper() {

	if use tor; then
		 ALL_PROXY=socks5h://127.0.0.1:9050 git $@
	else
		git $@
	fi

}

pkg_setup() {
	tc-is-gcc &&
		[[ "$(gcc-major-version)" -lt 11 ]] &&
		die "You need gcc version 11 or clang to compile this package"
}

src_unpack() {
	#	use discord && EGIT_SUBMODULES+=('discord-rpc')

	use !system-vulkan && EGIT_SUBMODULES+=('externals/Vulkan-Headers' 'externals/Vulkan-Utility-Libraries')

	use !system-ffmpeg && EGIT_SUBMODULES+=('externals/ffmpeg/ffmpeg')

	use !system-spirv && EGIT_SUBMODULES+=('externals/SPIRV-Tools' 'externals/SPIRV-Headers')
	use bundled-sdl && EGIT_SUBMODULES+=('externals/SDL')

	if use static; then
		use discord && EGIT_SUBMODULES+=('externals/discord-rpc')

		EGIT_SUBMODULES+=('externals/cpp-httplib' 'externals/mbedtls' 'externals/cubeb')
	fi

	EGIT_REPO_URI="$EGIT_REPO_HTTPS_URI"
	use tor && EGIT_REPO_URI="$EGIT_REPO_TOR_URI"

	mkdir -p "$(basename "$S")"
	git_wrapper clone --depth=1 "$EGIT_REPO_URI" "${S}" || die
	git config --global --add safe.directory "${S}"
	cd "$S"

	for submodule in "${EGIT_SUBMODULES[@]}"; do
		git_wrapper submodule update --init --depth=1 --recursive "$submodule" || die
	done

	#     rm -rf "${S}/externals/nx_tzdb/tzdb_to_nx/externals/tz/tz"
	#     ln -sf "${S}/externals/tz/tz" "${S}/externals/nx_tzdb/tzdb_to_nx/externals/tz/tz" || die

	git config --global --add safe.directory "${S}/externals/nx_tzdb/tzdb_to_nx/externals/tz/tz" || die
	git config --global --add safe.directory "${S}/.git/modules/tzdb_to_nx/modules/externals/tz/tz" || die

	if use bundled-qt; then
		git_wrapper clone https://github.com/qt/qt5.git -b 5.15.2 --depth=1 "${S}/externals/qt5"
		cd "${S}/externals/qt5"

		QT5_SUBMODULES=(
			qtbase
			qtdeclarative
			qttranslations
			qtmultimedia
			qttools
		)

		use wayland && QT5_SUBMODULES+=(qtwayland)
		use webengine && QT5_SUBMODULES+=(qtwebengine)

		for submodule in "${QT5_SUBMODULES[@]}"; do
			git_wrapper submodule update --init --depth=1 "$submodule" || die
		done

		cd "${S}"

	fi

	# Do not fetch via sources because this file always changes
	#use compatibility-list && curl https://api.yuzu-emu.org/gamedb/ > "${S}"/compatibility_list.json
}

src_prepare() {

	flto_addition='-flto'
	[[ "$CC" == *gcc* ]] && flto_addition='-flto=7'
	if use lto; then
		export CFLAGS="${CFLAGS} $flto_addition"
		export LDFLAGS="${LDFLAGS} -Wl,-flto $flto_addition"
		export CXXFLAGS="${CXXFLAGS} $flto_addition"
		export CPPFLAGS="$CXXFLAGS"
	fi

	if use static; then
		export LDFLAGS="${LDFLAGS} -static-pie -static-libgcc"
		export CFLAGS="${CFLAGS} -fpie"
		export CXXFLAGS="${CXXFLAGS} -fpie"
		export CPPFLAGS="$CXXFLAGS"
	fi

	use remove-rebrand && eapply "${FILESDIR}/${P}-use-yuzu-app-name.patch"
	# temporary fix
	sed -i -e '/Werror/d' src/CMakeLists.txt || die

	# Allow skip submodule downloading
	rm .gitmodules || die

	# Workaround: GenerateSCMRev fails
	sed -i -e "s/@GIT_BRANCH@/${EGIT_BRANCH:-master}/" \
		-e "s/@GIT_REV@/$(git rev-parse --short HEAD)/" \
		-e "s/@GIT_DESC@/$(git describe --always --long)/" \
		src/common/scm_rev.cpp.in || die

	if use !discord; then
		sed -i -e '/^if.*discord-rpc/,/^endif()/d' externals/CMakeLists.txt || die
	fi

	if use !static; then
		# Unbundle mbedtls
		sed -i -e '/^# mbedtls/,/^endif()/d' externals/CMakeLists.txt || die
		sed -i -e 's/mbedtls/& mbedcrypto mbedx509/' \
			src/dedicated_room/CMakeLists.txt \
			src/core/CMakeLists.txt || die

		if use discord; then
			# Unbundle discord rapidjson
			sed -i -e '/NOT RAPIDJSONTEST/,/endif(NOT RAPIDJSONTEST)/d' \
				-e '/find_file(RAPIDJSON/d' -e 's:\${RAPIDJSON}:"/usr/include/rapidjson":' \
				externals/discord-rpc/CMakeLists.txt || die
		fi

		# Unbundle cubeb
		if use cubeb; then
			sed -i '$afind_package(Threads REQUIRED)' CMakeLists.txt || die
		fi
		sed -i '/^if.*cubeb/,/^endif()/d' externals/CMakeLists.txt || die

		# Unbundle cpp-httplib
		sed -i -e '/httplib/s/ 0.12//' CMakeLists.txt || die
		sed -i -e '/^# httplib/,/^endif()/d' externals/CMakeLists.txt || die

	else
		if [[ "$(grep "CMAKE_FIND_LIBRARY_SUFFIXES" "${S}/CMakeLists.txt")" == "" ]]; then
			cmakelists_content="$(cat "${S}/CMakeLists.txt")"
			echo "set(CMAKE_FIND_LIBRARY_SUFFIXES \".a\")" >"${S}/CMakeLists.txt"
			echo "$cmakelists_content" >>"${S}/CMakeLists.txt"
		fi

	fi
	#	else
	#		sed -i 's/AND NOT TARGET.*)/)/g' "${S}/externals/CMakeLists.txt" || die
	#		sed -i 's/find_package(enet .*//g' "${S}/CMakeLists.txt" || die
	sed -i 's/httplib::httplib/httplib/g' "${S}/src/yuzu/CMakeLists.txt" || die

	#unbundle zstd
	sed -i 's/.*zstd.*//g' CMakeLists.txt || die
	# Unbundle enet
	sed -i -e '/^if.*enet/,/^endif()/d' externals/CMakeLists.txt || die
	sed -i -e '/enet\/enet\.h/{s/"/</;s/"/>/}' src/network/network.cpp || die

	# LZ4 temporary fix: https://github.com/yuzu-emu/yuzu/pull/9054/commits/a8021f5a18bc5251aef54468fa6033366c6b92d9
	sed -i 's/lz4::lz4/lz4/' src/common/CMakeLists.txt || die

	# Allow compiling using older glslang
	sed -i -e '/Vulkan/s/274/275/' CMakeLists.txt || die

	cp "${FILESDIR}/dist/"* dist
	use qt6 && sed -i 's/^Exec=\/usr\/bin\/yuzu/Exec=env QT_QPA_PLATFORM=xcb \/usr\/bin\/yuzu/g' dist/org.yuzu_emu.yuzu.desktop

	use !system-spirv && ln -s "$(realpath externals/SPIRV-Headers)" "$(realpath externals/SPIRV-Tools/external/SPIRV-Headers)"

	if use bundled-sdl; then
		sed -i 's/typedef struct XGenericEventCookie XGenericEventCookie;//g' "${S}/externals/SDL/src/video/x11/SDL_x11xinput2.h" || die
	fi

	# Fix "unknown type name 'async_operation' in boost/asio/co_composed.hpp
	sed -i 's/add_definitions(-DBOOST_ASIO_DISABLE_CONCEPTS)//g' "${S}/CMakeLists.txt" || die

	#Fix Wshorten-64-to-32 in src/input_common/helpers/udp_protocol.h
	sed -i 's/crc\.checksum()/(u32_le) crc.checksum()/g' "${S}/src/input_common/helpers/udp_protocol.h" || die

	cmake_src_prepare
}

compile_qt() {

	flto_addition='-flto'
	[[ "$CC" == *gcc* ]] && flto_addition='-flto=7'
	if use lto; then
		export CFLAGS="${CFLAGS} $flto_addition"
		export LDFLAGS="${LDFLAGS} -Wl,-flto $flto_addition"
		export CXXFLAGS="${CXXFLAGS} $flto_addition"
		export CPPFLAGS="$CXXFLAGS"
	fi

	if use static; then
		export LDFLAGS="${LDFLAGS} -static-pie -static-libgcc"
		export CFLAGS="${CFLAGS} -fpie"
		export CXXFLAGS="${CXXFLAGS} -fpie"
		export CPPFLAGS="$CXXFLAGS"
	fi
	export QMAKE_LFLAGS="$LDFLAGS"

	cd "${S}/externals/qt5"

	NEEDS_GCC_LIMITS_INCLUDE="src/corelib/codecs/qtextcodec.cpp src/corelib/codecs/qutfcodec.cpp src/corelib/global/qendian.cpp src/corelib/global/qfloat16.cpp src/corelib/global/qrandom.cpp src/corelib/plugin/qelfparser_p.cpp src/corelib/plugin/qmachparser.cpp src/corelib/plugin/quuid.cpp src/corelib/serialization/qdatastream.cpp src/corelib/text/qbytearray.cpp src/corelib/text/qbytearraymatcher.cpp src/corelib/tools/qbitarray.cpp src/corelib/tools/qcryptographichash.cpp src/gui/text/qfontengine_qpf2.cpp ../qtdeclarative/src/3rdparty/masm/yarr/Yarr.h ../qtdeclarative/src/qmldebug/qqmlprofilerevent.cpp ../qtdeclarative/src/qmldebug/qqmlprofilerevent_p.h"

	recurse_grep="rg"
	if [[ "$(rg --version 2>&1)" != *ripgrep* ]]; then
		recurse_grep="grep -R"
	fi

	OLD_IFS=$IFS
	export IFS=$'\n'
	for file in $($recurse_grep -l 'numeric_limits' | grep -v 'txt' | grep -v '^build' | grep -v '\.json$' | grep -v 'compilerdetection'); do
		contents="$(cat "$file")"
		echo '#include <limits>' >"$file" || die
		echo "$contents" >>"$file" || die
	done
	export IFS=$OLD_IFS

	mkdir -p build || true
	cd build || die
	mkdir -p out || true

	CONFIGURE_CMD="../configure -opensource -confirm-license -prefix $(pwd)/out -gtk -icu -no-rpath -skip qtdoc"
	use static && CONFIGURE_CMD+=" -static -dbus-linked -openssl-linked"
	use !webengine && CONFIGURE_CMD+=" -skip qtwebengine"

	use X && CONFIGURE_CMD+=" -xcb -xcb-xlib -xkbcommon -bundled-xcb-xinput"
	if use wayland; then
		CONFIGURE_CMD+=" -qpa wayland;xcb"
	else
		CONFIGURE_CMD+=" -skip qtwayland -qpa xcb"
	fi
	use !opengl && CONFIGURE_CMD+=" -no-opengl"

	tc-export AR CC CXX OBJDUMP RANLIB STRIP
	CONFIGURE_CMD="${CONFIGURE_CMD} \
		$(if use kernel_linux; then
		if tc-is-gcc; then
			echo -platform linux-g++
		elif tc-is-clang; then
			echo -platform linux-clang
		fi
	fi) \
		-no-optimized-tools \
		-release \
		-no-sql-db2 -no-sql-ibase -no-sql-mysql -no-sql-oci -no-sql-odbc \
		-no-sql-psql -no-sql-sqlite -no-sql-sqlite2 -no-sql-tds \
		$(is-flagq -mno-dsp && echo -no-mips_dsp) \
		$(is-flagq -mno-dspr2 && echo -no-mips_dspr2) \
		$(tc-cpp-is-true "defined(__SSE2__)" ${CFLAGS} ${CXXFLAGS} || echo -no-feature-sse2) \
		-pkg-config \
		-system-zlib \
		-system-pcre \
		-glib \
		-nomake tests -nomake examples \
		-make libs \
		-make tools \
		-no-compile-examples \
		-verbose \
		-no-cups -no-tslib \
		-no-pch \
		-no-ltcg \
		$(tc-ld-is-gold && echo -use-gold-linker || echo -no-use-gold-linker) \
		-qreal double \
		-no-egl \
		-system-proxies \
		-no-warnings-are-errors \
		-feature-network -feature-translation \
		-widgets -gui \
		"
	#		 -widgets -gui -core -network -multimedia -dbus -translation \
	#		 "
	$CONFIGURE_CMD || die

	BUILD_INCLUDE_DIRS="-I./qtbase/src/corelib/global -I./qtbase/include/QtCore -I./qtbase/src/corelib"
	emake_nested() {
		CC="$(tc-getCC)" CXX="$(tc-getCXX)" CPPFLAGS="$CXXFLAGS ${BUILD_INCLUDE_DIRS}" CFLAGS="$CFLAGS ${BUILD_INCLUDE_DIRS}" CXXFLAGS="$CXXFLAGS ${BUILD_INCLUDE_DIRS}" LDFLAGS="$LDFLAGS" \
		QMAKE_AR="$(tc-getAR)" \
		QMAKE_CC="$(tc-getCC)" \
		QMAKE_LINK_C="$(tc-getCC)" \
		QMAKE_LINK_C_SHLIB="$(tc-getCC)" \
		QMAKE_CXX="$(tc-getCXX)" \
		QMAKE_LINK="$(tc-getCXX)" \
		QMAKE_LINK_SHLIB="$(tc-getCXX)" \
		QMAKE_OBJCOPY="$(tc-getOBJCOPY)" \
		QMAKE_RANLIB= \
		QMAKE_STRIP="$(tc-getSTRIP)" \
		QMAKE_CFLAGS="${CFLAGS}" \
		QMAKE_CFLAGS_RELEASE= \
		QMAKE_CFLAGS_DEBUG= \
		QMAKE_CXXFLAGS="${CXXFLAGS}" \
		QMAKE_CXXFLAGS_RELEASE= \
		QMAKE_CXXFLAGS_DEBUG= \
		QMAKE_LFLAGS=\"${LDFLAGS}\" \
		QMAKE_LFLAGS_RELEASE= \
		QMAKE_LFLAGS_DEBUG= \
			gmake $MAKEOPTS "$@"
	}
	cp ./qtbase/src/corelib/global/qconfig.h ./qtbase/include/QtCore/qconfig.h || die
	cp ./qtbase/src/corelib/qtcore-config.h ./qtbase/include/QtCore/qtcore-config.h || die
	mkdir -p ./qtbase/include/QtCore/private
	cp ./qtbase/src/corelib/global/qconfig_p.h ./qtbase/include/QtCore/private/qconfig_p.h || die
	cp ./qtbase/src/corelib/qtcore-config_p.h ./qtbase/include/QtCore/private/qtcore-config_p.h || die

	#Fails when only run once, weird bug.
	#This can probably be fixed more efficiently, but I don't have the time to spend to
	#figure out a better fix.
	for _ in 1 2; do
		emake_nested || die
	done

	emake_nested install DESTDIR=./out || die

	cd "$S" || die

}

src_configure() {

	flto_addition='-flto'
	[[ "$CC" == *gcc* ]] && flto_addition='-flto=7'
	if use lto; then
		export CFLAGS="${CFLAGS} $flto_addition"
		export LDFLAGS="${LDFLAGS} -Wl,-flto $flto_addition"
		export CXXFLAGS="${CXXFLAGS} $flto_addition"
		export CPPFLAGS="$CXXFLAGS"
	fi

	if use static; then
		export LDFLAGS="${LDFLAGS} -static-pie -static-libgcc"
		export CFLAGS="${CFLAGS} -fpie"
		export CXXFLAGS="${CXXFLAGS} -fpie"
		export CPPFLAGS="$CXXFLAGS"
	fi

	use bundled-qt && [ ! -d "${S}/externals/qt5/build/out" ] && compile_qt

	local -a mycmakeargs=(
		# Libraries are private and rely on circular dependency resolution.
		-DBUILD_SHARED_LIBS=$(usev static OFF && usex shared-libs ON OFF) # dynarmic
		-DCMAKE_CXX_FLAGS="$CXXFLAGS"
		-DCMAKE_CXX_COMPILER="$CXX"
		-DCMAKE_C_COMPILER="$CC"
		-DCMAKE_EXE_LINKER_FLAGS="$LDFLAGS"
		-DCMAKE_MODULE_LINKER_FLAGS="$LDFLAGS"
		-DCMAKE_SHARED_LINKER_FLAGS="$LDFLAGS"
		-DLD_FLAGS="$LDFLAGS"
		-DCMAKE_LD_FLAGS="$LDFLAGS"
		-DENABLE_COMPATIBILITY_LIST_DOWNLOAD=$(usex compatibility-list)
		-DENABLE_CUBEB=$(usex cubeb ON OFF)
		-DENABLE_LIBUSB=ON
		-DENABLE_QT=$(usev qt5 ON || usev qt6 ON || usev bundled-qt ON || echo OFF)
		-DENABLE_QT_TRANSLATION=$(usev qt5 ON || usev qt6 ON || usev bundled-qt ON || echo OFF)
		-DENABLE_OPENGL=$(usex opengl ON OFF)
		-DENABLE_QT6=$(usex qt6)
		-DENABLE_SDL2=$(usev sdl ON || usev bundled-sdl ON || echo OFF)
		-DENABLE_WEB_SERVICE=$(usex webservice)
		-DSIRIT_USE_SYSTEM_SPIRV_HEADERS=$(usex system-spirv yes no)
		-DYUZU_USE_EXTERNAL_VULKAN_SPIRV_TOOLS=$(usex system-spirv no yes)
		-DUSE_DISCORD_PRESENCE=$(usex discord)
		-DYUZU_TESTS=$(usex test)
		-DYUZU_USE_EXTERNAL_VULKAN_HEADERS=$(usex system-vulkan no yes)
		-DYUZU_USE_EXTERNAL_VULKAN_UTILITY_LIBRARIES=$(usex system-vulkan no yes)
		-DYUZU_USE_EXTERNAL_SDL2=$(usex bundled-sdl ON OFF)
		#		-DYUZU_USE_BUNDLED_SDL2=$(usex bundled-sdl ON OFF)
		-DYUZU_USE_BUNDLED_FFMPEG=$(usex system-ffmpeg OFF ON)
		-DYUZU_USE_BUNDLED_QT=OFF
		-DYUZU_ENABLE_LTO=$(usex lto ON OFF)
		-DYUZU_USE_QT_WEB_ENGINE=$(usex webengine)
		-DYUZU_USE_FASTER_LD=no
		-DYUZU_CMD=ON
		-DYUZU_ROOM=$(usex static OFF ON)
		-DYUZU_ENABLE_PORTABLE=ON
		-DSDL_STATIC=$(usex static ON OFF)
		-DSDL_STATIC_PIC=$(usex static ON OFF)
		-DFFmpeg_COMPONENTS="swscale;avutil;avfilter;avcodec" #This and the following should not be used unless bundled is enabled, so should not present an issue otherwise to just add regardless.
		-DFFmpeg_PREFIX="${S}/externals/ffmpeg/ffmpeg"
		-DSPIRV-Headers_SOURCE_DIR="${S}/externals/SPIRV-Headers"
	)

	use bundled-qt && mycmakeargs+=(-DQt5_ROOT="${S}/externals/qt5/build/out")
	if use static || use prefer-static-libs; then
		mycmakeargs+=(-DCMAKE_FIND_LIBRARY_SUFFIXES=".a")
	fi
	#		-DYUZU_USE_EXTERNAL_VULKAN_MEMORY_ALLOCATOR=$(usex system-vulkan no yes)

	cmake_src_configure

	# This would be better in src_unpack but it would be unlinked
	if use compatibility-list; then
		#mv "${S}"/compatibility_list.json "${BUILD_DIR}"/dist/compatibility_list/ || die
		xz --decompress --stdout "${FILESDIR}/gamedb.xz" >"${BUILD_DIR}"/dist/compatibility_list/compatibility_list.json || die
	fi
}
