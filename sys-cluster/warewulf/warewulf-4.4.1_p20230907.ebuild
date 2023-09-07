# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit bash-completion-r1 go-module systemd

DESCRIPTION="A stateless cluster node management tool"
HOMEPAGE="https://warewulf.org/"

if [[ ${PV} == 9999 ]] ; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/hpcng/warewulf"
	EGIT_BRANCH="development"
else
	MY_COMMIT=791159c92682838f8eb28f12679a1ae5507d08fb
	SRC_URI="https://github.com/hpcng/warewulf/archive/${MY_COMMIT}.tar.gz -> ${P}.tar.gz
		https://deps.gentoo.zip/${P}-vendor.tar.xz"
	KEYWORDS="~amd64"
	S="${WORKDIR}/${PN}-${MY_COMMIT}"
fi

LICENSE="Apache-2.0 BSD BSD-2 MIT"
SLOT="0"
IUSE="firewalld"

# https://warewulf.org/docs/development/contents/installation.html#runtime-dependencies
RDEPEND="
	net-misc/dhcp
	net-ftp/atftp
	net-fs/nfs-utils
	firewalld? ( net-firewall/firewalld )
"

BDEPEND="
	>=dev-lang/go-1.17
"

src_compile() {
	# WWCLIENTDIR is an odd one out; it's a path relative to $WWOVERLAYDIR.
	# These variables immediately get fed into a giant sed command in the Makefile.
	# We probably don't need to specify _everything_, but it doesn't hurt.
	local myconf=(
		OFFLINE_BUILD=1
		VERSION="${PV}"
		PREFIX="${EPREFIX}"
		BINDIR="${EPREFIX}"/usr/bin
		SYSCONFDIR="${EPREFIX}"/etc
		SRVDIR="${EPREFIX}"/srv
		DATADIR="${EPREFIX}"/usr/share
		MANDIR="${EPREFIX}"/usr/share/man
		DOCDIR="${EPREFIX}"/usr/share/doc
		LOCALSTATEDIR="${EPREFIX}"/var
		TFTPDIR="${EPREFIX}"/var/lib/tftpboot
		FIREWALLDDIR="${EPREFIX}"/usr/lib/firewalld/services
		SYSTEMDDIR="${EPREFIX}"/usr/lib/systemd/system
		BASHCOMPDIR="${EPREFIX}"/etc/bash_completion.d
		WWCLIENTDIR=/warewulf
		WWCONFIGDIR="${EPREFIX}"/etc/warewulf
		WWPROVISIONDIR="${EPREFIX}"/srv/warewulf
		WWOVERLAYDIR="${EPREFIX}"/var/warewulf/overlays
		WWCHROOTDIR="${EPREFIX}"/var/warewulf/chroots
		WWTFTPDIR="${EPREFIX}"/var/lib/tftpboot/warewulf
		WWDOCDIR="${EPREFIX}"/usr/share/doc/warewulf
		WWDATADIR="${EPREFIX}"/usr/share/warewulf
	)
	emake ${myconf[@]} all || die
}

src_test() {
	ego test -v ./...
}

src_install() {
	# This is basically just `make install` with hard-coded Gentoo paths; I consistently hit a race condition with -j32.
	# We could just call make install with -j1, but that's not very Gentoo-like and I'd already written this
	# before I identified the root cause of my 'afternoon of make hell'.

	insinto /etc/warewulf
	for config in warewulf nodes wwapic wwapid wwapird defaults; do
		doins etc/${config}.conf
	done
	doins -r etc/examples
	doins -r etc/ipxe

	insinto /usr/bin
	for bin in wwctl wwapic wwapid wwapird; do
		dobin ${bin}
	done
	exeinto /var/warewulf/overlays/wwinit/warewulf
	doexe wwclient

	dobashcomp etc/bash_completion.d/wwctl

	local WWOVERLAYDIR="/var/warewulf/overlays"
	insinto ${WWOVERLAYDIR}
	for overlay in debug generic host wwinit; do
		doins -r overlays/${overlay}
	done

	fperms 0755 ${WWOVERLAYDIR}/wwinit/init
	fperms 0755 ${WWOVERLAYDIR}/wwinit/warewulf/wwinit
	fperms 0600 ${WWOVERLAYDIR}/wwinit/etc/NetworkManager/system-connections/ww4-managed.ww
	fperms 0600 ${WWOVERLAYDIR}/wwinit/warewulf/config.ww
	fperms 0750 ${WWOVERLAYDIR}/host

	for key in ssh_host_dsa_key ssh_host_ecdsa_key ssh_host_ed25519_key ssh_host_rsa_key; do
		fperms 0600 /${WWOVERLAYDIR}/wwinit/etc/ssh/${key}.ww
		fperms 0644 /${WWOVERLAYDIR}/wwinit/etc/ssh/${key}.pub.ww
	done

	if use firewalld; then
		insinto /usr/lib/firewalld/services
		doins include/firewalld/warewulf.xml
		fperms 0644 /usr/lib/firewalld/services/warewulf.xml
	fi

	systemd_dounit include/systemd/warewulfd.service

	find docs/man/man1/ -type f -iname '*.1' -exec doman {} \;
	find docs/man/man5/ -type f -iname '*.5' -exec doman {} \;

	insinto /usr/share/warewulf/ipxe
	for file in README-ipxe.md arm64.efi x86_64.efi x86_64.kpxe; do
		doins staticfiles/${file}
		fperms 0644 /usr/share/warewulf/ipxe/${file}
	done

	keepdir /srv/warewulf
	keepdir /usr/share/warewulf/ipxe
	keepdir /var/warewulf/chroots/
}

pkg_postinst() {
	if ! [[ "${REPLACING_VERSIONS}" ]]; then
		einfo "Gentoo does not ship a default configuration for Warewulf."
		einfo "One may be generated using the following command:"
		einfo "wwctl --emptyconf genconfig defaults /etc/warewulf/defaults.conf"
	fi
}
