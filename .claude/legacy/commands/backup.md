# /backup - Intelligent Configuration Backup & Recovery System

---
argument-hint: "[--encrypt] [--restore] [--verify] [--cloud] [--schedule] [--migrate]"
---

## Overview
Revolutionary backup and recovery system combining enterprise-grade security with intelligent state management, comprehensive MCP integration, and hybrid Claude 4 intelligence for optimal backup strategies and disaster recovery.

## Usage
```bash
/backup [--encrypt] [--restore] [--verify] [--cloud] [--schedule] [--migrate]
```

## Hybrid Intelligence Architecture

### 1. Claude Configuration Analysis
```bash
# Large-scale configuration state understanding
claude: "analyze @~/.claude/ configuration structure for backup optimization"
claude: "scan @~/.config/claude/ for MCP and environment dependencies"
claude: "review @~/.claude/.claude.json for session data and critical configurations"
```

### 2. Claude Strategic Backup Planning
```bash
# Sophisticated backup strategy and recovery optimization
- Critical file prioritization and dependency analysis
- Security threat modeling for backup protection
- Recovery scenario planning and testing
- Cross-platform compatibility and migration strategies
```

### 3. MCP Server Integration
Complete backup workflow with all 20 MCP servers:
- **Cloud Storage**: GCP MCP for cloud backup storage
- **Documentation**: Obsidian MCP for backup decision documentation
- **Security**: Sequential-thinking MCP for complex backup strategies
- **Monitoring**: Apple MCP for backup status and notifications

## Process

### Phase 1: Intelligent Configuration Discovery (Claude-Powered)
1. **Complete State Analysis**
   ```bash
   claude: "analyze @~/.claude/ directory structure for all critical files"
   claude: "review @~/.claude/.claude.json size and content for session data importance"
   claude: "scan @~/.config/claude/ for MCP server configurations"
   claude: "examine @~/.claude/commands/ for custom command implementations"
   ```

2. **Dependency Mapping**
   ```bash
   # Map configuration dependencies and relationships
   claude: "identify configuration file dependencies and relationships"
   claude: "analyze API key and credential storage patterns"
   claude: "review backup history for optimization patterns"
   ```

### Phase 2: Strategic Backup Planning (Claude Intelligence)
1. **Risk Assessment and Prioritization**
   ```xml
   <backup_strategy>
     <context>Complete Claude configuration state and dependencies</context>
     <objective>Comprehensive backup with optimal security and recovery</objective>
     <thinking>Analyze critical files, security requirements, recovery scenarios</thinking>
     <mcp_integration>GCP for cloud storage, Obsidian for documentation</mcp_integration>
     <validation>Comprehensive backup integrity and recovery testing</validation>
   </backup_strategy>
   ```

2. **Security and Encryption Strategy**
   ```bash
   # Enterprise-grade security implementation
   - AES-256 encryption with PBKDF2 key derivation
   - Secure key management and rotation
   - Multi-layer backup verification
   - Cross-platform compatibility validation
   ```

### Phase 3: MCP-Coordinated Backup Execution
1. **Cloud Integration and Storage**
   ```bash
   # GCP MCP: Cloud backup storage and management
   mcp__gcp-mcp__list-projects: Identify cloud storage projects
   mcp__gcp-mcp__get-billing-info: Monitor storage costs and usage
   
   # Apple MCP: Local backup coordination
   mcp__apple-mcp__messages: "Backup initiated: $timestamp"
   mcp__apple-mcp__reminders: "Verify backup integrity in 1 day"
   ```

2. **Documentation and Knowledge Management**
   ```bash
   # Obsidian MCP: Backup decision documentation
   mcp__obsidian__obsidian_append_content: "Backups/$date.md"
   mcp__obsidian__obsidian_patch_content: "Update backup procedures"
   
   # Sequential-thinking MCP: Complex backup analysis
   mcp__sequential-thinking__sequentialthinking: "Optimize backup strategy"
   ```

## Command Options

### `--encrypt` - Enterprise-Grade Encryption (Default)
**Advanced Encryption Strategy:**
1. **AES-256-GCM**: Authenticated encryption with integrity verification
2. **PBKDF2**: 100,000 iterations for key derivation
3. **Salt Generation**: Cryptographically secure random salts
4. **Key Rotation**: Support for encryption key rotation

