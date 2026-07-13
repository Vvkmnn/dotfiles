# badge.sh — the fleet's shared iconography contract: a machine's power-tier SHAPE and signature HUE.
# THE single source of truth for both consumers, so the tmux status bar and the shell suite always
# agree on how a machine looks:
#   • ~/.config/tmux/machine_badge.sh  (bash)  — the status-bar pills
#   • ~/.fleet                         (zsh)   — the `vw` fleet tree / picker
# Pure POSIX sh (no bashisms/zshisms) so both shells source it verbatim. Glyphs are octal UTF-8 bytes
# (strip-safe in any editor/transport, verified round-trip), same discipline as machine_badge.sh.

# fleet_shape CORES — power-tier glyph from core count (more sides = more power):
#   △≤8  □≤10  ⬠≤12  ⬡≤16  ○≤24  ☆>24.  Non-numeric/empty CORES (an asleep peer) → hollow ◇.
fleet_shape() {
	case "$1" in
		''|*[!0-9]*) printf '\342\227\207'; return ;;   # ◇ unknown
	esac
	if   [ "$1" -le 8 ];  then printf '\342\226\263'     # △ triangle
	elif [ "$1" -le 10 ]; then printf '\342\226\241'     # □ square
	elif [ "$1" -le 12 ]; then printf '\342\254\240'     # ⬠ pentagon
	elif [ "$1" -le 16 ]; then printf '\342\254\241'     # ⬡ hexagon
	elif [ "$1" -le 24 ]; then printf '\342\227\213'     # ○ circle
	else                       printf '\342\230\206'     # ☆ star
	fi
}

# fleet_hex NAME — a machine's Kanagawa signature colour as 6 hex chars (NO leading '#'). Curated per
# machine so two same-chip boxes never collide; an unrecognised host still gets a unique, stable hue by
# hashing its name (HLS 0.64/0.45, md5 % 360 — identical to the badge's original fallback). Grey if
# python3 is missing.
fleet_hex() {
	case "$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')" in
		*air*)    printf '7aa89f' ;;   # teal
		*mini*)   printf 'e0a45c' ;;   # amber
		*neo*)    printf '9d7cc9' ;;   # violet
		*studio*) printf 'c98a6b' ;;   # clay (reserved)
		*)  _fh=$(python3 - "$1" 2>/dev/null <<'PY'
import sys, colorsys, hashlib
h = int(hashlib.md5(sys.argv[1].encode()).hexdigest(), 16) % 360
r, g, b = colorsys.hls_to_rgb(h/360, 0.64, 0.45)
print("%02x%02x%02x" % (round(r*255), round(g*255), round(b*255)))
PY
)
		    printf '%s' "${_fh:-9a9a9a}" ;;
	esac
}
