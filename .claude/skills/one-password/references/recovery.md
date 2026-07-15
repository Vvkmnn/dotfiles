# 1Password recovery runbook

Restore 1Password on a broken or fresh fleet machine. Each scenario is independent — jump to the one
that matches the symptom.

## SSH agent: `ssh-add -l` shows "no identities" (or git push falls back to password)

The near-certain cause is the env var, not a missing key. Confirm and fix:

1. **Is the agent itself alive?** Bypass the env and ask the 1P socket directly:
   ```
   SSH_AUTH_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock" ssh-add -l
   ```
   - Keys listed → the agent is fine; the env var is wrong. Go to step 2.
   - "Connection refused" → the **1P desktop app isn't running**. Launch it, unlock, retry.
   - Socket missing → 1P ▸ Settings ▸ Developer ▸ **"Use the SSH agent"** is OFF. Turn it ON.

2. **Fix the env var** (`~/.zshenv`): the guard must gate on the session, not the socket —
   `[[ -n "$SSH_CONNECTION" ]] || export SSH_AUTH_SOCK=…1p sock…`. A bare `[[ -S "$SSH_AUTH_SOCK" ]]`
   guard silently fails because macOS pre-sets `SSH_AUTH_SOCK` to an empty-but-valid launchd agent.
   (Full explanation: `~/.zshenv:92` comment + SKILL.md § SSH agent.)

3. **Re-source / new shell**, then verify: `echo $SSH_AUTH_SOCK` = the 1P path (not `/var/run/…launchd…`),
   `ssh-add -l` lists the key, `ssh -T git@github.com` → "Hi <you>!" with a Touch-ID prompt.

4. **Key not on github?** Register the machine's public key:
   `SSH_AUTH_SOCK=…1p sock… ssh-add -L` → copy the ED25519 line → `gh ssh-key add - --title "<machine> (1Password)"`
   (or paste in github ▸ Settings ▸ SSH keys). Use a per-machine title so it's individually revocable.

## git-crypt won't unlock (encrypted dotfiles look like binary garbage)

The git-crypt symmetric key lives in 1P as the `Dotfiles` document:
```
op document get Dotfiles --output /tmp/dotfiles.key
git-crypt unlock /tmp/dotfiles.key      # run from the work-tree
rm /tmp/dotfiles.key                     # don't leave the key on disk
```
Verify: a previously-encrypted tracked file (e.g. the MCP config) is now readable plaintext.
(Reference: `~/.ai/setup:268`.)

## Browser extension missing or drifted

- **Safari** — install/refresh the App-Store extension and kill version-skew:
  ```
  mas install 1569813296     # "1Password for Safari" (if absent)
  mas upgrade 1569813296     # if the main app has out-run the extension
  ```
  Then Safari ▸ Settings ▸ Extensions → enable "1Password", and in the 1P app turn ON
  "Integrate with 1Password in the browser". Re-enable is required after a MAJOR update (~once/macOS major).
- **Mullvad Browser** — the 1P add-on is AMO `1password-x-password-manager`, guid
  `{d634138d-c276-4fc8-924b-40a0ea21d284}`, auto-updating install URL
  `https://addons.mozilla.org/firefox/downloads/latest/1password-x-password-manager/latest.xpi`.
  A `policies.json` (`ExtensionSettings` → `force_installed`) works only from inside the
  `/Applications/Mullvad Browser.app/Contents/Resources/distribution/` bundle — wiped on Mullvad
  update, not a tracked dotfile. **Pragmatic path: install once from AMO**; it persists in the
  profile across updates. (Firefox is not installed.)
- **Chrome** — no MDM force-install path: open the Chrome Web Store 1Password page and click **Add**, once.

## Fresh machine — order of operations

1. Install: 1Password (direct-download cask) + `1password-cli` + `git-crypt` + `mas`.
2. **Unlock the 1P app** (manual gate — biometric enrolment / sign-in).
3. Enable Developer ▸ "Use the SSH agent" + "Integrate with 1Password CLI" + "Integrate with other apps".
4. `op signin` → `op whoami` confirms CLI auth.
5. git-crypt unlock (above) so encrypted dotfiles decrypt.
6. Verify the SSH agent (above); register the machine's key on github if new.
7. Browser extensions (above) — `mas install` the Safari one, `policies.json` for Firefox/Mullvad.
8. `~/.ai/setup doctor` → the 1Password section should be all-green; it lists any remaining manual gates.
