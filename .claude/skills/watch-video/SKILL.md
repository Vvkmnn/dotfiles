---
name: watch-video
description: Use when the user pastes a video link (Instagram reel/post, YouTube, X/Twitter, TikTok, Vimeo, or any yt-dlp-supported site) or a local video file and wants it watched, read, summarized, transcribed, or analyzed. Triggers on "watch this", "what's in this video", "read this reel", instagram.com links, youtube.com links, or any video URL in the prompt. Downloads via yt-dlp (browser-cookie fallback for authed content), transcribes locally (native captions first, else mlx-whisper — audio never leaves the machine), extracts key frames, then reads both.
---

# watch-video

Turn any video URL or local file into a transcript + key frames, then read them.

## Run

```bash
python3 ~/.claude/skills/watch-video/scripts/watch_video.py "<url-or-path>"
```

Optional: `--browser chrome|safari|firefox` to force a cookie source. Default
tries anonymous first, then Chrome → Safari → Firefox cookies (needed for
Instagram saved posts / private content; yt-dlp reads the browser store
directly, nothing is copied or persisted).

## Then

1. Parse the JSON manifest the script prints (video, transcript, frames paths).
2. **Read the transcript file** (`.srt` — timestamped).
3. **Read a sample of frames** — for reels (≤60s) read ~6-10 spread evenly;
   for longer videos read the frames nearest the transcript moments that
   matter to the user's question. Frame filenames are chronological.
4. Answer the user's actual question. Cite timestamps from the SRT when
   pointing at moments.

## Notes

- Re-running the same URL is free — downloads cache per-URL under
  `$TMPDIR/watch-video/<hash>/`.
- Instagram rate-limits anonymous access aggressively; if anonymous fails the
  cookie chain usually succeeds when a logged-in browser session exists.
- Safari cookies may require Full Disk Access for the terminal; prefer Chrome.
- If the manifest has `"transcript": null`, say so and work from frames alone —
  never invent dialogue.
- Whisper model (~1.5 GB, `whisper-large-v3-turbo`) downloads once from
  Hugging Face on first transcription, then cached.

## Upgrade path (noted 2026-07-11 — works for now, explore later)

- **Native fast-path**: macOS 26 `SpeechAnalyzer`/`SpeechTranscriber` — zero
  model download, Neural Engine, much faster on long audio. Needs a ~50-line
  Swift shim (no CLI). Owner input 2026-07-11: content is ~90% English, so
  the right target shape is native-as-fast-path + Whisper-as-fallback (on
  non-English detection or low confidence). Not built yet — current path
  verified working; upgrade when latency actually hurts.
- **Better/faster models**: track Parakeet-MLX (English speed king) and
  whisper-large-v4-class releases; swap is one `--model` flag.
- **Frame selection**: scene-change detection (`ffmpeg -vf select='gt(scene,0.3)'`)
  over fixed-fps sampling if talking-head reels waste frame budget.

## Sources

Pattern reference: [mathiaschu/watch](https://github.com/mathiaschu/watch)
(fork of bradautomates/claude-video) — captions-first transcription, browser
cookie chain, adaptive frame rates all STOLEN from its design after a code
read (2026-07-11). Written fresh here to keep the loop third-party-free and
dotfiles-portable; flip-trigger to adopt upstream: if IG/yt-dlp churn makes
this maintenance-heavy, `/plugin install watch@claude-video` replaces it.

## Deps

`yt-dlp`, `ffmpeg`, `ffprobe` (brew), `mlx_whisper` (`uv tool install
mlx-whisper`, Apple Silicon). The script names anything missing.
