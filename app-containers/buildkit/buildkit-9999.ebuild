# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
EGO_PN=github.com/moby/buildkit
MY_PV=${PV/_/-}
inherit golang-vcs-snapshot linux-info optfeature systemd udev git-r3 go-module

DESCRIPTION="The core functions you need to create buildkit images and run buildkit containers"
HOMEPAGE="https://www.docker.com/"
EGIT_REPO_URI="https://github.com/moby/buildkit.git"
#SRC_URI="${PN}-${PV}-deps.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~ppc64 ~riscv ~x86"
IUSE="apparmor btrfs +container-init +overlay2 seccomp selinux systemd"

DEPEND="
	>=dev-db/sqlite-3.7.9:3
	apparmor? ( sys-libs/libapparmor )
	btrfs? ( >=sys-fs/btrfs-progs-3.16.1 )
	seccomp? ( >=sys-libs/libseccomp-2.2.1 )
	systemd? ( sys-apps/systemd )
"

# https://github.com/moby/moby/blob/master/project/PACKAGERS.md#runtime-dependencies
# https://github.com/moby/moby/blob/master/project/PACKAGERS.md#optional-dependencies
RDEPEND="
	${DEPEND}
	>=net-firewall/iptables-1.4
	sys-process/procps
	>=dev-vcs/git-1.7
	>=app-arch/xz-utils-4.9
	>=app-containers/containerd-1.7.21[apparmor?,btrfs?,seccomp?]
	>=app-containers/runc-1.1.13[apparmor?,seccomp?]
	!app-containers/docker-proxy
	container-init? ( >=sys-process/tini-0.19.0[static] )
	selinux? ( sec-policy/selinux-docker )
"

# https://github.com/docker/docker/blob/master/project/PACKAGERS.md#build-dependencies
BDEPEND="
	>=dev-lang/go-1.16.12
	dev-go/go-md2man
	virtual/pkgconfig
"
# tests require running dockerd as root and downloading containers
RESTRICT="installsources strip test"

S="${WORKDIR}/${P}"

