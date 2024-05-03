# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3

DESCRIPTION="Fast and secure initramfs generator"
HOMEPAGE="https://github.com/anatol/booster/"
EGIT_REPO_URI="https://github.com/anatol/booster/"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="dev-lang/go app-text/ronn-ng"
RDEPEND="${DEPEND}"
BDEPEND=""
