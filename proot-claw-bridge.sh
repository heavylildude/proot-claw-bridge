#!/data/data/com.termux/files/usr/bin/bash
# ==============================================================================
# proot-claw-bridge.sh
# Bridge Debian PRoot's ~/.openclaw directly to Android via Termux SAF
# Author: heavylildude
# ==============================================================================

set -euo pipefail

# 1. Environment check: Ensure execution in Termux host, not inside PRoot
if [ -z "${TERMUX_VERSION:-}" ] && [ ! -d "/data/data/com.termux" ]; then
    echo "❌ [Error] Run this directly from the Termux host shell, NOT inside PRoot."
    exit 1
fi

PROOT_DISTRO_DIR="$PREFIX/var/lib/proot-distro"
DISTRO_NAME="debian"

# proot-distro v5.x+ (current) stores rootfs at containers/<name>/rootfs
# older proot-distro (pre-5.0) stored it at installed-rootfs/<name>
NEW_LAYOUT="$PROOT_DISTRO_DIR/containers/$DISTRO_NAME/rootfs"
LEGACY_LAYOUT="$PROOT_DISTRO_DIR/installed-rootfs/$DISTRO_NAME"

LINK_TARGET="$HOME/openclaw_proot"

echo "🏄 [proot-claw-bridge] Checking Debian rootfs..."

# 2. Detect which layout is actually in use
if [ -d "$NEW_LAYOUT" ]; then
    DEBIAN_ROOTFS="$NEW_LAYOUT"
elif [ -d "$LEGACY_LAYOUT" ]; then
    DEBIAN_ROOTFS="$LEGACY_LAYOUT"
else
    echo "❌ [Error] Debian rootfs not found in either known location:"
    echo "   New layout    : $NEW_LAYOUT"
    echo "   Legacy layout : $LEGACY_LAYOUT"
    echo "   Run 'proot-distro list' to confirm the container is really installed,"
    echo "   or 'proot-distro login debian' once to force a layout check/migration."
    exit 1
fi

echo "✅ Found rootfs at: $DEBIAN_ROOTFS"

# 3. Locate or create the .openclaw directory
TARGET_SOURCE=""

# Check root first
if [ -d "$DEBIAN_ROOTFS/root/.openclaw" ]; then
    TARGET_SOURCE="$DEBIAN_ROOTFS/root/.openclaw"
else
    # Check existing non-root users
    if [ -d "$DEBIAN_ROOTFS/home" ]; then
        for udir in "$DEBIAN_ROOTFS/home/"*; do
            if [ -d "$udir/.openclaw" ]; then
                TARGET_SOURCE="$udir/.openclaw"
                break
            fi
        done
    fi
fi

# If .openclaw doesn't exist anywhere yet, initialize it
if [ -z "$TARGET_SOURCE" ]; then
    echo "🔍 No existing ~/.openclaw directory found inside Debian."
    echo "Where should it live?"
    echo "  1) root (/root/.openclaw) [Default]"
    echo "  2) Non-root user (/home/<username>/.openclaw)"
    # 👇 Slap the < /dev/tty right at the end of these two read lines 👇
    read -r -p "Selection [1/2]: " USER_CHOICE < /dev/tty
    USER_CHOICE="${USER_CHOICE:-1}"

    if [ "$USER_CHOICE" = "2" ]; then
        read -r -p "Enter PRoot username: " PROOT_USER < /dev/tty
        TARGET_SOURCE="$DEBIAN_ROOTFS/home/$PROOT_USER/.openclaw"
    else
        TARGET_SOURCE="$DEBIAN_ROOTFS/root/.openclaw"
    fi

    mkdir -p "$TARGET_SOURCE"
    echo "📁 Created: $TARGET_SOURCE"
fi

# 4. Generate persistent symlink on Termux host
ln -sfn "$TARGET_SOURCE" "$LINK_TARGET"

echo ""
echo "🤙 Bridge locked in and ready to roll!"
echo "---------------------------------------------------------"
echo "PRoot Source : $TARGET_SOURCE"
echo "Termux Link  : $LINK_TARGET"
echo "---------------------------------------------------------"
echo ""
echo "📱 How to open in Android editors (Acode, Material Files, etc.):"
echo "1. Open your Android app -> Add Storage / Open Folder -> Document Provider."
echo "2. Select 'Termux' from the file drawer."
echo "3. Pick 'openclaw_proot'."
echo ""
echo "All edits write straight to Debian in real-time. Zero copy, zero lag."
