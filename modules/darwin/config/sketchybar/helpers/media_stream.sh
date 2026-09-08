#!/bin/sh
# Event provider for items/media.lua. nowplaying-cli and sketchybar's built-in
# media_change event both went dark with macOS 15.4 (FelixKratz/dotfiles#76,
# FelixKratz/SketchyBar#708); media-control (brew) still works and streams JSON.
# /opt/homebrew/bin is not on the sketchybar agent's PATH, hence the full path.
ART=/tmp/sketchybar_media_artwork
/opt/homebrew/bin/media-control stream --no-diff --debounce=250 | while IFS= read -r line; do
  # Covers come at 600px+; shrink to 64px (drawn at scale 0.5 = 32pt, crisp on
  # retina). Decode and resize a temp file, then mv it into place so the bar never
  # redraws a half-written or still full-size file.
  printf '%s' "$line" | jq -r '.payload.artworkData // empty' | base64 -d > "$ART.tmp" 2>/dev/null
  if [ -s "$ART.tmp" ] && sips -Z 64 "$ART.tmp" >/dev/null 2>&1; then mv -f "$ART.tmp" "$ART"; else rm -f "$ART" "$ART.tmp"; fi
  eval "$(printf '%s' "$line" | jq -r '.payload | @sh "sketchybar --trigger media_update APP=\(.bundleIdentifier // "") PLAYING=\(.playing // false) ARTIST=\(.artist // "") TITLE=\(.title // "")"')"
done
