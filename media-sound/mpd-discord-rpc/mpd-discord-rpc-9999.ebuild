EAPI=8

inherit cargo

if [[ "${PV}" != *9999 ]]; then
CRATES="
	addr2line@0.20.0
	adler@1.0.2
	ahash@0.8.11
	aho-corasick@1.0.2
	autocfg@1.1.0
	backtrace@0.3.68
	base64@0.21.0
	bitflags@1.3.2
	bitflags@2.4.2
	bumpalo@3.12.0
	byteorder@1.5.0
	bytes@1.5.0
	cc@1.0.79
	cfg-if@1.0.0
	core-foundation@0.9.3
	core-foundation-sys@0.8.3
	crossbeam-channel@0.5.8
	crossbeam-utils@0.8.16
	dirs@5.0.1
	dirs-sys@0.4.1
	discord-presence@1.1.1
	encoding_rs@0.8.32
	equivalent@1.0.0
	errno@0.2.8
	errno-dragonfly@0.1.2
	fastrand@1.9.0
	fnv@1.0.7
	foreign-types@0.3.2
	foreign-types-shared@0.1.1
	form_urlencoded@1.1.0
	futures@0.3.30
	futures-channel@0.3.30
	futures-core@0.3.30
	futures-executor@0.3.30
	futures-io@0.3.30
	futures-macro@0.3.30
	futures-sink@0.3.30
	futures-task@0.3.30
	futures-util@0.3.30
	getrandom@0.2.8
	gimli@0.27.3
	h2@0.3.16
	hashbrown@0.12.3
	hashbrown@0.14.0
	hermit-abi@0.2.6
	hermit-abi@0.3.1
	http@0.2.9
	http-body@0.4.5
	httparse@1.8.0
	httpdate@1.0.2
	hyper@0.14.25
	hyper-tls@0.5.0
	idna@0.3.0
	indexmap@1.9.2
	indexmap@2.0.0
	instant@0.1.12
	io-lifetimes@1.0.9
	ipnet@2.7.1
	itoa@1.0.6
	js-sys@0.3.61
	lazy_static@1.4.0
	libc@0.2.150
	linux-raw-sys@0.1.4
	lock_api@0.4.10
	log@0.4.17
	memchr@2.6.3
	mime@0.3.17
	minimal-lexical@0.2.1
	miniz_oxide@0.7.1
	mio@0.8.9
	mpd-utils@0.2.0
	mpd_client@1.4.1
	mpd_protocol@1.0.3
	named_pipe@0.4.1
	native-tls@0.2.11
	nix@0.27.1
	nom@7.1.3
	nu-ansi-term@0.46.0
	num-derive@0.4.0
	num-traits@0.2.15
	num_cpus@1.15.0
	object@0.31.1
	once_cell@1.19.0
	openssl@0.10.47
	openssl-macros@0.1.0
	openssl-probe@0.1.5
	openssl-sys@0.9.82
	option-ext@0.2.0
	overload@0.1.1
	parking_lot@0.12.1
	parking_lot_core@0.9.8
	paste@1.0.14
	percent-encoding@2.2.0
	pin-project-lite@0.2.12
	pin-utils@0.1.0
	pkg-config@0.3.26
	proc-macro-crate@1.3.1
	proc-macro-error@1.0.4
	proc-macro-error-attr@1.0.4
	proc-macro2@1.0.76
	quork@0.6.2
	quork-proc@0.3.0
	quote@1.0.35
	redox_syscall@0.2.16
	redox_syscall@0.3.5
	redox_users@0.4.3
	regex@1.10.3
	regex-automata@0.4.4
	regex-syntax@0.8.2
	reqwest@0.11.26
	rustc-demangle@0.1.23
	rustix@0.36.11
	rustls-pemfile@1.0.4
	ryu@1.0.13
	schannel@0.1.21
	scopeguard@1.1.0
	security-framework@2.8.2
	security-framework-sys@2.8.0
	serde@1.0.197
	serde_derive@1.0.197
	serde_json@1.0.114
	serde_spanned@0.6.5
	serde_urlencoded@0.7.1
	sharded-slab@0.1.4
	slab@0.4.8
	smallvec@1.10.0
	socket2@0.4.9
	socket2@0.5.5
	syn@1.0.109
	syn@2.0.48
	sync_wrapper@0.1.2
	system-configuration@0.5.1
	system-configuration-sys@0.5.0
	tempfile@3.4.0
	thiserror@1.0.58
	thiserror-impl@1.0.58
	thread_local@1.1.7
	tinyvec@1.6.0
	tinyvec_macros@0.1.1
	tokio@1.36.0
	tokio-macros@2.2.0
	tokio-native-tls@0.3.1
	tokio-util@0.7.7
	toml@0.7.8
	toml@0.8.11
	toml_datetime@0.6.5
	toml_edit@0.19.15
	toml_edit@0.22.7
	tower-service@0.3.2
	tracing@0.1.40
	tracing-attributes@0.1.27
	tracing-core@0.1.32
	tracing-log@0.2.0
	tracing-subscriber@0.3.18
	try-lock@0.2.4
	unicode-bidi@0.3.13
	unicode-ident@1.0.8
	unicode-normalization@0.1.22
	universal-config@0.4.3
	url@2.3.1
	uuid@1.7.0
	valuable@0.1.0
	vcpkg@0.2.15
	version_check@0.9.4
	want@0.3.0
	wasi@0.11.0+wasi-snapshot-preview1
	wasm-bindgen@0.2.84
	wasm-bindgen-backend@0.2.84
	wasm-bindgen-futures@0.4.34
	wasm-bindgen-macro@0.2.84
	wasm-bindgen-macro-support@0.2.84
	wasm-bindgen-shared@0.2.84
	web-sys@0.3.61
	winapi@0.3.9
	winapi-i686-pc-windows-gnu@0.4.0
	winapi-x86_64-pc-windows-gnu@0.4.0
	windows@0.51.1
	windows-core@0.51.1
	windows-sys@0.42.0
	windows-sys@0.45.0
	windows-sys@0.48.0
	windows-targets@0.42.2
	windows-targets@0.48.5
	windows_aarch64_gnullvm@0.42.2
	windows_aarch64_gnullvm@0.48.5
	windows_aarch64_msvc@0.42.2
	windows_aarch64_msvc@0.48.5
	windows_i686_gnu@0.42.2
	windows_i686_gnu@0.48.5
	windows_i686_msvc@0.42.2
	windows_i686_msvc@0.48.5
	windows_x86_64_gnu@0.42.2
	windows_x86_64_gnu@0.48.5
	windows_x86_64_gnullvm@0.42.2
	windows_x86_64_gnullvm@0.48.5
	windows_x86_64_msvc@0.42.2
	windows_x86_64_msvc@0.48.5
	winnow@0.5.15
	winnow@0.6.5
	winreg@0.50.0
	zerocopy@0.7.32
	zerocopy-derive@0.7.32
