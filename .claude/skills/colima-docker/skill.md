---
name: colima-docker
description: Start Colima with optimal settings for Docker on Apple Silicon. Use when starting Docker work, after reboot, or when docker commands fail.
---

# Colima Docker Management

Lightweight Docker runtime for macOS using Apple's Virtualization.Framework.

## Quick Start

```bash
# Start Colima (if not running)
colima start --cpu 4 --memory 8 --disk 60 --vm-type vz --runtime docker

# Check status
colima status

# Verify docker works
docker version
```

## Optimal Settings Explained

| Flag | Value | Why |
|------|-------|-----|
| `--cpu 4` | 4 cores | Good balance for dev work |
| `--memory 8` | 8GB RAM | Enough for most containers |
| `--disk 60` | 60GB | Room for images without wasting space |
| `--vm-type vz` | Virtualization.Framework | Native Apple Silicon, fastest option |
| `--runtime docker` | Docker engine | Standard docker CLI compatibility |

## Common Commands

```bash
# Stop Colima (preserves state)
colima stop

# Restart with different resources
colima stop && colima start --cpu 6 --memory 12 --disk 60 --vm-type vz --runtime docker

# Delete and recreate (loses images)
colima delete && colima start ...

# SSH into the VM
colima ssh

# View resource usage
colima status
```

## Auto-start on Login (Optional)

```bash
# Enable auto-start
brew services start colima

# Disable auto-start
brew services stop colima
```

## Troubleshooting

**Docker commands fail with "Cannot connect to Docker daemon":**
```bash
colima start  # Colima not running
```

**Out of disk space:**
```bash
docker system prune -a  # Clean unused images/containers
```

**Need more resources:**
```bash
colima stop
colima start --cpu 6 --memory 16 --disk 100 --vm-type vz --runtime docker
```

**Check where images are stored:**
```bash
# Images stored in: ~/.colima/
du -sh ~/.colima/
```

## vs Docker Desktop

| Aspect | Colima | Docker Desktop |
|--------|--------|----------------|
| Disk usage | ~500MB-2GB | 3.6GB+ |
| Startup | ~10 seconds | 20-30 seconds |
| Memory | Configurable | Heavier baseline |
| GUI | None (CLI only) | Full GUI |
| Cost | Free forever | Free personal, paid business |
| `docker` command | Same | Same |
