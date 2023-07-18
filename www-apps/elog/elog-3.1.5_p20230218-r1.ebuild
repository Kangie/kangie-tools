# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake optfeature systemd

DESCRIPTION="A simple standalone weblog server"
HOMEPAGE="https://elog.psi.ch/elog/"

if [[ ${PV} == 9999 ]] ; then
	inherit git-r3
	EGIT_REPO_URI="https://bitbucket.org/ritt/elog"
else
	# Upstream's source tarballs are behind broken SSL.
	MY_COMMIT=338841043cb6
	# mxml is a submodule so we need to fetch it too
	MY_MXML_COMMIT=4d4b4cf17bec
	SRC_URI="
		https://bitbucket.org/ritt/elog/get/${MY_COMMIT}.tar.gz -> ${P}.tar.gz
		https://bitbucket.org/tmidas/mxml/get/${MY_MXML_COMMIT}.tar.gz -> tmidas-mxml-0.0.1_p20220215.tar.gz
	"
	S="${WORKDIR}/ritt-${PN}-${MY_COMMIT}"
	KEYWORDS="~amd64"
fi

LICENSE="GPL-2+"
SLOT="0"

IUSE="krb5 ldap pam"

RDEPEND="
	krb5? ( app-crypt/mit-krb5 )
	ldap? ( net-nds/openldap )
	pam? ( sys-libs/pam )
	>=dev-libs/openssl-0.9.8e:0=
	acct-user/elog
"

DEPEND="${RDEPEND}"

BDEPEND="dev-vcs/git"

PATCHES=(
	"${FILESDIR}/${PN}-3.1.5-cmake-order.patch"
)

src_unpack() {
	if [[ ${PV} == 9999 ]] ; then
		git-r3_src_unpack
	else
		default
		rm -rf "${S}"/mxml || die failed to remove mxml submodule placeholder
		mv tmidas-mxml-${MY_MXML_COMMIT} "${S}"/mxml || die failed to move mxml submodule data
	fi
}

src_prepare() {
	cmake_src_prepare
	sed -i \
		-e "s /usr/local/sbin ${EPREFIX}/usr/bin " \
		-e "s /usr/local ${EPREFIX}/etc " \
		"${S}"/elogd.service || die Failed to amend systemd unit
}

src_configure() {
	local mycmakeargs=()

	mycmakeargs+=( -DUSE_SSL=ON )

	if use krb5; then
		mycmakeargs+=( -DUSE_KRB5=ON )
	fi
	if use ldap; then
		mycmakeargs+=( -DUSE_LDAP=ON )
	fi
	if use pam; then
		mycmakeargs+=( -DUSE_PAM=ON )
	fi

	cmake_src_configure
}

src_compile() {
	cmake_src_compile
}

src_install() {
	# I realised too late that there was CMake and it's not worth the effort to
	# make that install work in portage; we'll just install manually.
	for manpage in elog.1 elogd.8; do
		doman man/$manpage
	done

	# Config
	insinto etc/elog
	doins "${FILESDIR}"/elogd.cfg.example
	fperms 644 /etc/elog/elogd.cfg.example
	# bundled certs are 15 years old; the user can generate any that they need.
	keepdir etc/elog/ssl
	fowners -R elog:elog /etc/elog
	# We won't install the demo logbook; elog can generate one anyway
	keepdir var/lib/elog
	fowners elog:elog /var/lib/elog
	insinto usr/bin
	for file in elog elogd; do
		doins "${WORKDIR}"/ritt-${PN}-${MY_COMMIT}_build/${file}
		fperms 755 /usr/bin/${file}
	done
	# Elog static resources
	insinto usr/share/elog
	doins -r scripts
	doins -r resources
	doins -r themes
	fowners -R elog:elog /usr/share/elog

	systemd_dounit elogd.service
}

pkg_postinst() {
	optfeature "image resizing" media-gfx/imagemagick
}