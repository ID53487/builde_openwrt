#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# Modify default IP /修改 OpenWrt 路由器的默认管理 IP 192.168.1.1为192.168.50.5
#sed -i 's/192.168.1.1/192.168.50.5/g' package/base-files/files/bin/config_generate

# Modify default theme/替换主题界面，由默认简洁主题luci-theme-bootstrap替换为科技风的luci-theme-argon
#sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# Modify hostname/修改 OpenWrt 系统的默认主机名/由OpenWrt改为P3TERX-Router
#sed -i 's/OpenWrt/P3TERX-Router/g' package/base-files/files/bin/config_generate
