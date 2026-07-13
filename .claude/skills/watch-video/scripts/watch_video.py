#!/usr/bin/env python3
"""watch-video: turn any video URL (Instagram, YouTube, X, TikTok, ...) or
local file into a transcript + key frames Claude can read.

Pipeline (the field-convergent pattern, 2026):
  1. yt-dlp download (720p cap) — anonymous first, then browser-cookie fallback
  2. transcript — native captions if the platform has them (free, instant),
     else local mlx_whisper (Apple Silicon GPU; audio never leaves the machine)
  3. ffmpeg key frames — adaptive count by duration, 512px JPEGs
  4. print a manifest of paths for Claude to Read

Deps: yt-dlp, ffmpeg, mlx_whisper (all on PATH). Stdlib only otherwise.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

# Cookie fallback chain for authed content (Instagram saved posts, private
# videos). Anonymous is tried first — cheapest and usually enough for public
# reels. Cookies are read by yt-dlp directly from the browser store, never
# copied or persisted (ADR-029 discipline: ride logged-in sessions).
BROWSER_CHAIN = ["chrome", "safari", "firefox"]

FRAME_WIDTH = 512  # px — enough for vision models, cheap to read
MAX_FRAMES = 60


def run(cmd: list[str], **kw) -> subprocess.CompletedProcess:
    """Run a command, capturing output; never raises on nonzero exit."""
    return subprocess.run(cmd, capture_output=True, text=True, **kw)


def die(msg: str) -> None:
    print(f"error: {msg}", file=sys.stderr)
    sys.exit(1)


def check_deps() -> None:
    missing = [t for t in ("yt-dlp", "ffmpeg", "ffprobe") if not shutil.which(t)]
    if missing:
        die(f"missing tools: {', '.join(missing)} (brew install ffmpeg yt-dlp)")


def workdir_for(target: str) -> Path:
    """Stable per-URL directory so re-runs of the same link are free."""
    digest = hashlib.sha256(target.encode()).hexdigest()[:12]
    d = Path(tempfile.gettempdir()) / "watch-video" / digest
    d.mkdir(parents=True, exist_ok=True)
    return d


def download(url: str, out: Path, browser: str | None) -> tuple[Path | None, str]:
    """Download video + any native subtitles. Returns (video_path, note)."""
    base = [
        "yt-dlp",
        "--no-playlist",
        "-f", "best[height<=720]/best",
        "--write-subs", "--write-auto-subs",
        # exact langs only — "en.*" floods every auto-translate variant and gets 429'd
        "--sub-langs", "en,en-orig",
        "--convert-subs", "srt",
        "-o", str(out / "video.%(ext)s"),
        "--print-json", "--no-simulate",
        url,
    ]
    attempts: list[list[str] | None] = [None] + (
        [[b] for b in ([browser] if browser else BROWSER_CHAIN)]
    )
    last_err = ""
    for cookies in attempts:
        cmd = list(base)
        note = "anonymous"
        if cookies:
            cmd[1:1] = ["--cookies-from-browser", cookies[0]]
            note = f"cookies:{cookies[0]}"
        proc = run(cmd)
        # Judge by what landed, not exit code — a failed subtitle fetch makes
        # yt-dlp exit nonzero even when the video downloaded fine.
        vids = [p for p in out.glob("video.*")
                if p.suffix not in (".srt", ".vtt", ".json", ".part")]
        if vids:
            (out / "meta.json").write_text(proc.stdout.splitlines()[-1] if proc.stdout else "{}")
            return vids[0], note
        errs = [l for l in (proc.stderr or "").splitlines() if "ERROR" in l]
        last_err = errs[0] if errs else "unknown"
    print(f"download failed after all auth attempts: {last_err}", file=sys.stderr)
    return None, last_err


def transcript(video: Path, out: Path) -> tuple[Path | None, str]:
    """Prefer native captions; fall back to local Whisper on extracted audio."""
    subs = sorted(out.glob("*.srt"))
    if subs:
        return subs[0], "native-captions"
    if not shutil.which("mlx_whisper"):
        return None, "no captions and mlx_whisper missing (uv tool install mlx-whisper)"
    audio = out / "audio.wav"
    if run(["ffmpeg", "-y", "-i", str(video), "-vn", "-ar", "16000", "-ac", "1", str(audio)]).returncode:
        return None, "audio extraction failed"
    proc = run([
        "mlx_whisper", str(audio),
        "--model", "mlx-community/whisper-large-v3-turbo",
        "--output-dir", str(out), "--output-name", "transcript",
        "--output-format", "srt",
    ])
    audio.unlink(missing_ok=True)
    t = out / "transcript.srt"
    return (t, "mlx-whisper") if t.exists() else (None, proc.stderr.strip()[-200:])


def duration_of(video: Path) -> float:
    proc = run(["ffprobe", "-v", "error", "-show_entries", "format=duration",
                "-of", "csv=p=0", str(video)])
    try:
        return float(proc.stdout.strip())
    except ValueError:
        return 0.0


def frames(video: Path, out: Path) -> list[Path]:
    """Adaptive frame extraction: short reels get dense coverage, long videos sparse."""
    dur = duration_of(video)
    count = min(MAX_FRAMES, max(8, int(dur)))  # ~1fps short, capped at 60
    fdir = out / "frames"
    fdir.mkdir(exist_ok=True)
    fps = count / dur if dur > 0 else 1
    run(["ffmpeg", "-y", "-i", str(video),
         "-vf", f"fps={fps:.4f},scale={FRAME_WIDTH}:-1",
         "-q:v", "4", str(fdir / "f%03d.jpg")])
    return sorted(fdir.glob("*.jpg"))


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("target", help="video URL or local file path")
    ap.add_argument("--browser", help="cookie source (chrome|safari|firefox); default: chain")
    args = ap.parse_args()

    check_deps()
    out = workdir_for(args.target)

    local = Path(args.target).expanduser()
    if local.exists():
        video, auth = local, "local-file"
    else:
        if not re.match(r"https?://", args.target):
            die(f"not a URL and not a local file: {args.target}")
        cached = [p for p in out.glob("video.*")
                  if p.suffix not in (".srt", ".vtt", ".json", ".part")]
        if cached:
            video, auth = cached[0], "cached"
        else:
            video, auth = download(args.target, out, args.browser)
    if video is None:
        die(f"could not obtain video ({auth})")

    t_path, t_how = transcript(video, out)
    frame_paths = frames(video, out)

    manifest = {
        "video": str(video),
        "auth": auth,
        "duration_s": round(duration_of(video), 1),
        "transcript": str(t_path) if t_path else None,
        "transcript_via": t_how,
        "frames": [str(p) for p in frame_paths],
        "frame_count": len(frame_paths),
    }
    print(json.dumps(manifest, indent=2))


if __name__ == "__main__":
    main()
