#!/usr/bin/env node
'use strict';
// Tests for hooks/lib/pane-session.js against a stub tmux: the pane option is set with an explicit
// target, a malformed id or a missing pane writes nothing. Run: node pane-session.test.js
const assert = require('assert');
const fs = require('fs');
const os = require('os');
const path = require('path');

const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'pane-session-'));
const calls = path.join(dir, 'calls.txt');
const stub = path.join(dir, 'tmux');
fs.writeFileSync(stub, `#!/bin/sh\nprintf '%s\\n' "$*" >> "${calls}"\n`);
fs.chmodSync(stub, 0o755);

process.env.CLAUDE_TMUX_BIN = stub;
process.env.TMUX = '/tmp/tmux-501/default,1,0';
process.env.TMUX_PANE = '%42';

const ps = require('./lib/pane-session');
let passed = 0;
function ok(name, cond) { assert.ok(cond, name); passed += 1; console.log(`ok    ${name}`); }

const id = '6364ea2e-321e-4a89-aa6d-8aebdd2405c7';
assert.strictEqual(ps.record(id), true);
ok('record sets the pane option with an explicit -t', fs.readFileSync(calls, 'utf8').trim() === `set-option -p -t %42 @claude_session ${id}`);

assert.strictEqual(ps.record('not-a-session-id'), false);
assert.strictEqual(ps.record(''), false);
ok('a malformed or empty id writes nothing', fs.readFileSync(calls, 'utf8').trim().split('\n').length === 1);

delete process.env.TMUX_PANE;
assert.strictEqual(ps.record(id), false);
ok('no pane, no write', fs.readFileSync(calls, 'utf8').trim().split('\n').length === 1);

fs.rmSync(dir, { recursive: true, force: true });
console.log(`${passed} passed`);