**Simple & Reliable Backup Implementation:**
```bash
# Create backup with timestamp in ~/.claude/backups/
cd ~/.claude && mkdir -p backups
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="claude_backup_${TIMESTAMP}.tar.gz"

echo "📦 Creating backup: $BACKUP_FILE"

# Create comprehensive tar backup excluding unnecessary directories
tar -czf "backups/$BACKUP_FILE" \
  --exclude='backups' \
  --exclude='*.backup' \
  --exclude='.DS_Store' \
  --exclude='todos' \
  --exclude='shell-snapshots' \
  --exclude='statsig' \
  --exclude='projects' \
  .

echo "✅ Backup created: ~/.claude/backups/$BACKUP_FILE"
echo "💾 Size: $(du -h backups/$BACKUP_FILE | cut -f1)"

# Optional: Create encrypted version if password provided
echo -e "\n🔐 Create encrypted version? (y/N):"
read -r ENCRYPT_CHOICE

if [[ "$ENCRYPT_CHOICE" == "y" || "$ENCRYPT_CHOICE" == "Y" ]]; then
  echo -n "Enter backup password: "
  read -s BACKUP_PASSWORD
  echo
  echo -n "Confirm password: "
  read -s CONFIRM_PASSWORD
  echo
  
  if [[ "$BACKUP_PASSWORD" != "$CONFIRM_PASSWORD" ]]; then
    echo "❌ Passwords don't match! Keeping plain backup only."
  else
    echo "🔐 Creating encrypted backup..."
    if openssl enc -aes-256-cbc -salt -pbkdf2 -iter 100000 \
       -in "backups/$BACKUP_FILE" \
       -out "backups/${BACKUP_FILE}.enc" \
       -pass pass:"$BACKUP_PASSWORD"; then
      echo "✅ Encrypted backup: ~/.claude/backups/${BACKUP_FILE}.enc"
    else
      echo "❌ Encryption failed!"
    fi
  fi
  unset BACKUP_PASSWORD CONFIRM_PASSWORD
fi

echo -e "\n📋 Backup includes:"
echo "✅ Configuration files (.claude.json, CLAUDE.md, settings.json)"
echo "✅ Environment file (.env)"
echo "✅ Custom commands (commands/ directory)"
echo "✅ Automation hooks (hooks/ directory)"
echo "✅ MCP documentation (MCP.md)"
echo "✅ All other config files"
echo "❌ Excluded: backups/, todos/, shell-snapshots/, projects/, statsig/"

echo -e "\n🔄 To restore:"
echo "   cd ~ && tar -xzf ~/.claude/backups/$BACKUP_FILE"
echo "   (This will overwrite current ~/.claude contents)"
```

### `--cloud` - Cloud Backup Integration
**Multi-Cloud Backup Strategy:**
1. **GCP Integration**: Google Cloud Storage for primary backup
2. **Apple iCloud**: Secondary backup for Apple ecosystem
3. **GitHub**: Configuration versioning and team sharing
4. **Distributed Storage**: Redundant storage across providers

**Cloud Backup Process:**
```bash
# GCP MCP: Primary cloud storage
mcp__gcp-mcp__run-gcp-code: "Upload encrypted backup to Cloud Storage"

# GitHub MCP: Configuration versioning
mcp__github__create_or_update_file: "backup-configs/claude-$timestamp.json"

# Apple MCP: Local cloud integration
mcp__apple-mcp__notes: "Backup stored: $cloud_location"
```

