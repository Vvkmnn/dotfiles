# Sketchybar Configuration

Minimal status bar for macOS — unified Swift daemon, native animations, solar-aware progress.

## Architecture

```
sketchybarrc                          # item definitions, color palette, cascade launcher
helpers/bar-daemon.swift -> bar-daemon # single daemon: 15 items, macmon pipe, NWPathMonitor
plugins/startup_cascade.sh            # boot animation: edges-to-center fade+expand
plugins/internet_animate.sh           # disconnect/reconnect animations (BUGGY — see Bugs)
plugins/wake_fadein.sh                # wake/unlock fade (commented out — needs lock fade-out)
plugins/lock_fadeout.sh               # lock/sleep fade (commented out — needs wake pair)
plugins/bar_colors.sh                 # shared Kanagawa color constants + dynamic space query
plugins/space.sh                      # space indicators (yabai + jq, single handler)
```

## Bar Items (15 managed by bar-daemon)

| Item | Position | Source | Update |
|------|----------|--------|--------|
| logo | left | background.image | static |
| space.1-N | left | space.sh | event-driven (dynamic count) |
| location | left | ipinfo.io/country | NWPathMonitor change |
| connection | left | NWConnection TCP | 30s timer |
| network_down/up | left | getifaddrs | 1s timer |
| graph_down/up | left | getifaddrs | 1s timer |
| progress | right | slider, day-of-year | 60s timer |
| progress_icon | right | clock face / sunrise / sunset | 60s timer |
| clock_time | right | HH:MM | 60s timer |
| battery | right | IOKit | 1s change detection |
| disk | right | statvfs | 1s change detection |
| cpu, gpu, temp, memory, power | right | macmon pipe | ~3s interval |

## Animation System

### Startup Cascade (WORKING)
Items born transparent + collapsed (`width=0`). Cascade script fades from edges toward notch:
- Left: logo -> spaces -> location -> connection -> network -> graphs
- Right: clock -> progress -> battery -> disk -> memory -> cpu -> gpu -> power -> temp
- Both sides simultaneously, meeting at the notch
- `tanh` for width expansion, `sin` for color fades, `D=40 W=0.35`
- `space_handler script=""` during cascade to prevent space.sh interference
- bar-daemon launched at end of cascade, `startupSmooth=true` for first 3s
- `sketchybar --update` runs in background after daemon starts

### Internet Disconnect/Reconnect (BUGGY — see Bugs section)
- bar-daemon detects via NWPathMonitor (`path.status`), `updateNetwork()` (`getifaddrs`), and `updateConnection()` (`finalize()`)
- Triggers `sketchybar --trigger internet_disconnect` or `internet_reconnect`
- `internet_animate.sh` handles animations via sketchybar event subscription
- SIGUSR2 = persistent lock on network items, SIGUSR1 = unlock + smooth + location refresh
- Disconnect: inside-out collapse, globe-strikeout icon (U+F01E8)
- Reconnect: globe fade, outside-in expand, regular globe (U+F059F) as placeholder

### Signal Protocol
- **SIGUSR1**: unlock network items + `startupSmooth=true` for 3s + `updateLocation(force: true)`
- **SIGUSR2**: persistent lock on network items (stays until SIGUSR1)
- Both handled on `DispatchQueue.main` via `DispatchSource.makeSignalSource`

### Lock/Wake (DISABLED — commented out in sketchybarrc)
- `lock_fadeout.sh`: kills bar-daemon + fades all items out on `com.apple.screenIsLocked` / `system_will_sleep`
- `wake_fadein.sh`: fades in + restarts bar-daemon on `system_woke`
- Disabled because wake without prior lock looks ugly (items already visible)

## Progress Slider

Native `--add slider` with solar-aware features:
- Outline clock faces (U+F144B-F1456) round to nearest hour (`minute >= 30 ? hour + 1 : hour`)
- Sunrise: gold (0xffE8A838) with half-circle icon, first 30 min of sunrise hour
- Sunset: blue (0xff4A90D9) with half-circle icon, first 30 min of sunset hour
- Hour flash: red (0xffE74C3C) at minute 0
- Normal: white highlight, gray day numbers
- Solar: Spencer formula + longitude correction for solar noon
- Coordinates from machine timezone, NOT VPN location
- Slider properties set via separate Process call (startupSmooth interferes)

## Color Palette (Kanagawa Wave)

```
kDim       0xff727169   fujiGray — idle metrics, network stats, graphs
kWhite     0xffDCD7BA   fujiWhite — clock, slider highlight, battery
kOldWhite  0xffC8C093   oldWhite — spaces, location, connection
kRed       0xffE74C3C   alerts, bad latency, hour flash
kOrange    0xffFFA500   warnings
kPeach     0xffFF5D62   peachRed — power mid-tier
kGold      0xffE8A838   sunrise
kBlue      0xff4A90D9   sunset
```

Transparent versions use `0x00` prefix with SAME RGB to avoid intermediate color flash during animation.

## Key Files