"
	fi

DESCRIPTION="Displays the playing song/album/artist from MPD in Discord using Rich Presence."
# Double check the homepage as the cargo_metadata crate
# does not provide this value so instead repository is used
HOMEPAGE="https://github.com/JakeStanger/mpd-discord-rpc"
if [[ "${PV}" == *9999 ]]; then
    inherit git-r3
		EGIT_REPO_URI="https://github.com/JakeStanger/mpd-discord-rpc.git"
else
	RESTRICT="network-sandbox"
SRC_URI="
	$(cargo_crate_uris)
	https://github.com/JakeStanger/mpd-discord-rpc/archive/v${PV}.tar.gz -> ${P}.tar.gz
"
    KEYWORDS="~amd64 ~x86"
fi


# License set may be more restrictive as OR is not respected
# use cargo-license for a more accurate license picture
LICENSE="Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD BSD-2 Boost-1.0 ISC MIT Unicode-DFS-2016 Unlicense ZLIB"
SLOT="0"
KEYWORDS="~amd64"

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=""

# rust does not use *FLAGS from make.conf, silence portage warning
# update with proper path to binaries this crate installs, omit leading /
QA_FLAGS_IGNORED="usr/bin/${PN}"
S="${WORKDIR}/${P}"

src_unpack() {
	if [[ "${PV}" == *9999 ]]; then
		git-r3_src_unpack
		cargo_live_src_unpack
	else 
    cargo_src_unpack
  fi
}

src_install() {
	if [ ! -d "/etc/systemd/system" ]; then
		 dodir "/etc/systemd/system"
	fi

	insinto "/etc/systemd/system"
	newins ${S}/mpd-discord-rpc.service mpd-discord-rpc.service

	cargo_src_install
}
