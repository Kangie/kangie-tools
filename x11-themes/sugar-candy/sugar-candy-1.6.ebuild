# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit git-r3

DESCRIPTION="Sugar Candy theme for SDDM"
HOMEPAGE="https://www.opencode.net/marianarlt/sddm-sugar-candy"
#SRC_URI="https://framagit.org/MarianArlt/sddm-sugar-candy/-/archive/v.${PV}/sddm-sugar-candy-v.${PV}.tar.gz -> ${P}.tar.gz"
EGIT_REPO_URI="https://github.com/Kangie/sddm-sugar-candy.git"

if [[ ${PV} == 9999 ]];then
	KEYWORDS=""
else
	KEYWORDS="~amd64 ~x86"
	EGIT_COMMIT="refs/tags/v${PV}"
fi

LICENSE="GPL-3"
SLOT="0"
IUSE="svg jpeg"

# Require at least one kind of image support
REQUIRED_USE="!jpeg? ( svg )
!svg? ( jpeg )"

DEPEND=">=dev-qt/qtquickcontrols2-5.11
svg? ( >=dev-qt/qtsvg-5.11 )
>=dev-qt/qtgraphicaleffects-5.11
>=dev-qt/qtdeclarative-5.11
>=dev-qt/qtgui-5.11[jpeg?]
>=x11-misc/sddm-0.18"
RDEPEND="${DEPEND}"
BDEPEND=""

# Git repo checks out to a subfolder
#S="${WORKDIR}/sddm-sugar-candy"
#EGIT_CHECKOUT_DIR=${WORKDIR}/${P}
src_install() {
	local DOCS=( AUTHORS COPYING CHANGELOG.md README.md )
	einstalldocs

	local target="${ROOT}usr/share/sddm/themes/${PN}"
	dodir ${target}
	insinto ${target}
	doins -r *
}

pkg_postinst () {
	elog "This theme can be customised by editing"
	elog "${ROOT}usr/share/sddm/themes/sugar-candy/theme.conf"
	elog "You will need to setup your ${ROOT}etc/sddm.conf file before"
	elog "this theme will be applied. If the file does not exist"
	elog "it is safe to create it with the following config:"
	elog "[Theme]"
	elog "Current=sugar-candy"
}
