  #!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

# 修改IP(C类地址)和主机名
#sed -i 's/192.168.1.1/192.168.99.1/g' package/base-files/luci2/bin/config_generate
sed -i 's/192.168.6.1/192.168.13.254/g' package/base-files/files/bin/config_generate
#sed -i 's/255.255.255.0/255.255.0.0/g' package/base-files/files/bin/config_generate

# 修改登录密码ezxykj
#sed -i '/root::0:0:99999:7:::/s/^/#/' package/lean/default-settings/files/zzz-default-settings
#sed -i '/root:::0:99999:7:::/s/^/#/' package/lean/default-settings/files/zzz-default-settings
sed -i 's/root:::0:99999:7:::/root:$1$iZM.01X5$xfeRwcqbhN\/60\/2SUPwDc\/:0:0:99999:7:::/g' package/base-files/files/etc/shadow

# 修改默认主题
#sed -i '/luci.main.mediaurlbase/s/^/#/' feeds/luci/themes/luci-theme-argon/root/etc/uci-defaults/30_luci-theme-argon
#sed -i '/luci.main.mediaurlbase/s/^/#/' feeds/luci/themes/luci-theme-bootstrap/root/etc/uci-defaults/30_luci-theme-bootstrap
#sed -i '/luci.main.mediaurlbase/s/^/#/' feeds/luci/themes/luci-theme-material/root/etc/uci-defaults/30_luci-theme-material
#sed -i '/luci.main.mediaurlbase/s/^/#/' feeds/luci/themes/luci-theme-openwrt/root/etc/uci-defaults/30_luci-theme-openwrt
#sed -i '/luci.main.mediaurlbase/s/^/#/' feeds/luci/themes/luci-theme-openwrt-2020/root/etc/uci-defaults/30_luci-theme-openwrt-2020
#sed -i 's/Bootstrap Theme (default)/Bootstrap Theme/g' feeds/luci/themes/luci-theme-bootstrap/Makefile
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci-light/Makefile

# 更改IP后TTYD不能访问以及外网访问
#sed -i '/${interface:+-i $interface}/s/^/#/' feeds/packages/utils/ttyd/files/ttyd.init               //此屏蔽与IPV6有冲突
#sed -i '/@lan/d' feeds/packages/utils/ttyd/files/ttyd.config
#sed -i "$ a\ \toption ipv6 '1'" feeds/packages/utils/ttyd/files/ttyd.config

#修改iptv
#sed -i 's/${vendorid:+-V "$vendorid"}/${vendorid:+-V "" "-x 0x3c:$vendorid"}/g' package/network/config/netifd/files/lib/netifd/proto/dhcp.sh

# 修改frp版本
rm -rf feeds/packages/net/frp
mv files/frp/net/frp feeds/packages/net/
rm -rf feeds/luci/applications/luci-app-frpc
rm -rf feeds/luci/applications/luci-app-frps
mv files/frp/luci-app-frpc feeds/luci/applications/
mv files/frp/luci-app-frps feeds/luci/applications/ 

# 修改unblockneteasemusic
git clone https://github.com/UnblockNeteaseMusic/luci-app-unblockneteasemusic.git package/luci-app-unblockneteasemusic
sed -i 's/+node//g' package/luci-app-unblockneteasemusic/Makefile

#打包unblockneteasemusic的core核心
NAME=$"package/luci-app-unblockneteasemusic/root/usr/share/unblockneteasemusic" && mkdir -p $NAME/core
echo "$(uclient-fetch -qO- 'https://api.github.com/repos/UnblockNeteaseMusic/server/commits?sha=enhanced&path=precompiled' | jsonfilter -e '@[0].sha')">"$NAME/core_local_ver"
curl -L https://github.com/UnblockNeteaseMusic/server/raw/enhanced/precompiled/app.js -o $NAME/core/app.js
curl -L https://github.com/UnblockNeteaseMusic/server/raw/enhanced/precompiled/bridge.js -o $NAME/core/bridge.js
mv files/unm/ca.crt $NAME/core/ca.crt
mv files/unm/server.crt $NAME/core/server.crt
mv files/unm/server.key $NAME/core/server.key
#curl -L https://github.com/UnblockNeteaseMusic/server/raw/enhanced/ca.crt -o $NAME/core/ca.crt
#curl -L https://github.com/UnblockNeteaseMusic/server/raw/enhanced/server.crt -o $NAME/core/server.crt
#curl -L https://github.com/UnblockNeteaseMusic/server/raw/enhanced/server.key -o $NAME/core/server.key

# lucky
git clone  https://github.com/gdy666/luci-app-lucky.git package/lucky