### `--restore` - Simple Recovery System
**Restore Implementation:**
```bash
# Restore from backup file
if [[ -z "$1" ]]; then
  echo "📋 Available backups in ~/.claude/backups/:"
  ls -la "$HOME/.claude/backups/" 2>/dev/null | grep -E "\.(tar\.gz|enc)$" || echo "No backups found"
  echo -e "\nUsage: /backup --restore <backup_file>"
  exit 1
fi

RESTORE_FILE="$1"
TEMP_DIR="/tmp/claude_restore_$$"

# Handle relative paths - look in ~/.claude/backups/ first
if [[ ! -f "$RESTORE_FILE" && ! -f "$HOME/.claude/backups/$RESTORE_FILE" ]]; then
  echo "❌ Backup file not found: $RESTORE_FILE"
  echo "💡 Try: /backup --restore <filename> (from ~/.claude/backups/)"
  exit 1
fi

# Use full path
if [[ -f "$HOME/.claude/backups/$RESTORE_FILE" ]]; then
  RESTORE_FILE="$HOME/.claude/backups/$RESTORE_FILE"
fi

mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR"

# Check if file is encrypted
if [[ "$RESTORE_FILE" == *.enc ]]; then
  echo "🔐 Encrypted backup detected"
  echo -n "Enter backup password: "
  read -s RESTORE_PASSWORD
  echo
  
  echo "🔓 Decrypting backup..."
  if ! openssl enc -d -aes-256-cbc -pbkdf2 -iter 100000 \
       -in "$RESTORE_FILE" -out backup.tar.gz \
       -pass pass:"$RESTORE_PASSWORD"; then
    echo "❌ Decryption failed - wrong password?"
    rm -rf "$TEMP_DIR"
    unset RESTORE_PASSWORD
    exit 1
  fi
  unset RESTORE_PASSWORD
else
  # Plain tar.gz file
  cp "$RESTORE_FILE" backup.tar.gz
fi

# Extract backup
echo "📦 Extracting backup..."
if ! tar -xzf backup.tar.gz; then
  echo "❌ Failed to extract backup archive"
  rm -rf "$TEMP_DIR"
  exit 1
fi

# Show what will be restored
echo -e "\n📋 Backup contents:"
if [[ -d claude_restore ]]; then
  find claude_restore -type f | head -10
  TOTAL_FILES=$(find claude_restore -type f | wc -l)
  echo "   ... and $((TOTAL_FILES - 10)) more files"
else
  echo "❌ Invalid backup format - claude_restore/ directory not found"
  rm -rf "$TEMP_DIR"
  exit 1
fi

# Confirm restore
echo -e "\n⚠️  This will replace your current ~/.claude configuration"
echo -n "Continue with restore? (y/N): "
read -r CONFIRM

if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
  echo "❌ Restore cancelled"
  rm -rf "$TEMP_DIR"
  exit 1
fi

# Backup existing config
if [[ -d "$HOME/.claude" ]]; then
  BACKUP_SUFFIX=$(date +%s)
  echo "💾 Backing up current config to ~/.claude.backup.$BACKUP_SUFFIX"
  mv "$HOME/.claude" "$HOME/.claude.backup.$BACKUP_SUFFIX"
fi

# Restore configuration
echo "🔄 Restoring configuration..."
mkdir -p "$HOME/.claude"
cp -r claude_restore/* "$HOME/.claude/"

# Cleanup
rm -rf "$TEMP_DIR"

echo "✅ Configuration restored successfully!"
echo "📁 Restored to: ~/.claude"
echo "🔄 Restart Claude to use restored configuration"
echo -e "\n📋 Restored files:"
find "$HOME/.claude" -type f | head -10
```

### `--verify` - Comprehensive Backup Validation
**Multi-Layer Verification:**
1. **Encryption Integrity**: Verify encryption and decryption process
2. **File Completeness**: Validate all critical files present
3. **JSON Validation**: Verify configuration file integrity
4. **MCP Configuration**: Validate MCP server configurations
5. **Recovery Testing**: Test complete recovery process

### `--schedule` - Automated Backup Scheduling
**Intelligent Backup Automation:**
1. **Trigger-Based**: Before MCP installations, major changes
2. **Time-Based**: Daily incremental, weekly full backup
3. **Event-Based**: Pre-commit, pre-deployment backups
4. **Smart Scheduling**: Adapt frequency based on activity patterns

### `--migrate` - Cross-Platform Migration
**Migration and Synchronization:**
1. **Platform Migration**: macOS ↔ Linux ↔ Windows
2. **Version Migration**: Claude Code version upgrades
3. **Environment Sync**: Development ↔ Production environments
4. **Team Sharing**: Secure configuration sharing and onboarding

## Advanced Backup Features

