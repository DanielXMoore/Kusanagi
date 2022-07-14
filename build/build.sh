#!/bin/bash
set -euo pipefail

rm -r dist/ || true
mkdir -p dist

# normal files
coffee build/main.coffee

# cli
BIN="dist/kusanagi"
echo "#!/usr/bin/env node" | cat - dist/cli.js > "$BIN"
chmod +x "$BIN"
rm dist/cli.js
