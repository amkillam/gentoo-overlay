# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DOCS_BUILDER="doxygen"
DOCS_DEPEND="media-gfx/graphviz"
ROCM_SKIP_GLOBALS=1

inherit cmake docs flag-o-matic rocm

DESCRIPTION="C++ Heterogeneous-Compute Interface for Portability"
HOMEPAGE="https://github.com/ROCm/clr"

if [[ ${PV} == *9999 ]]; then
	EGIT_REPO_URI=https://github.com/ROCm/clr.git
	HIP_REPO_URI=https://github.com/ROCm/HIP.git
	inherit git-r3
else
	SRC_URI="https://github.com/ROCm/clr/archive/refs/tags/rocm-${PV}.tar.gz -> rocm-clr-${PV}.tar.gz
	https://github.com/ROCm/HIP/archive/refs/tags/rocm-${PV}.tar.gz -> hip-${PV}.tar.gz
	test? ( https://github.com/ROCm/hip-tests/archive/refs/tags/rocm-${PV}.tar.gz )"
fi

KEYWORDS="~amd64"
LICENSE="MIT"
SLOT="0/$(ver_cut 1-2)"

RESTRICT="!test? ( test )"
IUSE="debug test"

DEPEND="
	dev-util/hipcc
	>=dev-util/rocminfo-5
		sys-devel/clang:19
	dev-libs/rocm-comgr:${SLOT}
	dev-libs/rocr-runtime:${SLOT}
	x11-base/xorg-proto
	virtual/opengl
"
RDEPEND="${DEPEND}
	dev-perl/URI-Encode
	sys-devel/clang-runtime:=
	>=dev-libs/roct-thunk-interface-9999"

S="${WORKDIR}/rocm-clr-${PV}/"

PATCHES=(
	${FILESDIR}/rocm-opencl-runtime-9999-no-hsa-contiguous-mem-flags.patch
)

hip_test_wrapper() {
	local S="${WORKDIR}/hip-tests-rocm-${TEST_PV}/catch"
	local CMAKE_USE_DIR="${S}"
	local BUILD_DIR="${S}_build"
	cd "${S}" || die
	$@
}

src_unpack() {
	if [[ "${PV}" == *9999 ]]; then
		git-r3_fetch "$HIP_REPO_URI"
		git-r3_checkout "$HIP_REPO_URI" "hip-${PV}"
		git-r3_fetch "$EGIT_REPO_URI"
		git-r3_checkout "$EGIT_REPO_URI" "rocm-clr-${PV}"
	else
		default
	fi

}

get_llvm_prefix() {
	echo /usr/lib/llvm/19
}

src_prepare() {

	# Set HIP and HIP Clang paths directly, don't search using heuristics
	sed -e "s:# Search for HIP installation:set(HIP_ROOT_DIR \"${EPREFIX}/usr\"):" \
		-e "s:#Set HIP_CLANG_PATH:set(HIP_CLANG_PATH \"$(get_llvm_prefix -d)/bin\"):" \
		-i "${WORKDIR}"/hip-${PV}/cmake/FindHIP.cmake || die

	# https://github.com/ROCm/HIP/commit/405d029422ba8bb6be5a233d5eebedd2ad2e8bd3
	# https://github.com/ROCm/clr/commit/ab6d34ae773f4d151e04170c0f4e46c1135ddf3e
	# Migrated to hip-test, but somehow the change is not applied to the tarball.
	rm -rf "${WORKDIR}"/hip-${PV}/tests || die
	sed -e '/tests.*cmake/d' -i hipamd/CMakeLists.txt || die

	cmake_src_prepare

	if use test; then
		PATCHES=${FILESDIR}/hip-test-5.7.0-rocm_agent_enumerator-location.patch \
			hip_test_wrapper cmake_src_prepare
	fi
}

src_configure() {
	# -Werror=strict-aliasing
	# https://bugs.gentoo.org/858383
	# https://github.com/ROCm/clr/issues/64
	#
	# Do not trust it for LTO either
	append-flags -fno-strict-aliasing
	filter-lto

	use debug && CMAKE_BUILD_TYPE="Debug"

	# Fix ld.lld linker error: https://github.com/ROCm/HIP/issues/3382
	# See also: https://github.com/gentoo/gentoo/pull/29097
	append-ldflags $(test-flags-CCLD -Wl,--undefined-version)

	local mycmakeargs=(
		-DCMAKE_PREFIX_PATH="$(get_llvm_prefix)"
		-DHIP_ENABLE_ROCPROFILER_REGISTER=OFF
		-DCMAKE_BUILD_TYPE=${buildtype}
		-DCMAKE_SKIP_RPATH=ON
		-DHIP_PLATFORM=amd
		-DHIP_COMMON_DIR="${WORKDIR}/hip-${PV}"
		-DROCM_PATH="${EPREFIX}/usr"
		-DUSE_PROF_API=0
		-DFILE_REORG_BACKWARD_COMPATIBILITY=OFF
		-DCLR_BUILD_HIP=ON
		-DHIPCC_BIN_DIR="${EPREFIX}/usr/bin"
		-DOpenGL_GL_PREFERENCE="GLVND"
	)

	cmake_src_configure

	if use test; then
		local mycmakeargs=(
			-DROCM_PATH="${BUILD_DIR}"/hipamd
			-DHIP_PLATFORM=amd
		)
		hip_test_wrapper cmake_src_configure
	fi
}

src_compile() {
	cmake_src_compile

	if use test; then
		HIP_PATH="${BUILD_DIR}"/hipamd \
			hip_test_wrapper cmake_src_compile build_tests
	fi
}

src_test() {
	check_amdgpu
	export LD_LIBRARY_PATH="${BUILD_DIR}/hipamd/lib"

	# TODO: research how to test Vulkan-related features.
	local CMAKE_SKIP_TESTS=(
		Unit_hipExternalMemoryGetMappedBuffer_Vulkan_Positive_Read_Write
		Unit_hipExternalMemoryGetMappedBuffer_Vulkan_Negative_Parameters
		Unit_hipImportExternalMemory_Vulkan_Negative_Parameters
		Unit_hipWaitExternalSemaphoresAsync_Vulkan_Positive_Binary_Semaphore
		Unit_hipWaitExternalSemaphoresAsync_Vulkan_Positive_Multiple_Semaphores
		Unit_hipWaitExternalSemaphoresAsync_Vulkan_Negative_Parameters
		Unit_hipSignalExternalSemaphoresAsync_Vulkan_Positive_Binary_Semaphore
		Unit_hipSignalExternalSemaphoresAsync_Vulkan_Positive_Multiple_Semaphores
		Unit_hipSignalExternalSemaphoresAsync_Vulkan_Negative_Parameters
		Unit_hipImportExternalSemaphore_Vulkan_Negative_Parameters
		Unit_hipDestroyExternalSemaphore_Vulkan_Negative_Parameters
	)

	MAKEOPTS="-j1" hip_test_wrapper cmake_src_test
}

src_install() {
	cmake_src_install

	# add version file that is required by some libraries
	mkdir "${ED}"/usr/include/rocm-core || die
	cat <<EOF >"${ED}"/usr/include/rocm-core/rocm_version.h || die
#pragma once
#define ROCM_VERSION_MAJOR $(ver_cut 1)
#define ROCM_VERSION_MINOR $(ver_cut 2)
#define ROCM_VERSION_PATCH $(ver_cut 3)
#define ROCM_BUILD_INFO "$(ver_cut 1-3).0-9999-unknown"
EOF
	dosym -r /usr/include/rocm-core/rocm_version.h /usr/include/rocm_version.h

	# files already installed by hipcc, which is a build dep
	rm "${ED}/usr/bin/hipconfig.pl" || die
	rm "${ED}/usr/bin/hipcc.pl" || die
	rm "${ED}/usr/bin/hipcc" || die
	rm "${ED}/usr/bin/hipcc.bin" || die
	rm "${ED}/usr/bin/hipconfig" || die
	rm "${ED}/usr/bin/hipconfig.bin" || die
	rm "${ED}/usr/bin/hipvars.pm" || die
}
