
# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit git-r3

DESCRIPTION="Graphical multitouch viewer"
HOMEPAGE="https://github.com/whot/mtview"
EGIT_REPO_URI="https://github.com/whot/mtview.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=""
DEPEND=${RDEPEND}

src_configure() {
	./autogen.sh
	./configure --prefix=/usr
}
