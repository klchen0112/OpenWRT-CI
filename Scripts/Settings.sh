#!/bin/bash

#修改默认主题
sed -i "s/luci-theme-bootstrap/luci-theme-$WRT_THEME/g" $(find ./feeds/luci/collections/ -type f -name "Makefile")
#修改immortalwrt.lan关联IP
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" $(find ./feeds/luci/modules/luci-mod-system/ -type f -name "flash.js")
#添加编译日期标识
sed -i "s/(\(luciversion || ''\))/(\1) + (' \/ $WRT_CI-$WRT_DATE')/g" $(find ./feeds/luci/modules/luci-mod-status/ -type f -name "10_system.js")
#修改默认WIFI名
sed -i "s/\.ssid=.*/\.ssid=$WRT_WIFI/g" $(find ./package/kernel/mac80211/ ./package/network/config/ -type f -name "mac80211.*")

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
	echo "$WRT_PACKAGE" >> ./.config
fi

#高通平台锁定512M内存
if [[ $WRT_TARGET == *"IPQ"* ]]; then
       echo "CONFIG_IPQ_MEM_PROFILE_1024=y" >> ./config
	   echo "CONFIG_IPQ_MEM_PROFILE_512=n" >> ./config
	   echo "CONFIG_IPQ_MEM_PROFILE_256=n" >> ./config
	   echo "CONFIG_KERNEL_IPQ_MEM_PROFILE_256=n" >> ./config
	   echo "CONFIG_NSS_MESH_SUPPORT=y" >> ./config
	   echo "CONFIG_NSS_MEM_PROFILE_HIGH=y" >> ./config
	   echo "CONFIG_ATH11K_MEM_PROFILE_256M=n" >> ./.config
	   echo "CONFIG_ATH11K_MEM_PROFILE_512M=y" >> ./.config
       echo "CONFIG_ATH11K_MEM_PROFILE_1G=n" >> ./.config
fi
# 主路由配置
if [[ $WRT_TARGET != *"MT7621"* ]]; then
    # netspeedtest
    echo "CONFIG_PACKAGE_luci-app-netspeedtest=n" >> ./config
	# NATMAP
	echo "CONFIG_PACKAGE_luci-app-natmap=y" >> ./.config
	#科学插件调整
	echo "CONFIG_PACKAGE_luci-app-homeproxy=n" >> ./.config
	#DAE CONFIG
	echo "CONFIG_PACKAGE_dae=y" >> ./config
	echo "CONFIG_KERNEL_DEBUG_KERNEL=y" >> ./config
	echo "CONFIG_KERNEL_DEBUG_INFO=y" >> ./config
	echo "CONFIG_KERNEL_DEBUG_INFO_REDUCED=n" >> ./config
	echo "CONFIG_KERNEL_DEBUG_INFO_BTF=y" >> ./config
	echo "CONFIG_BPF_TOOLCHAIN_HOST=y" >> ./config
	echo "CONFIG_KERNEL_BPF_EVENTS=y" >> ./config
	echo "CONFIG_KERNEL_CGROUP_BPF=y" >> ./config
	echo "CONFIG_BPF_SYSCALL=y" >> ./config
	echo "CONFIG_BPF_JIT=y" >> ./config
	echo "CONFIG_NET_CLS_BPF=y" >> ./config
	echo "CONFIG_NET_ACT_BPF=y" >> ./config
	echo "CONFIG_XDP_SOCKETS=y" >> ./config
	echo "CONFIG_XDP_SOCKETS_DIAG=y" >> ./config
	echo "CONFIG_BPF_TOOLCHAIN_NONE=n" >> ./config
	# DNS
	echo "CONFIG_PACKAGE_luci-app-mosdns=y" >> ./.config #DNS服务器
	# UU
	# echo "CONFIG_PACKAGE_luci-app-uugamebooster=y" >> ./.config # uu游戏
fi
