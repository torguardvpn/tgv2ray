# 
# Copyright (C) 2024 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=tgv2ray
PKG_VERSION:=1.0.0
PKG_RELEASE:=6
PKG_MAINTAINER:=TorGuard <support@torguard.net>
PKG_LICENSE:=GPL-3.0

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/tgv2ray
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=VPN
	TITLE:=TorGuard V2Ray Manager
	DEPENDS:=+luci +luci-compat +curl +jq +bash +coreutils-base64 +sing-box
	PKGARCH:=all
endef

define Package/tgv2ray/description
  LuCI interface for managing TorGuard V2Ray connections using sing-box
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/tgv2ray/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_DIR) $(1)/etc/tgv2ray
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller/admin
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/torguard
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view/tgv2ray
	$(INSTALL_DIR) $(1)/usr/bin

	$(INSTALL_BIN) ./files/etc/init.d/tgv2ray $(1)/etc/init.d/tgv2ray
	$(INSTALL_DATA) ./files/etc/config/tgv2ray $(1)/etc/config/tgv2ray
	$(INSTALL_BIN) ./files/etc/uci-defaults/tgv2ray_def $(1)/etc/uci-defaults/tgv2ray_def
	$(INSTALL_DATA) ./files/etc/tgv2ray/v2ray_default.conf $(1)/etc/tgv2ray/v2ray_default.conf
	$(INSTALL_DATA) ./files/etc/tgv2ray/config.json.template $(1)/etc/tgv2ray/config.json.template
	$(INSTALL_DATA) ./files/usr/lib/lua/luci/controller/admin/tgv2ray.lua $(1)/usr/lib/lua/luci/controller/admin/tgv2ray.lua
	$(INSTALL_DATA) ./files/usr/lib/lua/luci/model/cbi/torguard/tgv2ray.lua $(1)/usr/lib/lua/luci/model/cbi/torguard/tgv2ray.lua
	$(INSTALL_DATA) ./files/usr/lib/lua/luci/view/tgv2ray/status.htm $(1)/usr/lib/lua/luci/view/tgv2ray/status.htm
	$(INSTALL_DATA) ./files/usr/lib/lua/luci/view/tgv2ray/buttons.htm $(1)/usr/lib/lua/luci/view/tgv2ray/buttons.htm
	$(INSTALL_BIN) ./files/usr/bin/tgv2ray-subscription $(1)/usr/bin/tgv2ray-subscription
	$(INSTALL_BIN) ./files/usr/bin/tgv2ray-config-gen $(1)/usr/bin/tgv2ray-config-gen
endef

define Package/tgv2ray/prerm
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || {
	/etc/init.d/tgv2ray stop
	/etc/init.d/tgv2ray disable
}
endef

define Package/tgv2ray/conffiles
/etc/tgv2ray/config.json
endef

$(eval $(call BuildPackage,tgv2ray)) 