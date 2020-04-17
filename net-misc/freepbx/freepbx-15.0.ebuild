# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="FreePBX - a web-based open source GUI that controls and manages Asterisk (PBX)"
HOMEPAGE="https://freepbx.org"
SRC_URI="http://mirror.freepbx.org/modules/packages/freepbx/{$P}-latest.tgz -> {$P}.tgz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="csf apache2 nginx"

DEPEND="apache2? ( www-servers/apache2,dev-lang/php7.4[apache2] )
csf? ( dev-perl/libwww-perl )
nginx? ( www-servers/nginx,dev-lang/php:7.4[fpm,nginx] )
>=net-misc/asterisk-11.25.3 [http,mysql]
app-admin/sudo
app-crypt/gnupg
dev-db/mariadb
dev-db/mariadb-connector-c
dev-db/mariadb-connector-odbc
dev-db/sqlite
dev-lang/php:7.4 [mysql,opcache,fpm,pdo,curl,gd,mbstring,gettext]
dev-libs/ossp-uuid
dev-php/pear
dev-php/PEAR-Console_Getopt
dev-vcs/git
media-sound/sox [flac,opus,ogg,wavpack]
media-video/ffmpeg [vorbis]
media-video/mpg123
net-libs/nodejs
sys-devel/bison
virtual/mta
"
RDEPEND="${DEPEND}"
BDEPEND=">=net-misc/asterisk-11.25.3"
