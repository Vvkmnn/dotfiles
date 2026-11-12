# Fleet convergence — mechanics + traps

Full commands behind the **Fleet Convergence** loop in SKILL.md. Goal: one shared `v-macos`, same
experience everywhere — merge both machines' intent into ONE value; machine-tune only when a real
constraint forces it (never a fork/branch). Load this when you're actually reconciling drift.

## 1. Audit every machine (measure, don't ask)
```bash
AUDIT='D(){ /usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME "$@"; }
  D -c credential.helper= fetch "https://github.com/Vvkmnn/dotfiles.git" "+refs/heads/v-macos:refs/remotes/origin/v-macos" >/dev/null 2>&1
  echo "$(scutil --get ComputerName) vs-origin=[$(D rev-list --left-right --count HEAD...origin/v-macos)] dirty=$(D diff --name-only|wc -l)"
  D log --oneline -4; ls -t $HOME/.claude/plans/*.md 2>/dev/null|head -3|while read p;do grep -m1 "^# " "$p";done'
for ip in <air-ip> <mini-ip>; do ssh -A "$ip" "$AUDIT"; done   # neo runs it locally
```
ahead/behind = who's stale + who has unpushed work; the plan list = **who's editing what NOW** (clobber risk).

## 2. Detect true conflicts (the cwd trap)
A **bare** repo's git inherits `cwd = the git-dir`, so a pathspec resolves against the git-dir (empty
diff) and bare `HEAD` is ambiguous (a real file). **Always `git -C "$HOME"`.** NEVER `git status -uall`
— with `showUntrackedFiles=no` overridden it scans the TCC-protected home dir → "Operation not
permitted" → hangs.
```bash
D(){ /usr/bin/git -C "$HOME" --git-dir="$HOME/.dotfiles" --work-tree="$HOME" "$@"; }
comm -12 <(D diff --name-only|sort -u) <(D diff --name-only <base>..origin/v-macos|sort -u)   # = true conflicts
```

## 3. Merge into ONE (best-of-both)
Pull all machines' versions; understand WHY each diverged (favor recent, assume drift — but LEARN from
the older side; it often encodes a reason/workaround). Synthesize both intents into a single value.
`git merge origin/v-macos` auto-merges non-overlapping hunks — then **verify both intents survived**
(grep a marker from EACH side; a textual-clean merge can still drop a semantic). A GENUINE per-host
constraint becomes a minimal in-config adjustment (`~/.ai/scale`, `$SSH_CONNECTION`-gate) — never a fork.
Don't `git add -A` (a bare repo's `-A` = the whole home dir); add named files.

### Never merge in the live tree (2026-11-12)
The work tree is `$HOME`, so a conflicted `git merge` writes `<<<<<<<` markers straight into files in
use. On 2026-11-12 a merge run in place put markers into `~/.claude/settings.json`; every Claude session
that read it in that window lost its settings (statusline, theme, hooks). Merge in a throwaway clone and
let the home tree only ever fast-forward:
```bash
D merge-tree --write-tree --name-only v-macos origin/v-macos        # dry run: lists conflicts, touches nothing
W=~/.cache/dotfiles-merge; git clone --no-checkout ~/.dotfiles "$W" && cd "$W"
git config filter.git-crypt.smudge cat; git config filter.git-crypt.clean cat; git config filter.git-crypt.required false
git fetch ~/.dotfiles refs/remotes/origin/v-macos:refs/heads/github refs/heads/v-macos:refs/heads/local
git checkout -b merge-fleet local && git merge --no-commit --no-ff github
# resolve, then: jq empty settings.json · bash -n / zsh -n / node --check · no markers · commit
D fetch "$W" merge-fleet:refs/heads/merge-fleet-<date> && D merge --ff-only merge-fleet-<date>
```
- The `cat` filters keep git-crypt files as ciphertext in the clone, so their blobs pass through
  unchanged (check: `git cat-file blob :<path> | head -c 9` prints `GITCRYPT`).
- A fast-forward writes each file once, in its final form, and refuses if an untracked file is in the way.
- After a merge that moves a folder, look for untracked symlinks still pointing at the old path
  (the theme move to `~/.config/theme` broke `~/.config/lazygit/config.yml` and `~/.config/yazi/theme.toml`).

## 4. Push + sync (the footguns)
- **Explicit push:** `git push origin v-macos`. Bare `git push` + `push.default=matching` shoves dead
  per-machine branches → confusing "failed to push some refs". Set `push.default=simple` fleet-wide.
- **Headless can't self-sign** a github push: from a GUI machine `ssh -A <host> 'git … push'` forwards
  YOUR 1P agent → the remote signs → Touch-ID on you (the `vpush`/`vpull` verbs).
- **Remote merge over ssh -A → ABORT on conflict**, never leave a remote half-merged:
  `ssh -A <host> 'D(){…}; if D merge origin/v-macos --no-edit >/tmp/m 2>&1; then D push origin v-macos; else D merge --abort; echo CONFLICT-owner-resolves; fi'`

## 5. Don't clobber a live session
A file modified in your tree you didn't touch this session belongs to another worker (the audit's plan
column names them). Commit it as its own honest scope, or leave it — never fold another session's WIP silently.

## Traps log
Grew from a real convergence (2026-07-14): cwd=git-dir trap · `-uall` timeout · `push.default=matching`
· verify-both-intents-survived · abort-remote-merge-on-conflict · concurrent-editor flagging. Add each new one.
2026-11-12: in-place merge wrote conflict markers into the live `settings.json` · untracked symlinks left
dangling by a folder move.
