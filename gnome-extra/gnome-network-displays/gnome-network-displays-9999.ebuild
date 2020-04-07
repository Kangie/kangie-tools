# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit git-r3 meson xdg

DESCRIPTION="Miracast (Wi-Fi Display) implementation for GNOME"
HOMEPAGE="https://github.com/benzea/gnome-network-displays"
SRC_URI=""
EGIT_REPO_URI="https://github.com/benzea/gnome-network-displays.git"

if [[ ${PV} == 9999 ]];then
	KEYWORDS=""
else
	KEYWORDS="~amd64 ~x86"
	EGIT_COMMIT="refs/tags/v${PV}"
fi

LICENSE=""
SLOT="0"
IUSE=""

#TODO
#Dependencies:
#	Video: At least one of openh264 (unsure, media-plugins/gst-plugins-openh264?) or x264 (media-video/x264-encoder) - will work if at least one is installed at runtime.
#	Audio at least one of fdkaacenc (media-libs/fdk-aac) , faac (2?) (media-libs/faac, use flag faac already exists) or avenc_aac
#	sys-apps/xdg-desktop-portal to be installed unless using gnome(3?) where x11-wm/mutter should be in use and has the functionality built in.
#
DEPEND=">=net-misc/networkmanager-1.15.2
net-wireless/wpa_supplicant[p2p]
media-plugins/gst-plugins-x264
|| ( media-video/x264-encoder media-plugins/gst-plugins-openh264 )
|| ( media-libs/fdk-aac media-libs/faac media-plugins/gst-plugins-libav )
media-libs/gst-rtsp-server
|| ( sys-apps/xdg-desktop-portal x11-wm/mutter )"
RDEPEND="${DEPEND}"
BDEPEND=""

src_install () {
	meson_src_install
	}

pkg_postinst () {
	xdg_icon_cache_update
	}

pkg_postrm () {
	xdg_icon_cache_update
	}

