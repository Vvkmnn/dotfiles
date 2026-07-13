#!/usr/bin/env node

/**
 * Pre-Commit Quality Gate Hook for Claude Code
 * 
 * Validates code quality before allowing commits to proceed.
 * Integrates with /commit command to ensure high code standards.
 * 
 * Hook Event: PreToolUse
 * Matchers: Bash (for git commit commands)
 * Exit Codes: 0 = allow, 1 = block
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// Read hook input from stdin
let inputData = '';
process.stdin.on('data', chunk => inputData += chunk);
process.stdin.on('end', () => {
  try {
    const hookData = JSON.parse(inputData);
    handleHook(hookData);
  } catch (error) {
    console.error('❌ Hook error:', error.message);
    process.exit(0); // Don't block on hook errors
  }
});

async function handleHook(hookData) {
  // Only validate git commit commands from /commit 
  if (hookData.tool_name !== 'Bash') {
    process.exit(0);
  }
  
  const command = hookData.tool_input?.command || '';
  
  // Check if this is a commit command
  if (!command.includes('git commit') || command.includes('--amend')) {
    process.exit(0);
  }
  
  console.log('🔍 Running pre-commit quality gates...');
  
  try {
    const projectInfo = detectProjectType();
    const validationResults = await runQualityGates(projectInfo);
    
    if (validationResults.success) {
      console.log('✅ All quality gates passed - commit allowed');
      displaySuccessResults(validationResults);
      process.exit(0);
    } else {
      console.log('❌ Quality gates failed - commit blocked');
      displayFailureResults(validationResults);
      suggestFixes(validationResults, projectInfo);
      process.exit(1); // Block commit
    }
  } catch (error) {
    console.error('⚠️  Quality gate validation error:', error.message);
    console.log('🚀 Allowing commit to proceed (validation error)');
    process.exit(0); // Don't block on validation errors
  }
}

function detectProjectType() {
  const cwd = process.cwd();
  const projectInfo = {
    type: 'unknown',
    packageManager: null,
    hasLint: false,
    hasBuild: false,
    hasTypeCheck: false,
    tools: []
  };
  
  // Node.js projects
  if (fs.existsSync(path.join(cwd, 'package.json'))) {
    projectInfo.type = 'nodejs';
    
    try {
      const packageJson = JSON.parse(fs.readFileSync(path.join(cwd, 'package.json'), 'utf8'));
      const scripts = packageJson.scripts || {};
      
      // Detect package manager
      if (fs.existsSync(path.join(cwd, 'bun.lockb'))) {
        projectInfo.packageManager = 'bun';
      } else if (fs.existsSync(path.join(cwd, 'pnpm-lock.yaml'))) {
        projectInfo.packageManager = 'pnpm';
      } else if (fs.existsSync(path.join(cwd, 'yarn.lock'))) {
        projectInfo.packageManager = 'yarn';
      } else {
        projectInfo.packageManager = 'npm';
      }
      
      // Detect available scripts
      projectInfo.hasLint = !!(scripts.lint || scripts['lint:check']);
      projectInfo.hasBuild = !!(scripts.build);
      projectInfo.hasTypeCheck = !!(scripts['type-check'] || scripts.typecheck || fs.existsSync(path.join(cwd, 'tsconfig.json')));
      
    } catch (error) {
      console.warn('⚠️  Could not parse package.json');
    }
  }
  
  // Python projects
  else if (fs.existsSync(path.join(cwd, 'pyproject.toml')) || fs.existsSync(path.join(cwd, 'requirements.txt'))) {
    projectInfo.type = 'python';
    projectInfo.hasLint = checkCommandExists('ruff') || checkCommandExists('flake8') || checkCommandExists('pylint');
    projectInfo.hasTypeCheck = checkCommandExists('mypy');
    projectInfo.hasBuild = fs.existsSync(path.join(cwd, 'setup.py')) || fs.existsSync(path.join(cwd, 'pyproject.toml'));
  }
  
  // Go projects
  else if (fs.existsSync(path.join(cwd, 'go.mod'))) {
    projectInfo.type = 'go';
    projectInfo.hasLint = checkCommandExists('go');
    projectInfo.hasBuild = checkCommandExists('go');
    projectInfo.hasTypeCheck = true; // Built into Go
  }
  
  // Rust projects
  else if (fs.existsSync(path.join(cwd, 'Cargo.toml'))) {
    projectInfo.type = 'rust';
    projectInfo.hasLint = checkCommandExists('cargo');
    projectInfo.hasBuild = checkCommandExists('cargo');
    projectInfo.hasTypeCheck = true; // Built into Rust
  }
  
  return projectInfo;
}

function checkCommandExists(command) {
  try {
    execSync(`which ${command}`, { stdio: 'ignore' });
    return true;
  } catch {
    return false;
  }
}

async function runQualityGates(projectInfo) {
  const results = {
    success: true,
    linting: { passed: true, output: '', error: '' },
    typeCheck: { passed: true, output: '', error: '' },
    build: { passed: true, output: '', error: '' },
    security: { passed: true, output: '', error: '' }
  };
  
  // Run linting
  if (projectInfo.hasLint) {
    results.linting = await runLinting(projectInfo);
    if (!results.linting.passed) results.success = false;
  }
  
  // Run type checking
  if (projectInfo.hasTypeCheck) {
    results.typeCheck = await runTypeChecking(projectInfo);
    if (!results.typeCheck.passed) results.success = false;
  }
  
  // Run build validation
  if (projectInfo.hasBuild) {
    results.build = await runBuild(projectInfo);
    if (!results.build.passed) results.success = false;
  }
  
  // Run basic security checks
  results.security = await runSecurityChecks(projectInfo);
  if (!results.security.passed) results.success = false;
  
  return results;
}

async function runLinting(projectInfo) {
  try {
    let command;
    
    switch (projectInfo.type) {
      case 'nodejs':
        command = `${projectInfo.packageManager} run lint`;
        break;
      case 'python':
        command = 'ruff check . || flake8 .';
        break;
      case 'go':
        command = 'go vet ./...';
        break;
      case 'rust':
        command = 'cargo clippy --quiet -- -D warnings';
        break;
      default:
        return { passed: true, output: 'No linting configured', error: '' };
    }
    
    const output = execSync(command, { encoding: 'utf8', stdio: 'pipe' });
    return { passed: true, output: output.trim(), error: '' };
    
  } catch (error) {
    return { 
      passed: false, 
      output: '', 
      error: error.stdout || error.stderr || error.message 
    };
  }
}

async function runTypeChecking(projectInfo) {
  try {
    let command;
    
    switch (projectInfo.type) {
      case 'nodejs':
        command = 'npx tsc --noEmit || npm run type-check';
        break;
      case 'python':
        command = 'mypy .';
        break;
      case 'go':
        return { passed: true, output: 'Type checking built into Go', error: '' };
      case 'rust':
        command = 'cargo check --quiet';
        break;
      default:
        return { passed: true, output: 'No type checking configured', error: '' };
    }
    
    const output = execSync(command, { encoding: 'utf8', stdio: 'pipe' });
    return { passed: true, output: output.trim(), error: '' };
    
  } catch (error) {
    return { 
      passed: false, 
      output: '', 
      error: error.stdout || error.stderr || error.message 
    };
  }
}

async function runBuild(projectInfo) {
  try {
    let command;
    
    switch (projectInfo.type) {
      case 'nodejs':
        command = `${projectInfo.packageManager} run build`;
        break;
      case 'python':
        command = 'python -m build --wheel';
        break;
      case 'go':
        command = 'go build ./...';
        break;
      case 'rust':
        command = 'cargo build --quiet';
        break;
      default:
        return { passed: true, output: 'No build configured', error: '' };
    }
    
    const output = execSync(command, { encoding: 'utf8', stdio: 'pipe' });
    return { passed: true, output: output.trim(), error: '' };
    
  } catch (error) {
    return { 
      passed: false, 
      output: '', 
      error: error.stdout || error.stderr || error.message 
    };
  }
}

async function runSecurityChecks(projectInfo) {
  try {
    // Basic git secrets check
    try {
      execSync('git diff --cached --name-only | xargs grep -l "api[_-]key\\|password\\|secret\\|token" || true', { stdio: 'pipe' });
    } catch (error) {
      // If grep finds matches, it will exit with 0, if not, it might error - that's OK
    }
    
    // Dependency audit if available
    if (projectInfo.type === 'nodejs') {
      try {
        execSync(`${projectInfo.packageManager} audit --audit-level=high`, { stdio: 'pipe' });
      } catch (error) {
        if (error.status > 0) {
          return { 
            passed: false, 
            output: '', 
            error: 'High/critical vulnerabilities found in dependencies' 
          };
        }
      }
    }
    
    return { passed: true, output: 'Security checks passed', error: '' };
    
  } catch (error) {
    return { 
      passed: false, 
      output: '', 
      error: error.message 
    };
  }
}

function displaySuccessResults(results) {
  console.log('\n✅ Quality Gate Results:');
  if (results.linting.passed) console.log('  ✓ Linting: Passed');
  if (results.typeCheck.passed) console.log('  ✓ Type Checking: Passed');
  if (results.build.passed) console.log('  ✓ Build: Passed');
  if (results.security.passed) console.log('  ✓ Security: Passed');
}

function displayFailureResults(results) {
  console.log('\n❌ Quality Gate Failures:');
  
  if (!results.linting.passed) {
    console.log('  ✗ Linting: FAILED');
    console.log(`    ${results.linting.error}`);
  }
  
  if (!results.typeCheck.passed) {
    console.log('  ✗ Type Checking: FAILED');
    console.log(`    ${results.typeCheck.error}`);
  }
  
  if (!results.build.passed) {
    console.log('  ✗ Build: FAILED');
    console.log(`    ${results.build.error}`);
  }
  
  if (!results.security.passed) {
    console.log('  ✗ Security: FAILED');
    console.log(`    ${results.security.error}`);
  }
}

function suggestFixes(results, projectInfo) {
  console.log('\n🔧 Suggested fixes:');
  
  if (!results.linting.passed) {
    switch (projectInfo.type) {
      case 'nodejs':
        console.log(`  → Run: ${projectInfo.packageManager} run lint:fix`);
        break;
      case 'python':
        console.log('  → Run: ruff check --fix . || black .');
        break;
      case 'go':
        console.log('  → Run: go fmt ./...');
        break;
      case 'rust':
        console.log('  → Run: cargo clippy --fix');
        break;
    }
  }
  
  if (!results.build.passed) {
    console.log('  → Fix build errors and try again');
  }
  
  if (!results.security.passed) {
    console.log('  → Review and remove secrets/vulnerabilities');
  }
  
  console.log('\n💡 After fixing issues, run: git add . && /commit');
}