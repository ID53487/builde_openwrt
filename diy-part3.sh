#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part3.sh
# Description: OpenWrt DIY script part 3 (After make menuconfig)
#

# 确保在正确的目录中执行
# 修改此处：从 /openwrt 改为 $GITHUB_WORKSPACE/openwrt
cd $GITHUB_WORKSPACE/openwrt || { echo "无法进入openwrt目录"; exit 1; }

#用于编译mtk7628nn的openwrt固件，补充添加wifi功能、usb网络共享功能
#以下脚本默认用于单网口设备

# 添加WiFi支持包
echo "添加WiFi支持包..."
sed -i '/# CONFIG_PACKAGE_kmod-mac80211 is not set/c\CONFIG_PACKAGE_kmod-mac80211=y' .config
sed -i '/# CONFIG_PACKAGE_wpad-basic-wolfssl is not set/c\CONFIG_PACKAGE_wpad-basic-wolfssl=y' .config

# 启用WiFi功能并设置默认配置
echo "配置WiFi功能..."
mkdir -p package/base-files/files/etc/config
cat >> package/base-files/files/etc/config/wireless << EOF

config wifi-device 'radio0'
        option type 'mac80211'
        option channel '11'
        option hwmode '11g'
        option path 'platform/10300000.wmac'
        option htmode 'HT20'
        option disabled '0'

config wifi-iface 'default_radio0'
        option device 'radio0'
        option network 'lan'
        option mode 'ap'
        option ssid 'OpenWrt'
        option encryption 'psk2'
        option key 'password123'
EOF

# 添加USB网络共享支持
echo "添加USB网络共享支持..."
sed -i '/# CONFIG_PACKAGE_kmod-usb-net is not set/c\CONFIG_PACKAGE_kmod-usb-net=y' .config
sed -i '/# CONFIG_PACKAGE_kmod-usb-net-asix is not set/c\CONFIG_PACKAGE_kmod-usb-net-asix=y' .config
sed -i '/# CONFIG_PACKAGE_kmod-usb-net-cdc-ether is not set/c\CONFIG_PACKAGE_kmod-usb-net-cdc-ether=y' .config
sed -i '/# CONFIG_PACKAGE_kmod-usb-net-rndis is not set/c\CONFIG_PACKAGE_kmod-usb-net-rndis=y' .config
sed -i '/# CONFIG_PACKAGE_kmod-usb-net-rtl8152 is not set/c\CONFIG_PACKAGE_kmod-usb-net-rtl8152=y' .config
sed -i '/# CONFIG_PACKAGE_kmod-usb2 is not set/c\CONFIG_PACKAGE_kmod-usb2=y' .config
sed -i '/# CONFIG_PACKAGE_kmod-usb3 is not set/c\CONFIG_PACKAGE_kmod-usb3=y' .config

# 配置单网口路由器功能
echo "配置单网口路由器功能..."
mkdir -p package/base-files/files/etc/config
cat > package/base-files/files/etc/config/network << EOF
config interface 'loopback'
        option device 'lo'
        option proto 'static'
        option ipaddr '127.0.0.1'
        option netmask '255.0.0.0'

config globals 'globals'
        option ula_prefix 'fd1e:643b:7c56::/48'

config interface 'lan'
        option device 'br-lan'
        option proto 'static'
        option ipaddr '192.168.1.1'
        option netmask '255.255.255.0'
        option ip6assign '60'

config device 'lan_dev'
        option name 'br-lan'
        option type 'bridge'
        list ports 'eth0'

config interface 'wan'
        option device 'usb0'
        option proto 'dhcp'

config interface 'wan6'
        option device 'usb0'
        option proto 'dhcpv6'
EOF

# 配置防火墙规则以支持NAT和转发
echo "配置防火墙规则..."
mkdir -p package/base-files/files/etc/config
cat > package/base-files/files/etc/config/firewall << EOF
config defaults
        option syn_flood '1'
        option input 'ACCEPT'
        option output 'ACCEPT'
        option forward 'REJECT'

config zone
        option name 'lan'
        list network 'lan'
        option input 'ACCEPT'
        option output 'ACCEPT'
        option forward 'ACCEPT'

config zone
        option name 'wan'
        list network 'wan'
        list network 'wan6'
        option input 'REJECT'
        option output 'ACCEPT'
        option forward 'REJECT'
        option masq '1'
        option mtu_fix '1'

config forwarding
        option src 'lan'
        option dest 'wan'

config rule
        option name 'Allow-DHCP-Renew'
        option src 'wan'
        option proto 'udp'
        option dest_port '68'
        option target 'ACCEPT'
        option family 'ipv4'

config rule
        option name 'Allow-Ping'
        option src 'wan'
        option proto 'icmp'
        option icmp_type 'echo-request'
        option family 'ipv4'
        option target 'ACCEPT'

config rule
        option name 'Allow-IGMP'
        option src 'wan'
        option proto 'igmp'
        option family 'ipv4'
        option target 'ACCEPT'

config rule
        option name 'Allow-DHCPv6'
        option src 'wan'
        option proto 'udp'
        option dest_port '546'
        option family 'ipv6'
        option target 'ACCEPT'

config rule
        option name 'Allow-MLD'
        option src 'wan'
        option proto 'icmp'
        option src_ip 'fe80::/10'
        list icmp_type '130/0'
        list icmp_type '131/0'
        list icmp_type '132/0'
        list icmp_type '143/0'
        option family 'ipv6'
        option target 'ACCEPT'

config rule
        option name 'Allow-ICMPv6-Input'
        option src 'wan'
        option proto 'icmp'
        list icmp_type 'echo-request'
        list icmp_type 'echo-reply'
        list icmp_type 'destination-unreachable'
        list icmp_type 'packet-too-big'
        list icmp_type 'time-exceeded'
        list icmp_type 'bad-header'
        list icmp_type 'unknown-header-type'
        list icmp_type 'router-solicitation'
        list icmp_type 'neighbor-solicitation'
        list icmp_type 'router-advertisement'
        list icmp_type 'neighbor-advertisement'
        option limit '1000/sec'
        option family 'ipv6'
        option target 'ACCEPT'

config rule
        option name 'Allow-ICMPv6-Forward'
        option src 'wan'
        option dest '*'
        option proto 'icmp'
        list icmp_type 'echo-request'
        list icmp_type 'echo-reply'
        list icmp_type 'destination-unreachable'
        list icmp_type 'packet-too-big'
        list icmp_type 'time-exceeded'
        list icmp_type 'bad-header'
        list icmp_type 'unknown-header-type'
        option limit '1000/sec'
        option family 'ipv6'
        option target 'ACCEPT'
EOF

# 启用USB网络支持的服务
echo "启用USB网络支持服务..."
mkdir -p package/base-files/files/etc/uci-defaults
cat > package/base-files/files/etc/uci-defaults/99-usb-network << EOF
#!/bin/sh
# 启用USB网络接口
uci set network.wan.device='usb0'
uci set network.wan.proto='dhcp'
uci commit network

# 重启网络服务
/etc/init.d/network restart
EOF

# 设置文件权限
chmod +x package/base-files/files/etc/uci-defaults/99-usb-network

echo "DIY脚本执行完成！"
