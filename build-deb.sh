#!/usr/bin/env bash
# Build agent-monitor_<version>_all.deb from ./src
set -euo pipefail
cd "$(dirname "$0")"
V="$(tr -d '[:space:]' < VERSION)"
PKG="agent-monitor_${V}_all.deb"
STG=staging
rm -rf "$STG"
mkdir -p "$STG/usr/bin" \
         "$STG/usr/share/agent-monitor/icons" \
         "$STG/usr/share/applications" \
         "$STG/usr/share/doc/agent-monitor" \
         "$STG/usr/share/icons/hicolor/scalable/apps" \
         "$STG/DEBIAN"
install -m 755 src/agent-monitor                 "$STG/usr/bin/agent-monitor"
install -m 755 src/agent-monitor-install-hook    "$STG/usr/bin/agent-monitor-install-hook"
install -m 644 src/hook/agent-auto-log           "$STG/usr/share/agent-monitor/hook.sh"
install -m 644 src/icons/*.svg "$STG/usr/share/agent-monitor/icons/"
install -m 644 src/icons/agent-monitor.svg       "$STG/usr/share/icons/hicolor/scalable/apps/agent-monitor.svg"
install -m 644 src/agent-monitor.desktop         "$STG/usr/share/applications/agent-monitor.desktop"
install -m 644 README.md                         "$STG/usr/share/doc/agent-monitor/README.md"
cat > "$STG/DEBIAN/control" <<CTRL
Package: agent-monitor
Version: $V
Section: admin
Priority: optional
Architecture: all
Depends: python3, python3-gi, gir1.2-gtk-3.0
Recommends: cloudflared
Maintainer: Pejman <pejman@agent-box>
Description: Live monitor of the AI agent's activity on this VM
 Arrow panel (read/write with byte counters), a live command log with
 search/follow/clear (daily-rotated logs), and Cloudflare tunnel status
 with restart/stop/start plus an ingress settings GUI.
 .
 CLI: agent-monitor [--stats|--selftest|--version]
CTRL
cat > "$STG/DEBIAN/postinst" <<'POST'
#!/bin/sh
set -e
if command -v update-desktop-database >/dev/null 2>&1; then update-desktop-database -q; fi
if command -v gtk-update-icon-cache >/dev/null 2>&1; then gtk-update-icon-cache -q -t -f /usr/share/icons/hicolor; fi
exit 0
POST
chmod 755 "$STG/DEBIAN/postinst"
( cd "$STG" && find . -type f ! -path './DEBIAN/*' -printf '%P\0' | sort -z | xargs -0 md5sum > DEBIAN/md5sums )
dpkg-deb --root-owner-group --build "$STG" "$PKG" >/dev/null
rm -rf "$STG"
echo "built: $PKG ($(stat -c%s "$PKG") bytes)"