### Active
- `sketchybarrc` — bar config, items born transparent/collapsed, event registration
- `helpers/bar-daemon.swift` — unified daemon (~1300 lines), all 15 items + NWPathMonitor + macmon
- `plugins/startup_cascade.sh` — boot cascade animation (dynamic space count)
- `plugins/internet_animate.sh` — disconnect/reconnect animations (buggy)
- `plugins/bar_colors.sh` — shared Kanagawa constants + `get_spaces()` helper
- `plugins/space.sh` — space indicators, disabled during cascade
- `plugins/lock_fadeout.sh` — lock/sleep fade-out (disabled)
- `plugins/wake_fadein.sh` — wake/unlock fade-in (disabled)

### Superseded (kept for reference)
- `helpers/metrics-daemon.swift`, `net-stats.swift`, `net-monitor.swift`, `progress-clock.swift`, `wifi-signal.swift`
- `plugins/battery.sh`, `disk.sh`, `connection.sh`, `location.sh`

## Build

```bash
cd ~/.config/sketchybar/helpers
swiftc -O -o bar-daemon bar-daemon.swift
```

Frameworks linked automatically: Network, IOKit, CoreWLAN, SystemConfiguration.

## Dotfiles

Tracked via bare git repo at `~/.dotfiles/`:
```bash
cd $HOME && /usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME add .config/sketchybar/...
```

## Gotchas

- `sketchybar --update` triggers ALL subscribed scripts — disable space_handler before cascade
- `$TRANSPARENT` is `0x00000000` — animating to white goes through gray. Use `0x00FFFFFF` (transparent white)
- Graph `graph.color` alpha doesn't fully hide waveforms — use `drawing=off`
- `drawing` is NOT animatable (boolean) — use `width=0` + transparent colors to fake it
- `width=dynamic` as animation target = smooth expand to natural size
- Slider properties must be set WITHOUT `--animate` (separate Process call in bar-daemon)
- `networkActive` must be initialized via `readNetBytes()` before `updateLocation()` runs
- `getifaddrs` IFF_RUNNING lags 1-2s behind macOS WiFi state — NWPathMonitor detects faster
- `startupSmooth` prepends `--animate tanh 30` to ALL `sketchybar()` calls including `--trigger` — use `sketchybarDirect()` for triggers
- NWPathMonitor fires on main queue with 1s debounce + 3s throttle

## Bugs (to revisit)

### Internet Disconnect/Reconnect Animation Unreliable
**Status**: Not working reliably. Preview worked perfectly in bash but real implementation fails intermittently.

**What should happen**:
- WiFi off: network section (location, connection, arrows, graphs) collapses inside-out with fade animation, ending with globe-strikeout icon
- WiFi on: globe fades out, items expand outside-in with fade, country code refreshes

**What actually happens**:
- Disconnect: some items flash/persist (arrows, graphs stay visible), animation plays partially or out of order
- Reconnect: items pop in without animation, country code never returns

**Root causes identified (5)**:
1. **Color mismatch**: animation script colors must exactly match bar-daemon's Kanagawa palette (transparent version = `0x00` + same RGB). Any RGB mismatch causes visible flash during fade
2. **`updateLocation()` never called after reconnect**: neither `updateNetwork()` nor NWPathMonitor reconnect paths call it. SIGUSR1 handler now does, but timing unclear
3. **`startupSmooth` contaminates `--trigger`**: `sketchybar()` helper prepends `--animate tanh 30` to ALL calls. Fixed with `sketchybarDirect()` for triggers
4. **Timed auto-unlock races with SIGUSR2**: NWPathMonitor disconnect had 5s auto-unlock that fired during animation. Fixed — now persistent lock only
5. **Three detection paths race**: `updateNetwork()`, NWPathMonitor, `updateConnection()` all independently detect state changes. Guards prevent double-fire but timing is fragile

**Why the bash preview worked but real implementation doesn't**:
The approved preview killed bar-daemon (`pkill -f bar-daemon`) before running the animation. With no daemon writing to items, the animation played uncontested. In the real implementation, bar-daemon stays alive and its 1s timer, NWPathMonitor, and async callbacks (finalize(), URLSession) can write to items between animation steps despite `networkItemsLocked` guards.

**Attempted fixes**:
- `networkItemsLocked` flag with guards in all 3 functions + async callbacks
- SIGUSR2 persistent lock (no timer expiry)
- SIGUSR1 unlock + smooth + location refresh
- `sketchybarDirect()` for trigger commands
- `activeTickCount` debounce for reconnect (prevent false reconnect during interface oscillation)
- `guard internetReachable` before item writes (prevent writes during getifaddrs lag)

**Possible next approach**:
The only approach that reliably worked was killing bar-daemon entirely during the animation. Consider: on disconnect, kill ONLY the network-related timers/subsystem within bar-daemon (not the whole process). Or: accept the simpler approach of killing bar-daemon for the 2-3s animation window and restarting it after, accepting the brief gap in battery/disk/metric updates.

**Key insight**: the fundamental tension is that bar-daemon runs a 1s timer that writes to network items, and the animation takes 2s with sleep gaps between steps. No flag-based locking fully prevents all async code paths from writing during those gaps. The cleanest solution may be architectural: move the animation INTO bar-daemon using `DispatchQueue.main.asyncAfter` chains (no external script, no signal delivery gaps, no async callback races — everything on the same serial queue).
