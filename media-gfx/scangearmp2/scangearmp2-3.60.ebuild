# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit autotools

MY_P="${PN}-source-${PV}-1"

DESCRIPTION="Driver and utility package for Canon scanners"
HOMEPAGE="https://www.canon.com"
SRC_URI="http://gdlp01.c-wss.com/gds/3/0100009493/01/${MY_P}.tar.gz"

LICENSE="Canon-IJ"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=">=x11-libs/gtk+-2.16:2
virtual/libusb:1"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_P}/${PN}"

src_prepare()
{
	sed -i -e '/^CFLAGS/d' configure.in || die
	sed -i -e '/AC_INIT/s/in/ac/' configure.in || die
	mv configure.{in,ac} || die

	eapply -p2 ${FILESDIR}/scangearmp2-3.60-1_fix_crash.patch
	eapply_user

	eautoreconf
}

src_compile()
{
	SHIPPED_LIBS="${WORKDIR}/${MY_P}/com/libs_bin$(usex amd64 64 32)"
	emake LDFLAGS="-L${SHIPPED_LIBS}"
}

src_install()
{
	SHIPPED_LIBS="${WORKDIR}/${MY_P}/com/libs_bin$(usex amd64 64 32)"

	dodir /usr/lib/bjlib
	dodir /lib/udev/rules.d
	
	dolib.so "${SHIPPED_LIBS}/"*.so*
	insinto /usr/lib/bjlib
	doins "${WORKDIR}/${MY_P}/com/ini/canon_mfp2_net.ini"

	insinto /lib/udev/rules.d
	doins "${S}/etc/"*.rules

	emake DESTDIR="${D}" install
}