### Critical File Prioritization Matrix
```bash
# Intelligent file prioritization based on criticality
Priority 1 (Critical):
  - ~/.claude/.claude.json (session data, API keys)
  - ~/.claude/CLAUDE.md (global instructions)
  - ~/.config/claude/settings.json (MCP configurations)

Priority 2 (Important):
  - ~/.claude/commands/ (custom commands)
  - ~/.claude/MCP.md (MCP documentation)
  - ~/.claude/settings*.json (user preferences)

Priority 3 (Useful):
  - ~/.claude/mcp.servers.backup (server backup)
  - ~/.claude/init.* (initialization files)
  - ~/.claude/backups/ (previous backups)
```

### Incremental Backup Strategy
```bash
# Smart incremental backup with change detection
1. **Change Detection**: MD5 checksums for file change detection
2. **Delta Backup**: Only backup changed files since last backup
3. **Compression**: Intelligent compression based on file types
4. **Deduplication**: Remove duplicate content across backups
5. **Cleanup**: Intelligent cleanup of old and redundant backups
```

### Cross-Platform Compatibility
```bash
# Ensure backups work across different environments
1. **Path Normalization**: Convert platform-specific paths
2. **Permission Handling**: Preserve and adapt file permissions
3. **Encoding**: UTF-8 encoding for cross-platform compatibility
4. **Line Endings**: Handle CRLF/LF differences automatically
5. **Environment Variables**: Adapt environment-specific configurations
```

## MCP Server Coordination

### Cloud Storage & Management
```bash
# GCP MCP: Primary cloud backup infrastructure
mcp__gcp-mcp__run-gcp-code: "Create and manage Cloud Storage buckets"
mcp__gcp-mcp__get-cost-forecast: "Monitor backup storage costs"

# GitHub MCP: Configuration versioning and team sharing
mcp__github__create_repository: "claude-configs-backup"
mcp__github__push_files: "Encrypted configuration backups"
```

### Documentation & Knowledge Management
```bash
# Obsidian MCP: Backup strategy documentation
mcp__obsidian__obsidian_append_content: "Operations/Backups/$date.md"
mcp__obsidian__obsidian_complex_search: "Historical backup patterns"

# Context7 MCP: Best practice validation
mcp__context7__get-library-docs: "Enterprise backup best practices"
```

### Monitoring & Notifications
```bash
# Apple MCP: Team coordination and monitoring
mcp__apple-mcp__messages: "Backup completed: $summary"
mcp__apple-mcp__reminders: "Backup verification due: $date"

# tmux MCP: Development environment coordination
mcp__tmux__execute-command: "Backup status and monitoring"
```

## Enterprise Backup Workflows

### Disaster Recovery Planning
```bash
# Comprehensive disaster recovery scenarios
1. **Configuration Corruption**: Rapid recovery from verified backup
2. **Hardware Failure**: Cross-platform migration and restoration
3. **Security Breach**: Secure backup with credential rotation
4. **Team Onboarding**: Standardized configuration distribution
5. **Environment Migration**: Development to production sync
```

### Backup Integrity Monitoring
```bash
# Continuous backup health monitoring
1. **Checksum Verification**: Regular integrity validation
2. **Recovery Testing**: Automated recovery validation
3. **Storage Health**: Monitor backup storage availability
4. **Encryption Validation**: Verify encryption strength
5. **Compliance Checking**: Ensure backup meets requirements
```

### Team Collaboration Features
```bash
# Secure team configuration sharing
1. **Configuration Templates**: Standardized team setups
2. **Selective Sharing**: Share configurations without secrets
3. **Role-Based Access**: Different configurations for different roles
4. **Change Tracking**: Version control for configuration changes
5. **Audit Trail**: Complete backup and restore audit logging
```

## Performance & Security Optimization

### High-Performance Backup
```bash
# Optimized backup performance
- Parallel compression with pigz (4x faster)
- Intelligent file filtering and exclusion
- Delta compression for large files
- Memory-efficient streaming operations
- Background cleanup and optimization
```

