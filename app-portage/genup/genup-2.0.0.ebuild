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

IUSE="buildkernel emtee pgmerge nocache"

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
	pgmerge? ( app-portage/pgmerge )
	nocache? ( sys-fs/nocache )
"

src_install() {
	# Install the main script
	dobin genup || die "Failed to install genup script"

	# Set proper permissions
	fperms +x /usr/bin/genup

	# Install man page
	doman genup.1 || die "Failed to install man page"

	# Install bash completion
	newbashcomp "${FILESDIR}"/genup.bash genup || die "Failed to install bash completion"

	# Install configuration directory
	insinto /etc/genup
	doins "${FILESDIR}"/genup.conf || die "Failed to install configuration"

	# Create updaters.d directory
	keepdir /etc/genup/updaters.d
	fperms 755 /etc/genup/updaters.d

	# Install docs
	dodoc README.md || die "Failed to install README"
	dodoc CHANGELOG.md || die "Failed to install CHANGELOG"
}

pkg_preinst() {
	# Check for old version and migrate configuration if needed
	if [[ -f "${EROOT}"/etc/genup.conf ]]; then
		if [[ ! -f "${EROOT}"/etc/genup/genup.conf ]]; then
			cp "${EROOT}"/etc/genup.conf "${EROOT}"/etc/genup/genup.conf
		fi
	fi
}

pkg_postinst() {
	# Post-installation setup
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
	elog "  genup                    # Run a complete system update"
	elog "  genup --ask              # Interactive mode with confirmations"
	elog "  genup --help             # Show all available options"
	elog ""
	elog "Configuration:"
	elog "  - Main config: /etc/genup/genup.conf"
	elog "  - Custom updaters: /etc/genup/updaters.d/"
	elog ""

	# Enable/disable USE flags based configuration
	if use buildkernel; then
		elog "Kernel update support is enabled via USE flag"
	else
		elog "Kernel update support is disabled (set USE=buildkernel to enable)"
	fi

	if use emtee; then
		elog "emtee support is enabled via USE flag"
	else
		elog "emtee support is disabled (set USE=emtee to enable)"
	fi

	if use pgmerge; then
		elog "pgmerge support is enabled via USE flag"
	else
		elog "pgmerge support is disabled (set USE=pgmerge to enable)"
	fi

	if use nocache; then
		elog "nocache support is enabled via USE flag"
	else
		elog "nocache support is disabled (set USE=nocache to enable)"
	fi

	elog ""
	elog "For more information, see the man page: man genup"
	elog ""
}

pkg_prerm() {
	# Clean up configuration on removal if user chooses
	if [[ -f "${EROOT}"/etc/genup/genup.conf ]]; then
		ewarn "Configuration file found at ${EROOT}/etc/genup/genup.conf"
		ewarn "This file will be preserved. Remove manually if not needed."
	fi
}

# This is a live ebuild that installs from the current directory
# The actual file is copied during src_unpack phase
