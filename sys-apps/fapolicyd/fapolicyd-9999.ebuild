# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
EAPI=8

inherit autotools

DESCRIPTION="File Access Policy Daemon, for application whitelisting"
HOMEPAGE="https://github.com/linux-application-whitelisting/fapolicyd/"

if [[ ${PV} == 9999 ]]; then
		inherit git-r3
		EGIT_REPO_URI="https://github.com/linux-application-whitelisting/fapolicyd.git"
else
	MY_COMMIT=396803ff7a1b935945bfd7fb60d56c5708f8c897
	SRC_URI="https://github.com/kangie/fapolicyd/archive/${MY_COMMIT}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64"
	S="${WORKDIR}/fapolicyd-${MY_COMMIT}"
fi

LICENSE="GPL-3+"
SLOT="0"

BDEPEND="
	dev-libs/openssl:=
	sys-apps/file
	sys-libs/libcap-ng
	sys-libs/libseccomp
	dev-db/lmdb:=
	dev-libs/uthash
"

DEPEND=${BDEPEND}

RDEPEND="
	${BDEPEND}
	acct-user/fapolicyd
	acct-group/fapolicyd
	sys-apps/systemd:=
"

src_prepare() {
	default
	eautoreconf
}

# https://github.com/linux-application-whitelisting/fapolicyd/blob/main/BUILD.md?plain=1
src_configure() {
	econf --with-audit --without-rpm --with-ebuild --disable-shared
}

src_install() {
	keepdir /etc/fapolicyd/rules.d
	default
	keepdir /var/lib/fapolicyd
	fowners -R fapolicyd:fapolicyd /var/lib/fapolicyd
	# the default of 50(MB?) is too small for a reasonably sized portage system.
	sed -i -e 's/db_max_size.*/db_max_size = 100/' "${ED}"/etc/fapolicyd/fapolicyd.conf || die
	sed -i -e 's/rpmdb/ebuilddb/' "${ED}"/etc/fapolicyd/fapolicyd.conf || die

	# whitelist portage (todo: detect this in postinst)
	echo 'allow perm=open exe=/usr/bin/python-exec2c comm=portage : all' \
		>> "${ED}"/etc/fapolicyd/rules.d/21-updaters.rules || die
	fowners -R fapolicyd:fapolicyd /etc/fapolicyd
	# update upstream kernel filter to match gentoo paths
	sed -i -e 's usr/src/kernel\* usr/src/linux\* ' "${ED}"/etc/fapolicyd/fapolicyd-filter.conf || die

}

src_test() {
	emake check
}

pkg_postinst() {
	# These are required substitituons to configure fapolicyd for the deployment environment
	# They would be performed during the rpm build for RHEL packages, but because we're Gentoo
	# and it's entirely possible that the user has a different python version installed, we
	# need to do this at install time.

	# This is used to carve out an exemption for system updaters. `dnf` upstream, portage for us.
	local rulesd
	rulesd="${EROOT}/usr/share/fapolicyd/sample-rules/"

	#local python_path="$(readlink -f /usr/bin/python3 | sed 's/\//\\\\\//g')"
	# drop dnf from system-updaters and whitelist portage instead
	#head -n 3 ${rulesd}/21-updaters.rules > ${rulesd}/21-updaters.rules
	#echo "allow perm=open exe=${python_path} comm=portage : all" >> ${rulesd}/21-updaters.rules || die

	# This detects the run-time linker
	local interpret
	interpret=$(readelf -e /usr/bin/bash \
					| grep Requesting \
					| sed 's/.$//' \
					| rev | cut -d" " -f1 \
					| rev)
	head -n 3 ${rulesd}/43-known-elf.rules > ${rulesd}/43-known-elf.rules
	echo "allow perm=execute all : path=${interpret} trust=1" >> ${rulesd}/43-known-elf.rules || die
	ewarn "hic sunt dracones"
	ewarn "This is incredibly experimental."
	ewarn "Only use \`/usr/sbin/fapolicyd --permissive --debug\`"
}
