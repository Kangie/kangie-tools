# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
USE_RUBY="ruby23 ruby24 ruby25"

RUBY_FAKEGEM_EXTRADOC="README.md"
RUBY_FAKEGEM_GEMSPEC="${PN}.gemspec"

inherit ruby-fakegem multilib

DESCRIPTION="Multitouch gestures with libinput driver on Linux"
HOMEPAGE="https://github.com/iberianpig/fusuma"

if [[ ${PV} == 9999 ]];then
	KEYWORDS=""
	inherit git-r3
	EGIT_REPO_URI="https://github.com/iberianpig/fusuma.git"
else
	KEYWORDS="~amd64 ~x86"
	EGIT_COMMIT="refs/tags/v${PV}"
fi

LICENSE="MIT"
SLOT="0"
IUSE=""

DEPEND=">=dev-libs/libinput-1.0"
RDEPEND="${DEPEND}"
BDEPEND=""
