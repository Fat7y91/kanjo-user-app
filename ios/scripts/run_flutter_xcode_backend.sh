#!/bin/sh
# Flutter codesigns App.framework during `xcode_backend.sh build`.
# iCloud File Provider stamps FinderInfo onto those files, and codesign
# then fails with "resource fork, Finder information, or similar detritus
# not allowed". Intercept `codesign` and strip xattrs first.

set +e

SHIM_DIR="${CONFIGURATION_TEMP_DIR:-${TMPDIR:-/tmp}}/codesign_shim"
mkdir -p "$SHIM_DIR"

cat > "$SHIM_DIR/codesign" << 'EOF'
#!/bin/sh
target="${@: -1}"
if [ -e "$target" ]; then
  xattr -cr "$target" >/dev/null 2>&1
  parent="$(dirname "$target")"
  if [ -d "$parent" ]; then
    xattr -cr "$parent" >/dev/null 2>&1
  fi
fi
exec /usr/bin/codesign "$@"
EOF
chmod +x "$SHIM_DIR/codesign"
export PATH="$SHIM_DIR:$PATH"

if [ -n "$TARGET_BUILD_DIR" ] && [ -d "$TARGET_BUILD_DIR" ]; then
  xattr -cr "$TARGET_BUILD_DIR" >/dev/null 2>&1
fi

# Keep iCloud from re-stamping the local build tree.
if [ -n "$SRCROOT" ] && [ -d "$SRCROOT/../build" ]; then
  xattr -w com.apple.fileprovider.ignore#P 1 "$SRCROOT/../build" >/dev/null 2>&1
fi

set -e
exec /bin/sh "$FLUTTER_ROOT/packages/flutter_tools/bin/xcode_backend.sh" "$@"
