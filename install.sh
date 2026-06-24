#!/bin/sh
# Surge Universal Installer — POSIX compatible
set -e

REPO="jh2929/Surge-Linux"
VERSION="v0.7.0"
BINDIR="${HOME}/.local/bin"
DESKTOPDIR="${HOME}/.local/share/applications"

URL="https://github.com/${REPO}/releases/download/${VERSION}/surge-0.7.0-linux-x86_64-gui.tar.gz"

log() { printf '\033[1;34m==>\033[0m %s\n' "$1"; }
warn() { printf '\033[1;33m  warning:\033[0m %s\n' "$1"; }
die() { printf '\033[1;31m  error:\033[0m %s\n' "$1" >&2; exit 1; }

download() {
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$1"
    elif command -v wget >/dev/null 2>&1; then
        wget -qO- "$1"
    else
        die "neither curl nor wget found. Install one and retry."
    fi
}

log "Surge universal installer"
log "Installing into: ${BINDIR}"

mkdir -p "${BINDIR}"

log "downloading surge (GUI) + surge-ui (Dashboard)..."
download "${URL}" | tar xz -C "${BINDIR}" surge surge-ui
chmod +x "${BINDIR}/surge" "${BINDIR}/surge-ui"

log "creating desktop shortcut for surge-ui..."
mkdir -p "${DESKTOPDIR}"
cat <<EOF > "${DESKTOPDIR}/surge-ui.desktop"
[Desktop Entry]
Type=Application
Name=Surge Dashboard
Comment=Manage and uninstall applications installed via Surge
Exec=${BINDIR}/surge-ui
Icon=surge
Terminal=false
Categories=Utility;Settings;PackageManager;
EOF

if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "${DESKTOPDIR}" >/dev/null 2>&1 || true
fi

log "registering MIME associations..."
"${BINDIR}/surge" --register >/dev/null 2>&1 || warn "Could not complete MIME registration automatically."

log "installed successfully"

case ":${PATH}:" in
    *:"${BINDIR}":*) ;;
    *) warn "${BINDIR} is not in your PATH"
       printf '    add this to your shell config:\n'
       printf '    export PATH="${HOME}/.local/bin:${PATH}"\n' ;;
esac
