#!/usr/bin/env bash
# Render a mod's SVG the way the desktop app shows an isInteractive Svg: inside a sandboxed frame,
# on dark and light grounds, after the animation has run for a while. Prints the PNG path.
# Usage: svg-check.sh <file.svg> [ms=3000] [width=600]
set -euo pipefail
SVG=$1; MS=${2:-3000}; W=${3:-600}
OUT="${TMPDIR:-/tmp}/svg-check-$$"; mkdir -p "$OUT"
# Chrome or Chromium: $CHROME, then PATH, then the macOS app.
CHROME=${CHROME:-$(command -v google-chrome chromium chromium-browser chrome 2>/dev/null | head -1 || true)}
[ -z "$CHROME" ] && [ -x "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" ] \
  && CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
[ -z "$CHROME" ] && { echo "svg-check: no Chrome found; set CHROME=/path/to/chrome" >&2; exit 1; }
python3 - "$SVG" "$OUT/page.html" "$W" <<'EOF'
import base64, sys
svg = open(sys.argv[1], 'rb').read()
src = 'data:image/svg+xml;base64,' + base64.b64encode(svg).decode()
w = sys.argv[3]
def frame(bg, scheme):
    return (f'<div style="background:{bg};color-scheme:{scheme};padding:12px 16px">'
            f'<iframe sandbox="" style="border:0;width:{w}px;height:40px;display:block" src="{src}"></iframe></div>')
open(sys.argv[2], 'w').write('<!doctype html><meta name="color-scheme" content="dark light">'
    '<body style="margin:0">' + frame('#232323', 'dark') + frame('#f4f4f2', 'light') + '</body>')
EOF
"$CHROME" --headless=new --hide-scrollbars --force-dark-mode --virtual-time-budget="$MS" \
  --window-size=$((W + 40)),150 --screenshot="$OUT/check.png" "file://$OUT/page.html" >/dev/null 2>&1
echo "$OUT/check.png"