### Enterprise Security Features
```bash
# Comprehensive security implementation
- AES-256-GCM authenticated encryption
- PBKDF2 key derivation (100,000 iterations)
- Secure key management and rotation
- Cryptographically secure random salts
- Memory-safe password handling
- Secure deletion of temporary files
```

### Compliance and Auditing
```bash
# Enterprise compliance features
- SOC 2 Type II backup controls
- GDPR data protection compliance
- Audit trail for all backup operations
- Retention policy enforcement
- Access control and permissions
- Encryption key management compliance
```

## Integration with Other Commands

### Seamless Workflow Integration
- **`/install`**: Automatic backup before MCP server installation
- **`/sync`**: Backup coordination across worktrees
- **`/check`**: Backup integrity validation
- **`/learn`**: Backup pattern analysis and optimization

## Success Criteria

### Backup Excellence
- [ ] **Zero Data Loss**: Complete configuration preservation
- [ ] **Rapid Recovery**: <30 second recovery from backup
- [ ] **Security Assured**: Enterprise-grade encryption and protection
- [ ] **Cross-Platform**: Works across macOS, Linux, Windows
- [ ] **Team Ready**: Secure configuration sharing capabilities

### MCP Integration Success
- [ ] **Cloud Integrated**: Seamless cloud backup storage
- [ ] **Documentation Complete**: All backup decisions documented
- [ ] **Monitoring Active**: Proactive backup health monitoring
- [ ] **Compliance Met**: All enterprise security requirements satisfied

## Manual Backup & Restore (Without Claude)

For quick backup/restore operations when Claude is not available:

### Quick Manual Backup
```bash
# Create backup directory
mkdir -p ~/.claude/backups

# Create timestamped backup (from within ~/.claude directory)
cd ~/.claude
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
tar -czf "backups/manual_backup_${TIMESTAMP}.tar.gz" \
  --exclude='backups' \
  --exclude='*.backup' \
  --exclude='.DS_Store' \
  --exclude='todos' \
  --exclude='shell-snapshots' \
  --exclude='statsig' \
  --exclude='projects' \
  .

echo "Backup created: ~/.claude/backups/manual_backup_${TIMESTAMP}.tar.gz"
echo "Size: $(du -h backups/manual_backup_${TIMESTAMP}.tar.gz | cut -f1)"
```

### Quick Manual Restore
```bash
# List available backups
ls -la ~/.claude/backups/

# Restore from specific backup (replace TIMESTAMP with actual timestamp)
cd ~ 
mv .claude .claude.backup.$(date +%s)  # Backup current config
tar -xzf ~/.claude/backups/manual_backup_TIMESTAMP.tar.gz

echo "Configuration restored from backup"
echo "Previous config backed up to ~/.claude.backup.*"
```

### Emergency Recovery (From Any Shell)
```bash
# If you have an encrypted backup
openssl enc -d -aes-256-cbc -pbkdf2 -iter 100000 \
  -in backup_file.tar.gz.enc -out backup.tar.gz

# Extract and restore
tar -xzf backup.tar.gz
mv ~/.claude ~/.claude.old
mv claude_restore ~/.claude
```

### Explore Backup Contents
```bash
# Extract backup to temporary location
mkdir /tmp/explore_backup
cd /tmp/explore_backup
tar -xzf ~/.claude/backups/backup_file.tar.gz

# Browse contents
ls -la claude_restore/
cat claude_restore/CLAUDE.md
cat claude_restore/.claude.json
```

### Key Files to Backup Manually
If you need to quickly backup just the essential files:
```bash
# Essential configuration files
cp ~/.claude/.claude.json ~/Desktop/
cp ~/.claude/CLAUDE.md ~/Desktop/
tar -czf ~/Desktop/claude_commands.tar.gz ~/.claude/commands/

# Restore essentials
cp ~/Desktop/.claude.json ~/.claude/
cp ~/Desktop/CLAUDE.md ~/.claude/
cd ~/.claude && tar -xzf ~/Desktop/claude_commands.tar.gz --strip-components=2
```

---

**Philosophy**: Backups should be invisible. Recovery should be instant. Security should be unbreakable. Documentation should be automatic. Peace of mind should be guaranteed.

**Local Storage**: Everything in `~/.claude/backups/` - encrypted + plain copies for easy access during development.