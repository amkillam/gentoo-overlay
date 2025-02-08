# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake git-r3

MO_PV="mo1"
DESCRIPTION="MoneroOcean fork of xmrig that supports algo switching"
HOMEPAGE="https://github.com/MoneroOcean/xmrig"
EGIT_REPO_URI="https://github.com/MoneroOcean/xmrig.git"

LICENSE="Apache-2.0 GPL-3+ MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

IUSE="cpu_flags_x86_sse4_1 donate hwloc opencl strict_cache +ssl cnlite cnheavy cnpico cnfemto cngpu vaes randomx argon2 kawpow ghostrider msr cuda asm nvml adl dmi secure_jit static http debug"
REQUIRED_USE="nvml? ( cuda ) adl? ( opencl ) ssl? ( http )"

DEPEND="
	dev-libs/libuv:=
	hwloc? ( >=sys-apps/hwloc-2.5.0:= )
	opencl? ( virtual/opencl )
	ssl? ( dev-libs/openssl:= )
"

RDEPEND="
	${DEPEND}
	!arm64? ( sys-apps/msr-tools )
"

src_prepare() {
	if ! use donate; then
		sed -i 's/1;/0;/g' src/donate.h || die
	fi

	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DWITH_SSE4_1=$(usex cpu_flags_x86_sse4_1)
		-DWITH_HWLOC=$(usex hwloc)
		-DWITH_TLS=$(usex ssl)
		-DWITH_OPENCL=$(usex opencl)
		-DWITH_STRICT_CACHE=$(usex opencl $(usex strict_cache) off)
		-DWITH_CUDA=$(usex cuda)
		-DWITH_ASM=$(usex asm)
		-DWITH_NVML=$(usex cuda $(usex nvml) off)
		-DWITH_ADL=$(usex opencl $(usex adl) off)
		-DWITH_DMI=$(usex dmi)
		-DWITH_SECURE_JIT=$(usex secure_jit)
		-DBUILD_STATIC=$(usex static)
		-DWITH_CN_LITE=$(usex cnlite)
		-DWITH_CN_HEAVY=$(usex cnheavy)
		-DWITH_CN_PICO=$(usex cnpico)
		-DWITH_CN_FEMTO=$(usex cnfemto)
		-DWITH_CN_GPU=$(usex cngpu)
		-DWITH_RANDOMX=$(usex randomx)
		-DWITH_ARGON2=$(usex argon2)
		-DWITH_KAWPOW=$(usex kawpow)
		-DWITH_GHOSTRIDER=$(usex ghostrider)
		-DWITH_VAES=$(usex vaes)
		-DWITH_MSR=$(usex msr)
		-DWITH_HTTP=$(usex http)
		-DHWLOCK_DEBUG=$(usex debug)
		-DWITH_DEBUG_LOG=$(usex debug)

	)

	cmake_src_configure
}

src_install() {
	default
	newbin "${BUILD_DIR}/xmrig" xmrig-mo
}
