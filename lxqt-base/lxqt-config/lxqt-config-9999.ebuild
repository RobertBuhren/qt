# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils gnome2-utils eapi7-ver

DESCRIPTION="LXQt system configuration control center"
HOMEPAGE="https://lxqt.org/"

if [[ ${PV} = *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/lxqt/${PN}.git"
else
	SRC_URI="https://downloads.lxqt.org/downloads/${PN}/${PV}/${P}.tar.xz"
	KEYWORDS="~amd64 ~arm ~arm64 ~x86"
fi

LICENSE="GPL-2 GPL-2+ GPL-3 LGPL-2 LGPL-2+ LGPL-2.1+ WTFPL-2"
SLOT="0"
IUSE="+monitor +touchpad"

RDEPEND="
	>=dev-libs/libqtxdg-3.0.0
	dev-qt/qtcore:5
	dev-qt/qtdbus:5
	dev-qt/qtgui:5
	dev-qt/qtwidgets:5
	dev-qt/qtx11extras:5
	dev-qt/qtxml:5
	kde-frameworks/kwindowsystem:5
	=lxqt-base/liblxqt-$(ver_cut 1-2)*
	sys-libs/zlib:=
	x11-apps/setxkbmap
	x11-libs/libxcb:=
	x11-libs/libX11
	x11-libs/libXcursor
	x11-libs/libXfixes
	monitor? ( kde-plasma/libkscreen:5= )
	touchpad? (
		virtual/libudev
		x11-drivers/xf86-input-libinput
		x11-libs/libXext
	)
"
DEPEND="${DEPEND}
	dev-qt/linguist-tools:5
	>=dev-util/lxqt-build-tools-0.5.0
"

PATCHES="${FILESDIR}/${PN}-0.14.0-make-touchpad-optional.patch"

src_configure() {
	local mycmakeargs=(
		-DPULL_TRANSLATIONS=OFF
		-DWITH_MONITOR="$(usex monitor)"
		-DWITH_TOUCHPAD="$(usex touchpad)"
	)
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
	doman man/*.1 liblxqt-config-cursor/man/*.1 lxqt-config-appearance/man/*.1
}

pkg_postinst() {
	gnome2_icon_cache_update

	if ! use touchpad; then
		ewarn "Please do not report issues to upstream, if they are caused by"
		ewarn "USE=\"-touchpad\", as upstream does not support such a build."
	fi
}

pkg_postrm() {
	gnome2_icon_cache_update
}
