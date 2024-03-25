# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake desktop flag-o-matic optfeature systemd

DESCRIPTION="Gridcoin Proof-of-Stake based crypto-currency that rewards BOINC computation"
HOMEPAGE="https://gridcoin.us/"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/gridcoin/Gridcoin-Research.git"
	EGIT_BRANCH="development"
	PATCHES="${FILESDIR}/gridcoin-9999-desktop.patch"
else
	SRC_URI="https://github.com/gridcoin/Gridcoin-Research/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64"
	S="${WORKDIR}/Gridcoin-Research-${PV}"
fi

LICENSE="MIT"
SLOT="0"

IUSE_GUI="+dbus +gui"
IUSE_OPTIONAL="doc pic +qrcode static test +upnp"
IUSE_SYSTEM="system-bdb system-ldb"
IUSE_EXPAND="cpu_flags_x86_sha cpu_flags_x86_avx2 cpu_flags_x86_sse4_1 cpu_flags_arm_sha1"
IUSE="${IUSE_GUI} daemon ${IUSE_OPTIONAL} ${IUSE_EXPAND} ${IUSE_SYSTEM}"
RESTRICT="!test? ( test )"

REQUIRED_USE="
	|| ( daemon gui )
	dbus? ( gui )
	qrcode? ( gui )
"

BDEPEND="
	doc? ( app-text/doxygen )
"
# test? ( dev-util/xxd )

RDEPEND="
	acct-group/gridcoin
	acct-user/gridcoin
	>=dev-libs/boost-1.73.0:=
	>=dev-libs/libsecp256k1-0.2.0
	>=dev-libs/libzip-1.3.0:=
	>=dev-libs/openssl-1.1.1d:=
	dev-libs/libevent
	dev-libs/univalue
	net-misc/curl
	dbus? ( dev-qt/qtdbus:5 )
	gui? (
		dev-qt/linguist-tools:5
		dev-qt/qtcharts:5
		dev-qt/qtconcurrent:5
		dev-qt/qtcore:5
		dev-qt/qtgui:5
		dev-qt/qtnetwork:5
		dev-qt/qtwidgets:5
	)
	qrcode? ( media-gfx/qrencode )
	system-bdb? ( sys-libs/db:5.3[cxx] )
	system-ldb? ( >=dev-libs/leveldb-1.23 )
	upnp? ( >=net-libs/miniupnpc-1.9.20140401 )
"

DEPEND="${RDEPEND}"

PATCHES=(
	"${FILESDIR}"/gridcoin-9999-find-leveldb.patch
)

src_configure() {
	append-flags -Wa,--noexecstack
	local mycmakeargs=()

	# Use system libs
	mycmakeargs+=(
		-DSYSTEM_BDB=$(usex system-bdb)
		-DSYSTEM_LEVELDB=$(usex system-ldb)
		-DSYSTEM_SECP256K1=ON
		-DSYSTEM_UNIVALUE=ON
		-DSYSTEM_XXD=OFF
	)

	# This _may_ need to be the opposite of $(usex pic)
	if use amd64; then
		mycmakeargs+=(
			-DUSE_ASM_X86_64=ON
		)
	fi
	# CPU_FLAGS_* dependent options
	# I _think_ sha-ni for ARM is sha1
	mycmakeargs+=(
		-DENABLE_ARM_SHANI=$(usex cpu_flags_arm_sha1)
		-DENABLE_AVX2=$(usex cpu_flags_x86_avx2)
		-DENABLE_SSE41=$(usex cpu_flags_x86_sse4_1)
		-DENABLE_X86_SHANI=$(usex cpu_flags_x86_sha)
	)

	# Anything that can trivially be handled via USEX
	mycmakeargs+=(
		-DDEFAULT_UPNP=$(usex upnp)
		-DENABLE_DAEMON=$(usex daemon)
		-DENABLE_DOCS=$(usex doc)
		-DENABLE_GUI=$(usex gui)
		-DENABLE_PIE=$(usex pic)
		-DENABLE_QRENCODE=$(usex qrcode)
		-DENABLE_TESTS=$(usex test)
		-DENABLE_UPNP=$(usex upnp)
		-DLUPDATE=OFF
		-DUSE_DBUS=$(usex dbus)
	)

	cmake_src_configure
}

src_install() {
	# Live package is called staging and should *only* be used for testing purposes
	local suffix=""
	if [[ ${PV} == 9999 ]]; then
		local suffix="-staging"
	fi

	if use daemon; then
			newbin "${BUILD_DIR}"/src/gridcoinresearchd gridcoinresearchd${suffix}
			newman doc/gridcoinresearchd.1 gridcoinresearchd${suffix}.1
			newinitd "${FILESDIR}"/gridcoin${suffix}.init gridcoin${suffix}
	fi
	if use gui; then
		newbin "${BUILD_DIR}"/src/qt/gridcoinresearch gridcoinresearch${suffix}
		newman doc/gridcoinresearch.1 gridcoinresearch${suffix}.1
		newmenu contrib/gridcoinresearch.desktop gridcoinresearch${suffix}.desktop
		for size in 16 22 24 32 48 64 128 256 ; do
			newicon -s "${size}" "share/icons/hicolor/${size}x${size}/apps/gridcoinresearch.png" gridcoinresearch${suffix}.png
		done
		newicon -s scalable "share/icons/hicolor/scalable/apps/gridcoinresearch.svg" gridcoinresearch${suffix}.svg
	 fi

	systemd_dounit "${FILESDIR}"/gridcoin${suffix}.service
	newinitd "${FILESDIR}"/gridcoin${suffix}.init gridcoin${suffix}

	dodoc README.md CHANGELOG.md doc/build-unix.md

	diropts -o${PN} -g${PN}
	keepdir /var/lib/${PN}/.GridcoinResearch/
	newconfd "${FILESDIR}"/gridcoinresearch.conf gridcoinresearch
	fowners gridcoin:gridcoin /etc/conf.d/gridcoinresearch
	fperms 0660 /etc/conf.d/gridcoinresearch
	dosym -r /etc/conf.d/gridcoinresearch /var/lib/${PN}/.GridcoinResearch/gridcoinresearch.conf
}

pkg_postinst() {
	if use debug; then
		ewarn "You have enabled debug flags and macros during compilation."
		ewarn "For these to be useful, you should also have Portage retain debug symbols."
		ewarn "See https://wiki.gentoo.org/wiki/Debugging on configuring your environment"
		ewarn "and set your desired FEATURES before (re-)building this package."
	fi
	if [[ ${PV} == 9999 ]]; then
		ewarn "NB: This branch is only intended for debugging on the gridcoin testnet!"
		ewarn "	Only proceed if you know what you are doing."
		ewarn "	Testnet users must join Slack at https://teamgridcoin.slack.com #testnet"
		ewarn "\nAll generated binaries, services, and desktop files have the suffix '-staging'."
	fi
	elog "The daemon can be found at /usr/bin/gridcoinresearchd"
	use gui && elog "The graphical wallet can be found at /usr/bin/gridcoinresearch"
	elog
	elog "You need to configure this node with a few basic details to do anything"
	elog "useful with gridcoin. The wallet configuration file is located at:"
	elog "	/etc/conf.d/gridcoinresearch"
	elog "The wiki for this configuration file is located at:"
	elog "	http://wiki.gridcoin.us/Gridcoinresearch_config_file"
	elog
	if use boinc; then
		elog "To run your wallet as a researcher you should add gridcoin user to boinc group."
		elog "Run as root:"
		elog "gpasswd -a gridcoin boinc"
		elog
	fi
	optfeature BOINC proof-of-work mining sci-misc/boinc
}
