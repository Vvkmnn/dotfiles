# Karabiner Screenshot System

Auto-resizing screenshot workflow optimized for Claude Code conversations.

## Quick Reference

| Shortcut | Action |
|----------|--------|
| `right_cmd` alone | Fullscreen screenshot → Resize to 700px → Clipboard |
| `ctrl + right_cmd` | Area screenshot → Resize to 700px → Clipboard |
| `shift + right_cmd` | macOS screenshot options (video/other) |
| `right_cmd + space` | Paste (Ctrl+V) |

## Directory Structure

```
~/.config/karabiner/
├── karabiner.json                 # Karabiner config with screenshot rules
├── KARABINER.md                   # This file
└── scripts/
    ├── smart-screenshot-resize.sh # Main screenshot script (has full setup docs)
    ├── impbcopy                   # Clipboard copy utility (compiled)
    └── resize-and-paste-test.sh   # Experimental (NOT IN USE)
```

## Rule Ordering (Critical!)

Karabiner processes rules **top-to-bottom**. The `optional: ["any"]` modifier means "match with ANY other modifier keys", so specific modifiers MUST come first.

### ✓ Correct Order
```
1. shift + right_cmd     (most specific)
2. ctrl + right_cmd      (specific)
3. right_cmd + space     (specific combo)
4. right_cmd optional:any (general - catches "alone")
```

### ✗ Wrong Order (Broken)
```
1. right_cmd optional:any → Catches EVERYTHING including ctrl+right_cmd
2. ctrl + right_cmd       → Never reached!
```

**Symptom**: ctrl+right_cmd does nothing or works intermittently.

**Fix**: Move specific modifier rules above the `optional: ["any"]` rule in `karabiner.json`.

## How It Works

1. **Press shortcut** → Triggers `smart-screenshot-resize.sh` (or `-i` for area)
2. **Screenshot captured** → Saves to `/tmp/screenshot-$$.png`
3. **Auto-resize** → `sips --resampleHeightWidthMax 700` maintains aspect ratio
4. **Copy to clipboard** → `impbcopy` for reliable clipboard access
5. **Cleanup** → Temp file removed immediately

**Why 700px?** Token efficiency (10-12 screenshots per conversation) + readability.

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `ctrl + right_cmd` does nothing | Fix rule ordering - specific modifiers before `optional: any` |
| Script not running | Verify path in `karabiner.json` matches script location |
| Image not resized | Check `impbcopy` executable: `ls -lh scripts/impbcopy` |
| No screenshot sound | Grant Karabiner screenshot permissions in System Settings |

## Testing

```bash
# Take screenshot (any method), then verify resize:
pngpaste /tmp/test.png && \
sips -g pixelWidth -g pixelHeight /tmp/test.png | grep pixel && \
rm /tmp/test.png

# Expected: pixelWidth: 700 (or less for portrait)
```

## Full Documentation

See `scripts/smart-screenshot-resize.sh` header comments for:
- Complete setup instructions
- Dependencies and compilation steps
- Detailed testing procedures
- Resize dimension adjustment
- Research sources and credits
