# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="CU / ROCM agnostic hip FFT implementation"
HOMEPAGE="https://github.com/ROCm/hipFFT"
SRC_URI="https://github.com/ROCm/hipFFT/archive/refs/tags/rocm-${PV}.tar.gz -> hipFFT-rocm-${PV}.tar.gz"

LICENSE="MIT"
KEYWORDS="~amd64"
SLOT="0/$(ver_cut 1-2)"

RESTRICT="test"

RDEPEND="dev-util/hip
	>=sci-libs/rocFFT-${PV}"
DEPEND="${RDEPEND}"

S="${WORKDIR}/hipFFT-rocm-${PV}"

src_configure() {
	local mycmakeargs=(
		-DROCM_SYMLINK_LIBS=OFF
		-DBUILD_CLIENTS_TESTS=OFF
		-DBUILD_CLIENTS_RIDER=OFF
		-DBUILD_FILE_REORG_BACKWARD_COMPATIBILITY=OFF
	)

	cmake_src_configure
}
