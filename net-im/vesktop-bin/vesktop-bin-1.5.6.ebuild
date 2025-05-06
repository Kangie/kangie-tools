# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg unpacker

DESCRIPTION="Vesktop: the performance of web Discord and the comfort of Discord Desktop"
HOMEPAGE="https://github.com/Vencord/Vesktop"
SRC_URI="
	amd64? ( https://github.com/Vencord/Vesktop/releases/download/v${PV}/vesktop_${PV}_amd64.deb )
	arm64? ( https://github.com/Vencord/Vesktop/releases/download/v${PV}/vesktop_${PV}_arm64.deb )
"
S="${WORKDIR}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RESTRICT="test"

RDEPEND="
	x11-libs/libnotify
	x11-misc/xdg-utils
"

QA_PREBUILT="
	opt/Vesktop/chrome_crashpad_handler
	opt/Vesktop/chrome-sandbox
	opt/Vesktop/libEGL.so
	opt/Vesktop/libffmpeg.so
	opt/Vesktop/libGLESv2.so
	opt/Vesktop/libvk_swiftshader.so
	opt/Vesktop/libvulkan.so.1
	opt/Vesktop/vesktop
"

src_install() {
	cp -rp "${WORKDIR}/opt" "${D}"
	# We don't want to collide with non-bin
	cp -rp "${WORKDIR}/usr/share/icons " "${D}/opt/Vesktop"

	make_desktop_entry "${EPREFIX}/opt/Vesktop/vesktop" "Vesktop (bin)" \
		"${EPREFIX}/opt/Vesktop/icons/hicolor/64x64/apps/vesktop.png" Network
}
