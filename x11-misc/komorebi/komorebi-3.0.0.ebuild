# Copyright 1999-2024 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..12} )

inherit gnome2-utils meson python-single-r1

DESCRIPTION="A beautiful, customizable wallpapers manager for Linux"
HOMEPAGE="https://github.com/Komorebi-Fork/komorebi"

if [[ ${PV} == 9999 ]];then
	inherit git-r3
	EGIT_REPO_URI="${HOMEPAGE}.git"
else
	SRC_URI="${HOMEPAGE}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64"
fi

LICENSE="GPL-3"
SLOT="0"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="
	${PYTHON_DEPS}
	dev-libs/libgee:0.8
	$(python_gen_cond_dep '
		dev-python/pygobject:3[${PYTHON_USEDEP}]
	')
	media-libs/clutter-gst:3.0[introspection]
	media-libs/clutter-gtk:1.0[introspection,gtk]
	media-libs/clutter:1.0[introspection,gtk]
	media-plugins/gst-plugins-libav
	net-libs/webkit-gtk:4
	x11-libs/gtk+:3
"

src_configure() {
	local emesonargs=(
		'--python.bytecompile=2'
	)
	meson_src_configure
}

pkg_preinst(){
	gnome2_schemas_savelist
}

pkg_postinst(){
	gnome2_gconf_install
	gnome2_schemas_update
}

pkg_postrm(){
	gnome2_gconf_uninstall
	gnome2_schemas_update
}
