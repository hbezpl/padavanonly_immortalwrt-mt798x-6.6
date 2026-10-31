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
sed -i 's/192.168.6.1/192.168.66.254/g' package/base-files/files/bin/config_generate
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
sed -i 's/${vendorid:+-V "$vendorid"}/${vendorid:+-V "" "-x 0x3c:$vendorid"}/g' package/network/config/netifd/files/lib/netifd/proto/dhcp.sh

# 更换golang版本
rm -rf feeds/packages/lang/golang
mv files/golang feeds/packages/lang

# 修改frp版本
rm -rf feeds/packages/net/frp
mv files/frp/frp feeds/packages/net/
rm -rf feeds/luci/applications/luci-app-frpc
rm -rf feeds/luci/applications/luci-app-frps
mv files/frp/luci-app-frpc feeds/luci/applications/
mv files/frp/luci-app-frps feeds/luci/applications/ 

# 修改unblockneteasemusic
rm -rf feeds/luci/applications/luci-app-unblockneteasemusic
git clone https://github.com/UnblockNeteaseMusic/luci-app-unblockneteasemusic.git package/luci-app-unblockneteasemusic
sed -i 's/+node//g' package/luci-app-unblockneteasemusic/Makefile

#打包unblockneteasemusic的core核心
NAME=$"package/luci-app-unblockneteasemusic/root/usr/share/unblockneteasemusic" && mkdir -p $NAME/core
echo "$(curl -s 'https://api.github.com/repos/UnblockNeteaseMusic/server/commits?sha=enhanced&path=precompiled' | jq -r '.[0].sha')" > "$NAME/core_local_ver"
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

# 添加cmcc-rax3000m-256m
sed -i '/^TARGET_DEVICES += cmcc_rax3000m-nand-mtk$/a\
\
define Device/cmcc_rax3000m-nand-mtk-256m\
  DEVICE_VENDOR := CMCC\
  DEVICE_MODEL := RAX3000M NAND\
  DEVICE_VARIANT := (MTK 256m layout)\
  DEVICE_DTS := mt7981b-cmcc-rax3000m-nand-mtk-256m\
  DEVICE_DTS_DIR := ../dts\
  DEVICE_PACKAGES := kmod-usb3 f2fsck mkf2fs\
  BLOCKSIZE := 128k\
  PAGESIZE := 2048\
  IMAGE_SIZE := 240128k\
  IMAGE/sysupgrade.bin := sysupgrade-tar | append-metadata\
endef\
TARGET_DEVICES += cmcc_rax3000m-nand-mtk-256m
' target/linux/mediatek/image/filogic.mk
mv files/dts/mt7981b-cmcc-rax3000m-nand-mtk-256m.dts target/linux/mediatek/dts/
sed -i 's/compatible = "cmcc,rax3000m-nand", "mediatek,mt7981"/compatible = "cmcc,rax3000m-nand-mtk", "cmcc,rax3000m-nand", "mediatek,mt7981"/g' target/linux/mediatek/dts/mt7981b-cmcc-rax3000m-nand-mtk.dts
sed -i 's/compatible = "cmcc,rax3000m-emmc", "mediatek,mt7981"/compatible = "cmcc,rax3000m-emmc-mtk", "cmcc,rax3000m-emmc", "mediatek,mt7981"/g' target/linux/mediatek/dts/mt7981b-cmcc-rax3000m-emmc-mtk.dts

# 添加openclash
rm -rf package/feeds/luci/luci-app-openclash
rm -rf feeds/luci/applications/luci-app-openclash
mkdir package/openclash
cd package/openclash
git init
git remote add origin https://github.com/vernesong/OpenClash.git
git config core.sparsecheckout true
echo "luci-app-openclash" >> .git/info/sparse-checkout
git pull --depth 1 origin master
git branch --set-upstream-to=origin/master master
mv luci-app-openclash ../
cd ../../
rm -rf package/openclash

#添加上网时间控制
git clone https://github.com/gaobin89/luci-app-timecontrol package/luci-app-timecontrol
sed -i '/$(eval $(call BuildPackage,$(PKG_NAME)))/s/^/#/' package/luci-app-timecontrol/luci-app-timecontrol/Makefile
#sed -i 's/download-ci-llvm=true/download-ci-llvm=false/' feeds/packages/lang/rust/Makefile

rm -rf files


# 修复 Go 1.23+ linkname 检查导致 containerd/docker 编译失败
echo ">>> [diy] applying -checklinkname=0 workaround"

python3 - <<'PYEOF'
import pathlib

def patch_golang():
    p = pathlib.Path("feeds/packages/lang/golang/golang-package.mk")
    if not p.exists():
        print("[SKIP] golang-package.mk not found"); return
    s = p.read_text()
    if "checklinkname" in s:
        print("[OK] golang-package.mk already patched"); return
    p.write_text(s.rstrip() + "\n\nGO_PKG_CUSTOM_LDFLAGS += -checklinkname=0\n")
    print("[OK] golang-package.mk patched")

def patch_containerd():
    p = pathlib.Path("feeds/packages/utils/containerd/Makefile")
    if not p.exists():
        print("[SKIP] containerd Makefile not found"); return
    s = p.read_text()
    if "checklinkname" in s:
        print("[OK] containerd already patched"); return

    block = (
        "# Go 1.23+ linkname workaround\n"
        "define Build/Compile\n"
        "\tsed -i \"s/-ldflags '\\([^']*\\)'/-ldflags '\\1 -checklinkname=0'/g\" \\\n"
        "\t\t$(PKG_BUILD_DIR)/$(MAKE_PATH)/Makefile\n"
        "\t$(call Build/Compile/Default)\n"
        "endef\n"
    )
    old = ("# Reset golang-package.mk overrides so we can use the Makefile\n"
           "Build/Compile=$(call Build/Compile/Default)\n")

    if old in s:
        s = s.replace(old, block, 1); print("[OK] containerd patched (in place)")
    elif "$(eval $(call BuildPackage,containerd))" in s:
        s = s.replace("$(eval $(call BuildPackage,containerd))",
                      block + "\n$(eval $(call BuildPackage,containerd))", 1)
        print("[OK] containerd patched (before BuildPackage)")
    else:
        s = s.rstrip() + "\n\n" + block; print("[WARN] containerd patched (appended)")
    p.write_text(s)

def patch_docker():
    p = pathlib.Path("feeds/packages/utils/docker/Makefile")
    if not p.exists():
        print("[SKIP] docker Makefile not found"); return
    s = p.read_text()
    if "checklinkname" in s:
        print("[OK] docker already patched"); return

    old = "\t\tcd $(PKG_BUILD_DIR); \\\n\t\t$(GO_PKG_VARS) \\\n"
    new = (
        "\t\tcd $(PKG_BUILD_DIR); \\\n"
        "\t\tsed -i -e \"s/-ldflags \\\"/-ldflags \\\"-checklinkname=0 /\" \\\n"
        "\t\t\t-e \"s/-ldflags '/-ldflags '-checklinkname=0 /\" \\\n"
        "\t\t\tscripts/build/binary; \\\n"
        "\t\t$(GO_PKG_VARS) \\\n"
    )
    if old in s:
        s = s.replace(old, new, 1); print("[OK] docker patched (in place)")
    else:
        print("[WARN] docker patch pattern not found, skip")
    p.write_text(s)

patch_golang()
patch_containerd()
patch_docker()
PYEOF

echo ">>> [diy] verify:"
grep -n "checklinkname" \
  feeds/packages/lang/golang/golang-package.mk \
  feeds/packages/utils/containerd/Makefile \
  feeds/packages/utils/docker/Makefile || true
