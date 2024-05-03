EAPI=8
inherit acct-user
DESCRIPTION="A user for dev-util/ollama"
ACCT_USER_ID=243
ACCT_USER_GROUPS=( ollama )
ACCT_USER_SHELL=/bin/false
ACCT_USER_HOME=/usr/share/ollama
acct-user_add_deps
