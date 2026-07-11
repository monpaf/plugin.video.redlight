#!/usr/bin/env bash
# Build a Red Light release into packages/ for the addon's built-in self-updater.
#
# The updater (resources/lib/modules/updater.py) reads, from the "master" branch of
# this repo at packages/:
#   - redlightam_version                       -> the online version string
#   - redlightam_changes                       -> changelog shown before updating
#   - plugin.video.redlight-<version>.zip      -> the addon zip it installs
#
# Usage:
#   ./build_release.sh           # build packages/ locally then commit it (amending the last commit)
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ADDON_ID="plugin.video.redlight"
ADDON_DIR="$ROOT/$ADDON_ID"
PKG_DIR="$ROOT/packages"

[ -f "$ADDON_DIR/addon.xml" ] || { echo "ERROR: $ADDON_DIR/addon.xml not found" >&2; exit 1; }

# First version="..." in addon.xml is the addon version (it precedes the imports).
VERSION="$(grep -m1 -oP 'version="\K[^"]+' "$ADDON_DIR/addon.xml")"
[ -n "$VERSION" ] || { echo "ERROR: could not parse version from addon.xml" >&2; exit 1; }
echo "==> Building Red Light $VERSION"

mkdir -p "$PKG_DIR"
ZIP_PATH="$PKG_DIR/$ADDON_ID-$VERSION.zip"
rm -f "$ZIP_PATH"

# Zip the addon folder so it extracts as plugin.video.redlight/ (what the updater expects).
( cd "$ROOT" && zip -r -q -X "$ZIP_PATH" "$ADDON_ID" \
    -x "*/__pycache__/*" "*.pyc" "*.pyo" "*/.git/*" "*/.DS_Store" )

# Version + changelog files consumed by the updater.
printf '%s' "$VERSION" > "$PKG_DIR/redlightam_version"
if [ -f "$ADDON_DIR/resources/text/changelog.txt" ]; then
    cp "$ADDON_DIR/resources/text/changelog.txt" "$PKG_DIR/redlightam_changes"
else
    printf 'Red Light %s' "$VERSION" > "$PKG_DIR/redlightam_changes"
fi

echo "==> packages/ contents:"
ls -la "$PKG_DIR"

echo "==> Committing release $VERSION"
git -C "$ROOT" add packages
git -C "$ROOT" commit --amend --no-edit
