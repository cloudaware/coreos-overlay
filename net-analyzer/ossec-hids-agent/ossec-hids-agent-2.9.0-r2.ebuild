# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit rpm systemd user multilib

MY_P="${P}-2"

DESCRIPTION="OSSEC"
HOMEPAGE="https://ossec.github.io"
SRC_URI="${MY_P}.x86_64.rpm"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64"

RESTRICT="mirror fetch strip"

S="${WORKDIR}"

pkg_nofetch() {
	einfo "Please download ${A} from ${HOMEPAGE}/downloads.html"
	einfo "The archive should then be placed into ${DISTDIR}."
}

pkg_setup() {
	local group="ossec"
	enewgroup $group
	enewuser ossec -1 -1 /var/ossec $group
	enewuser ossecm -1 -1 /var/ossec $group
	enewuser ossecr -1 -1 /var/ossec $group
}

src_install() {
	# Using doins -r would strip executable bits from all binaries
	cp -pPR "${S}"/var "${D}"/ || die "Failed to copy files"
	cp -fpL /etc/localtime "${D}"/var/ossec/etc/ || die "Failed to copy localtime"

	touch "${D}"/var/ossec/logs/ossec.log
	fowners ossec:ossec /var/ossec/logs/ossec.log

	newinitd "${FILESDIR}"/ossec.initd ossec
	systemd_newunit "${FILESDIR}"/ossec.service ossec.service

	dosym libssl.so /usr/$(get_libdir)/libssl.so.10
	dosym libcrypto.so /usr/$(get_libdir)/libcrypto.so.10
}
