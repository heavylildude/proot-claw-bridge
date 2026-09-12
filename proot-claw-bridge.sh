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

DEBIAN_ROOTFS="$PREFIX/var/lib/proot-distro/installed-rootfs/debian"
LINK_TARGET="$HOME/openclaw_proot"

echo "🏄 [proot-claw-bridge] Checking Debian rootfs..."

# 2. Verify Debian rootfs exists
if [ ! -d "$DEBIAN_ROOTFS" ]; then
    echo "❌ [Error] Debian rootfs not found at: $DEBIAN_ROOTFS"
    echo "   Install it first with: proot-distro install debian"
    exit 1
fi

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
    read -r -p "Selection [1/2]: " USER_CHOICE
    USER_CHOICE="${USER_CHOICE:-1}"

    if [ "$USER_CHOICE" = "2" ]; then
        read -r -p "Enter PRoot username: " PROOT_USER
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