pkg_setup() {
	# this is based on "contrib/check-config.sh" from upstream's sources
	# required features.
	CONFIG_CHECK="
		~NAMESPACES ~NET_NS ~PID_NS ~IPC_NS ~UTS_NS
		~CGROUPS ~CGROUP_CPUACCT ~CGROUP_DEVICE ~CGROUP_FREEZER ~CGROUP_SCHED ~CPUSETS ~MEMCG
		~KEYS
		~VETH ~BRIDGE ~BRIDGE_NETFILTER
		~IP_NF_FILTER ~IP_NF_TARGET_MASQUERADE
		~NETFILTER_XT_MATCH_ADDRTYPE
		~NETFILTER_XT_MATCH_CONNTRACK
		~NETFILTER_XT_MATCH_IPVS
		~NETFILTER_XT_MARK
		~IP_NF_NAT ~NF_NAT
		~POSIX_MQUEUE
	"
	WARNING_POSIX_MQUEUE="CONFIG_POSIX_MQUEUE: is required for bind-mounting /dev/mqueue into containers"

	# optional features
	CONFIG_CHECK+="
		~USER_NS
	"

	if use seccomp; then
		CONFIG_CHECK+="
			~SECCOMP ~SECCOMP_FILTER
		"
	fi

	CONFIG_CHECK+="
		~CGROUP_PIDS
	"

	if kernel_is lt 6 1; then
		CONFIG_CHECK+="
			~MEMCG_SWAP
			"
	fi

	if kernel_is le 5 8; then
		CONFIG_CHECK+="
			~MEMCG_SWAP_ENABLED
		"
	fi

	CONFIG_CHECK+="
		~!LEGACY_VSYSCALL_NATIVE
		"
	if kernel_is lt 5 19; then
		CONFIG_CHECK+="
			~LEGACY_VSYSCALL_EMULATE
			"
	fi
	CONFIG_CHECK+="
		~!LEGACY_VSYSCALL_NONE
		"
	WARNING_LEGACY_VSYSCALL_NONE="CONFIG_LEGACY_VSYSCALL_NONE enabled: \
		Containers with <=glibc-2.13 will not work"

	if kernel_is le 4 5; then
		CONFIG_CHECK+="
			~MEMCG_KMEM
		"
	fi

	if kernel_is lt 5; then
		CONFIG_CHECK+="
			~IOSCHED_CFQ ~CFQ_GROUP_IOSCHED
		"
	fi

	CONFIG_CHECK+="
		~BLK_CGROUP ~BLK_DEV_THROTTLING
		~CGROUP_PERF
		~CGROUP_HUGETLB
		~NET_CLS_CGROUP ~CGROUP_NET_PRIO
		~CFS_BANDWIDTH ~FAIR_GROUP_SCHED
		~IP_NF_TARGET_REDIRECT
		~IP_VS
		~IP_VS_NFCT
		~IP_VS_PROTO_TCP
		~IP_VS_PROTO_UDP
		~IP_VS_RR
		"

	if use selinux; then
		CONFIG_CHECK+="
			~SECURITY_SELINUX
			"
	fi

	if use apparmor; then
		CONFIG_CHECK+="
			~SECURITY_APPARMOR
			"
	fi

	# if ! is_set EXT4_USE_FOR_EXT2; then
	#	check_flags EXT3_FS EXT3_FS_XATTR EXT3_FS_POSIX_ACL EXT3_FS_SECURITY
	#	if ! is_set EXT3_FS || ! is_set EXT3_FS_XATTR || ! is_set EXT3_FS_POSIX_ACL || ! is_set EXT3_FS_SECURITY; then
	#		echo "    $(wrap_color '(enable these ext3 configs if you are using ext3 as backing filesystem)' bold black)"
	#	fi
	# fi

	CONFIG_CHECK+="
		~EXT4_FS ~EXT4_FS_POSIX_ACL ~EXT4_FS_SECURITY
	"

	# if ! is_set EXT4_FS || ! is_set EXT4_FS_POSIX_ACL || ! is_set EXT4_FS_SECURITY; then
	#	if is_set EXT4_USE_FOR_EXT2; then
	#		echo "    $(wrap_color 'enable these ext4 configs if you are using ext3 or ext4 as backing filesystem' bold black)"
	#	else
	#		echo "    $(wrap_color 'enable these ext4 configs if you are using ext4 as backing filesystem' bold black)"
	#	fi
	# fi

	# network drivers
	CONFIG_CHECK+="
		~VXLAN ~BRIDGE_VLAN_FILTERING
		~CRYPTO ~CRYPTO_AEAD ~CRYPTO_GCM ~CRYPTO_SEQIV ~CRYPTO_GHASH
		~XFRM ~XFRM_USER ~XFRM_ALGO ~INET_ESP
	"
	if kernel_is le 5 3; then
		CONFIG_CHECK+="
			~INET_XFRM_MODE_TRANSPORT
		"
	fi

	CONFIG_CHECK+="
		~IPVLAN
		"
	CONFIG_CHECK+="
		~MACVLAN ~DUMMY
		"
	CONFIG_CHECK+="
		~NF_NAT_FTP ~NF_CONNTRACK_FTP ~NF_NAT_TFTP ~NF_CONNTRACK_TFTP
	"

	# storage drivers
	if use btrfs; then
		CONFIG_CHECK+="
			~BTRFS_FS
			~BTRFS_FS_POSIX_ACL
		"
	fi

	CONFIG_CHECK+="
		~OVERLAY_FS
	"

	linux-info_pkg_setup
}

src_unpack() {
	git-r3_src_unpack
	go-module_src_unpack
	#	go-module_live_vendor
}

src_compile() {

	for bin in buildctl buildkitd; do
		export GOPATH="${WORKDIR}/${P}/cmd/${bin}"
		export VERSION=${PV}
		tc-export PKG_CONFIG

		# setup CFLAGS and LDFLAGS for separate build target
		# see https://github.com/tianon/docker-overlay/pull/10
		CGO_CFLAGS+=" -I${ESYSROOT}/usr/include"
		CGO_LDFLAGS+=" -L${ESYSROOT}/usr/$(get_libdir)"

		cd "$GOPATH" || die
		ego build || die
	done
}

src_install() {
	for bin in buildctl buildkitd; do
		dobin "cmd/${bin}/${bin}"
	done

	sed -i 's,/usr/local,/usr,g' "${S}/examples/systemd/"*/*.service || die
	sed -i 's,multi-user.target,default.target,g' "${S}/examples/systemd/"*/*.service || die
	sed -i 's,buildkit/rootless,buildkit-default/buildkitd.sock,g' "${S}/examples/systemd/"*/*.service || die

	if use systemd; then
		systemd_newuserunit "${S}/examples/systemd/user/buildkit.service" buildkitd.service
		systemd_douserunit "${S}/examples/systemd/user/buildkit-proxy.service"

		systemd_newunit "${S}/examples/systemd/system/buildkit.service" buildkitd.service
	fi

	dodoc AUTHORS PROJECT.md README.md
	dodoc -r docs/*
}

pkg_postinst() {
	udev_reload

	elog
	elog "To use buildkit, the buildkit daemon must be running as root. To automatically"
	elog "start the buildkit daemon at boot:"
	if systemd_is_booted || has_version sys-apps/systemd; then
		elog "  systemctl --user enable --now buildkitd.service"
	else
		elog "  rc-update add buildkitd default"
	fi
}

pkg_postrm() {
	udev_reload
}
