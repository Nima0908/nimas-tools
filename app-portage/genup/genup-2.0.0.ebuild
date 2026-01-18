# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit bash-completion-r1

DESCRIPTION="Gentoo System Updater - Automated system update script"
HOMEPAGE="https://github.com/Nima0908/genup"
SRC_URI="https://github.com/Nima0908/genup/releases/download/${PV}/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm64"

IUSE="buildkernel emtee pmerge nocache"

DEPEND="
	>=sys-apps/portage-3.0.0
	>=app-portage/eix-0.36.0
"
RDEPEND="
	${DEPEND}
	>=sys-apps/coreutils-8.0
	>=sys-apps/findutils-4.4
	>=sys-apps/grep-2.5
	>=sys-apps/sed-4.0
	>=sys-apps/which-2.0
	>=sys-process/procps-3.0.0
	>=sys-apps/util-linux-2.0
	>=app-admin/eselect-1.4.0
	>=sys-devel/gcc-8.0
	>=app-portage/gentoolkit-0.5.0
	>=app-portage/portage-utils-0.80
	buildkernel? ( sys-kernel/buildkernel )
	emtee? ( app-portage/emtee )
	pmerge? ( sys-apps/pkgcore )
	nocache? ( sys-fs/nocache )
"

S="${WORKDIR}/${PN}"

src_install() {
	# Install the main script
	dobin genup || die "Failed to install genup script"

	# Install man page
	doman "${FILESDIR}"/genup.1 || die "Failed to install man page"

	# Install bash completion (from FILESDIR as you intended)
	newbashcomp "${FILESDIR}"/genup.bash genup || die "Failed to install bash completion"

	# Install configuration
	insinto /etc/genup
	doins "${FILESDIR}"/genup.conf || die "Failed to install configuration"

	# Create updaters.d directory
	keepdir /etc/genup/updaters.d
	fperms 755 /etc/genup/updaters.d
}

pkg_preinst() {
	if [[ -f "${EROOT}"/etc/genup.conf ]]; then
		if [[ ! -f "${EROOT}"/etc/genup/genup.conf ]]; then
			cp "${EROOT}"/etc/genup.conf "${EROOT}"/etc/genup/genup.conf
		fi
	fi
}

pkg_postinst() {
	elog ""
	elog "Gentoo System Updater (genup) has been successfully installed!"
	elog ""
	elog "Key Features:"
	elog "  - Automated portage tree synchronization"
	elog "  - Complete @world system updates"
	elog "  - Kernel update support (with buildkernel USE flag)"
	elog "  - Configuration file conflict resolution"
	elog "  - Custom updater support via /etc/genup/updaters.d"
	elog ""
	elog "Basic Usage:"
	elog "  genup"
	elog "  genup --ask"
	elog "  genup --help"
	elog ""

	if use buildkernel; then
		elog "Kernel update support is enabled"
	else
		elog "Kernel update support is disabled"
	fi

	if use emtee; then
		elog "emtee support is enabled"
	else
		elog "emtee support is disabled"
	fi

	if use pmerge; then
		elog "pmerge support is enabled"
	else
		elog "pmerge support is disabled"
	fi

	if use nocache; then
		elog "nocache support is enabled"
	else
		elog "nocache support is disabled"
	fi

	elog ""
	elog "For more information, see: man genup"
	elog ""
}

pkg_prerm() {
	if [[ -f "${EROOT}"/etc/genup/genup.conf ]]; then
		ewarn "Configuration file found at ${EROOT}/etc/genup/genup.conf"
		ewarn "This file will be preserved. Remove manually if not needed."
	fi
}

