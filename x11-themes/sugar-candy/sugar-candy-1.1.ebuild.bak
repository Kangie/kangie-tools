# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Sugar Candy theme for SDDM"
HOMEPAGE="https://www.opencode.net/marianarlt/sddm-sugar-candy"
SRC_URI="https://framagit.org/MarianArlt/sddm-sugar-candy/-/archive/v.${PV}/sddm-sugar-candy-v.${PV}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 x86 ~amd64 ~x86"
IUSE=""

DEPEND=">=dev-qt/qtquickcontrols2-5.11
>=dev-qt/qtsvg-5.11
>=dev-qt/qtgraphicaleffects-5.11
>=dev-qt/qtdeclarative-5.11
>=dev-qt/qtgui-5.11[jpeg]
>=x11-misc/sddm-0.18"
RDEPEND="${DEPEND}"
BDEPEND=""

# Theme maintainer uses non-standard name & version info
S="${WORKDIR}/sddm-sugar-candy-v.${PV}"


src_install() {
	local DOCS=( AUTHORS COPYING CREDITS README.md )
	einstalldocs

	local target="/usr/share/sddm/themes/${PN}"
	dodir ${target}
	insinto ${target}
	doins -r *
}

pkg_postinst () {
	elog "This theme can be customised by editing"
	elog "/usr/share/sddm/themes/sugar-candy/theme.conf"
	elog "You will need to setup your /etc/sddm.conf file before"
	elog "this theme will be applied. If the file does not exist"
	elog "it is safe to create it with the following config:"
	elog "[Theme]"
	elog "Current=sugar-candy"
}
