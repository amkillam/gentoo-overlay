EAPI=8
inherit acct-user
DESCRIPTION="A user for www-client/rqbit"
ACCT_USER_ID=244
ACCT_USER_GROUPS=(rqbit)
ACCT_USER_SHELL=/bin/false
ACCT_USER_HOME=/usr/share/rqbit
acct-user_add_deps
