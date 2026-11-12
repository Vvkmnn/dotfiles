# `op` CLI cheatsheet + secret-reference patterns

The 1Password CLI (`op`, v2) as **auth transport** and, optionally, **secret injection**. The
injection patterns (secret references / `op run` / `op inject`) are what the community 1P skills
cover; they're here for when fleet MCP/API tokens move out of the git-crypt'd public repo to runtime.

## Session

```
op signin                       # interactive; biometric if the desktop app integration is on
op signin --account <shorthand> # pick one of several accounts
op whoami                       # confirm who / which account is active
```

## Secret references — the core idea

A secret reference is a URI that points at a field without exposing the value:
```
op://<vault>/<item>/[section/]<field>
# e.g.  op://AI/GitHub Token/token
```
Three ways to resolve them at runtime (secrets stay in memory, never on disk):

```
# 1. read one value to stdout (or a file)
op read "op://AI/GitHub Token/token"

# 2. run a process with references resolved into its env (1P's MCP-hardening pattern)
#    .env holds POINTERS, safe to commit:  GITHUB_TOKEN=op://AI/GitHub Token/token
op run --env-file=.env -- <command>          # e.g. op run --env-file=.env -- claude

# 3. inject references into a config/template file
op inject -i config.tpl -o config.out         # config.tpl contains op://… placeholders
```

Rule of thumb (from the community skill): **commit the `.env.tpl` with references, never the resolved
`.env`.** Avoid `eval $(op run …)` — it leaks secrets into shell history/subshells.

## Items & documents

```
op item get "<name>" --fields <field>         # read a single field
op item get "<name>" --format json            # full item as JSON
op document get "Dotfiles" --output <file>     # fetch a stored document (e.g. the git-crypt key)
op run -- <command>                            # run a privileged command with 1P auth (e.g. xcodes)
```

## Shell plugins — biometric-backed `gh` / git (no token on disk)

```
op plugin init gh          # wraps `gh` so it authenticates via 1P (Touch-ID), no OAuth token in keyring
op plugin list             # what's configured
# then source the plugin's init from your shell rc so it's active in every shell
```
This is the biometric path for `gh`/git pushes and replaces a gh OAuth token sitting in the keyring.

## git commit signing with the 1P SSH key (optional, first-class)

Git ≥ 2.34 can sign commits with an SSH key — no GPG. 1P can configure this for you: open the SSH key
in the app ▸ **"Configure Commit Signing"**, which sets:
```
git config --global gpg.format ssh
git config --global user.signingkey "<your ed25519 public key>"
git config --global commit.gpgsign true
git config --global gpg.ssh.program "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
```
Result: every commit is signed by the 1P-held key, Touch-ID on demand, private key never on disk.
(Optional — decide per fleet policy; not required for auth.)
