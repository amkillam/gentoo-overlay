# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
TS_BINDINGS=(python)

inherit tree-sitter-grammar

MY_PN=tree-sitter-markdown
MY_P=${MY_PN}-${PV}

DESCRIPTION="Markdown-inline grammar for Tree-sitter"
HOMEPAGE="https://github.com/tree-sitter-grammars/tree-sitter-markdown"
SRC_URI="https://github.com/tree-sitter-grammars/${MY_PN}/archive/v${PV}.tar.gz -> ${MY_P}.tar.gz"
S="${WORKDIR}"/${MY_P}/${MY_PN}-inline

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64"

# Running the tests requires extensions to be enabled, but the parser
# generated by upstream does not include the extensions.
# https://github.com/tree-sitter-grammars/tree-sitter-markdown/issues/136
RESTRICT="test"

src_prepare() {
  tree-sitter-grammar_src_prepare
  cp "${WORKDIR}"/${MY_P}/pyproject.toml ${S}/src/
}
