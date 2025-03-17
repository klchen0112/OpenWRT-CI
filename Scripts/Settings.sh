#!/bin/bash

#修改默认主题
sed -i "s/luci-theme-bootstrap/luci-theme-$WRT_THEME/g" $(find ./feeds/luci/collections/ -type f -name "Makefile")
#修改immortalwrt.lan关联IP
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" $(find ./feeds/luci/modules/luci-mod-system/ -type f -name "flash.js")
#添加编译日期标识
sed -i "s/(\(luciversion || ''\))/(\1) + (' \/ $WRT_CI-$WRT_DATE')/g" $(find ./feeds/luci/modules/luci-mod-status/ -type f -name "10_system.js")

WIFI_SH=$(find ./target/linux/{mediatek/filogic,qualcommax}/base-files/etc/uci-defaults/ -type f -name "*set-wireless.sh")
WIFI_UC="./package/network/config/wifi-scripts/files/lib/wifi/mac80211.uc"
if [ -f "$WIFI_SH" ]; then
	#修改WIFI名称
	sed -i "s/BASE_SSID='.*'/BASE_SSID='$WRT_SSID'/g" $WIFI_SH
	#修改WIFI密码
	sed -i "s/BASE_WORD='.*'/BASE_WORD='$WRT_WORD'/g" $WIFI_SH
elif [ -f "$WIFI_UC" ]; then
	#修改WIFI名称
	sed -i "s/ssid='.*'/ssid='$WRT_SSID'/g" $WIFI_UC
	#修改WIFI密码
	sed -i "s/key='.*'/key='$WRT_WORD'/g" $WIFI_UC
	#修改WIFI地区
	sed -i "s/country='.*'/country='CN'/g" $WIFI_UC
	#修改WIFI加密
	sed -i "s/encryption='.*'/encryption='psk2+ccmp'/g" $WIFI_UC
fi

CFG_FILE="./package/base-files/files/bin/config_generate"
#修改默认IP地址
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" $CFG_FILE
#修改默认主机名
sed -i "s/hostname='.*'/hostname='$WRT_NAME'/g" $CFG_FILE

#修改默认时区
sed -i "s/timezone='.*'/timezone='CST-8'/g" $CFG_FILE
sed -i "/timezone='.*'/a\\\t\t\set system.@system[-1].zonename='Asia/Shanghai'" $CFG_FILE

#配置文件修改
echo "CONFIG_PACKAGE_luci=y" >> ./.config
echo "CONFIG_LUCI_LANG_zh_Hans=y" >> ./.config
echo "CONFIG_PACKAGE_luci-theme-$WRT_THEME=y" >> ./.config
echo "CONFIG_PACKAGE_luci-app-$WRT_THEME-config=y" >> ./.config

#手动调整的插件
if [ -n "$WRT_PACKAGE" ]; then
	echo -e "$WRT_PACKAGE" >> ./.config
fi


# 主路由配置
if [[ $WRT_TARGET != *"MT7621"* ]]; then
    echo "CONFIG_PACKAGE_luci-app-netspeedtest=n" >> ./.config
	echo "CONFIG_PACKAGE_luci-app-natmap=y" >> ./.config
	echo "CONFIG_PACKAGE_mosdns=y" >> ./.config #DNS服务器
	echo "CONFIG_PACKAGE_luci-app-mosdns=n" >> ./.config #DNS服务器
	echo "CONFIG_PACKAGE_luci-app-uugamebooster=n" >> ./.config # uu游戏
	echo "CONFIG_PACKAGE_tailscale=y" >> ./.config #vpn
	echo "CONFIG_PACKAGE_tailscaled=y" >> ./.config #vpn
fi

if [[ $WRT_TARGET != *"MT7621"* ]]; then
	echo "CONFIG_PACKAGE_sing-box=y" >> ./.config #DNS服务器
	echo "CONFIG_PACKAGE_luci-app-homeproxy=n" >> ./.config
fi

# if [[ $WRT_TARGET != *"MT7621"* && $WRT_TARGET != *"IPQ"* ]]; then

# DAE
	# echo "CONFIG_KERNEL_DEBUG_INFO=y" >> ./.config
	# echo "CONFIG_KERNEL_DEBUG_INFO_REDUCED=n" >> ./.config
	# echo "CONFIG_KERNEL_DEBUG_INFO_BTF=y" >> ./.config
	# echo "CONFIG_KERNEL_CGROUP_BPF=y" >> ./.config
	# echo "CONFIG_KERNEL_BPF_EVENTS=y" >> ./.config
	# echo "CONFIG_BPF_TOOLCHAIN_HOST=y" >> ./.config
	# echo "CONFIG_KERNEL_XDP_SOCKETS=y" >> ./.config
	# echo "CONFIG_PACKAGE_kmod-xdp-sockets-diag=y" >> ./.config
	# SAVING RAM FOR DAE
	# echo "CONFIG_PACKAGE_zram-swap=y" >> ./.config
	# echo "CONFIG_PACKAGE_kmod-lib-lz4=y" >> ./.config
	# echo "CONFIG_PACKAGE_kmod-lib-lzo=y" >> ./.config
	# echo "CONFIG_PACKAGE_kmod-lib-zstd=y" >> ./.config
	### AGGRESSIVE ###
	# echo "CONFIG_USE_GC_SECTIONS=y" >> ./.config
	# echo "CONFIG_USE_LTO=y" >> ./.config
	# echo "CONFIG_PACKAGE_dae=y" >> ./.config
	# echo "CONFIG_PACKAGE_luci-app-daed=n" >> ./.config
	# echo "CONFIG_PACKAGE_luci-app-nikki=y" >> ./.config
# fi

#高通平台调整
if [[ $WRT_TARGET == *"QUALCOMMAX"* ]]; then
	#取消nss相关feed
	echo "CONFIG_FEED_nss_packages=n" >> ./.config
	echo "CONFIG_FEED_sqm_scripts_nss=n" >> ./.config
	#设置NSS版本
	echo "CONFIG_NSS_FIRMWARE_VERSION_11_4=n" >> ./.config
	echo "CONFIG_NSS_FIRMWARE_VERSION_12_2=y" >> ./.config
fi

#编译器优化
if [[ $WRT_TARGET != *"X86"* ]]; then
	echo "CONFIG_TARGET_OPTIONS=y" >> ./.config
	echo "CONFIG_TARGET_OPTIMIZATION=\"-O2 -pipe -march=armv8-a+crypto+crc -mcpu=cortex-a53+crypto+crc -mtune=cortex-a53\"" >> ./.config
fi
