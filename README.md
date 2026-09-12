# proot-claw-bridge

A zero-copy, persistent bridge to expose OpenClaw directories (`~/.openclaw`) running inside a Termux Debian PRoot environment directly to Android's Storage Access Framework (SAF).

Edit configs, workspace files, and assets from Android apps (Acode, Material Files, QuickEdit, etc.) in real time without duplicating files or wrestling with `/sdcard` permission limits.

---

## ⚡ Quick Start

Run this one-liner in your **Termux host** shell (outside of PRoot):

```bash
bash <(curl -sL https://raw.githubusercontent.com/heavylildude/proot-claw-bridge/main/proot-claw-bridge.sh)
```

Alternatively, clone and run locally:

```bash
git clone https://github.com/heavylildude/proot-claw-bridge.git
cd proot-claw-bridge
chmod +x proot-claw-bridge.sh
./proot-claw-bridge.sh
```

---

## 🛠️ How It Works

1. **Native ext4 Performance:** Instead of copying files to shared emulated storage (`/sdcard`)—which lacks Unix permission handling and breaks symlinks—this script drops a persistent symlink named `openclaw_proot` directly into Termux's native `$HOME`.
2. **Auto-Discovery:** Scans your Debian rootfs to find whether `.openclaw` belongs to `root` or a non-root user under `/home/<username>`.
3. **No Dotfile Hiding:** Android's SAF document picker automatically hides directories starting with a `.` (dot). The exposed symlink drops the dot so Android file managers pick it up instantly.
4. **Persistent:** Runs once. The symlink remains active across device reboots and PRoot restarts.

---

## 📱 Accessing from Android

Once executed, open your preferred SAF-compatible Android application (e.g., **Acode**, **Material Files**, **MiXplorer**, or **Solid Explorer**):

1. Choose **Add Storage** / **Open Folder** → **Document Provider** (System file picker).
2. Tap the hamburger menu on the top left and select **Termux**.
3. Select **`openclaw_proot`**.
4. Grant access.

Any changes made inside Android are written directly to your Debian PRoot filesystem without sync scripts or background daemons.

---

## 📋 Requirements

* [Termux](https://github.com/termux/termux-app)
* [proot-distro](https://github.com/termux/proot-distro) with `debian` installed:
  ```bash
  pkg install proot-distro
  proot-distro install debian
  ```

---

## 📄 License

MIT © [heavylildude](https://github.com/heavylildude)
