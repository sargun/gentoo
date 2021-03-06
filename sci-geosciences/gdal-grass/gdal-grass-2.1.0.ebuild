# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils

DESCRIPTION="GDAL plugin to access GRASS data"
HOMEPAGE="http://www.gdal.org/"
SRC_URI="http://download.osgeo.org/gdal/${PV}/${P}.tar.gz"

SLOT="0"
LICENSE="MIT"
KEYWORDS="~amd64 ~x86"

IUSE="postgres"
RDEPEND="
	>=sci-libs/gdal-2.0.0
	sci-geosciences/grass:0=
"
DEPEND="${RDEPEND}
	dev-libs/expat
	dev-libs/json-c:=
	virtual/jpeg
	media-libs/tiff
	sci-libs/libgeotiff
	sci-libs/proj
	sys-libs/zlib
	postgres? ( dev-db/postgresql )"

# these drivers are copied at install from the already installed GRASS
QA_PREBUILT="/usr/share/gdal/grass/driver/db/*"

src_prepare() {
	sed -e 's:mkdir ${GRASSTABLES_DIR}$:mkdir -p ${GRASSTABLES_DIR}:' \
		-i Makefile.in || die
	default
}

src_configure() {
	econf \
		--with-grass="/usr/$(get_libdir)/grass70" \
		--with-gdal="/usr/bin/gdal-config" \
		$(use_with postgres postgres-includes "/usr/include/postgresql")
}

src_install() {
	#pass the right variables to 'make install' to prevent a sandbox access violation
	emake DESTDIR="${D}" \
		GRASSTABLES_DIR="${D}$(gdal-config --prefix)/share/gdal/grass" \
		AUTOLOAD_DIR="${D}/usr/$(get_libdir)/gdalplugins" \
		install
}
