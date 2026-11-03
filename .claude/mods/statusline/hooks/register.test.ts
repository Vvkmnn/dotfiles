// Mod tests, run against the engine itself: `claude plugin test .` (harness shape from better-claude's sub-meter)
import { expect, mock, test } from 'claude-code/testing'
import type { Engine } from 'claude-code/testing'
import type { On } from 'claude-code'

const NOW = Date.parse('2026-11-04T10:00:00Z')
const GOLD = '\x1b[38;2;230;195;132m', RED = '\x1b[38;2;232;36;36m', DIM = '\x1b[2m', R = '\x1b[0m'
const LINE = `${GOLD}ॐ${R} Fᵀ⁺  ${GOLD}?${R} ${RED}5${R} ${DIM}waiting${R}\n`

/** Everything beneath the mod: the clock, the session, settings, and the script as a stubbed process. */
function world (on: On, stdout: string = LINE) {
  const clock = mock.clock(on, { now: NOW })
  on('session.start', ($, e) => ({ cwd: e.cwd }))
  on('session.end', ($, e) => ({ sessionId: e.sessionId }))
  on('session.usage', () => ({ value: { startedAt: NOW, context: { window: 1_000_000, percent: 61 }, rateLimits: [{ kind: 'seven_day', percentUsed: 48, resetsAt: new Date(NOW + 4 * 86_400_000).toISOString() }], cost: { usd: 283 } } as never }))
  on('session.model', () => ({ value: 'claude-fable-5-1' }))
  on('session.cwd', () => ({ value: '/project' }))
  on('settings.read', () => ({ value: { effortLevel: 'high' } }))
  on('env.get', ($, e) => ({ value: e.name === 'HOME' ? '/Users/v' : undefined }))
  const states: string[] = []   // CLAUDE_STATUSLINE_STATE of every script run, in order
  on('process.run', ($, e) => {
    states.push((e.init && e.init.env && e.init.env.CLAUDE_STATUSLINE_STATE) || '')
    return { value: { exitCode: 0, stdout, stderr: '' } }
  })
  on('session.measure', ($, e) => ({ changed: e.changed }))
  on('ui.render', ($, e) => {
    const { Text } = $.ui.resolve(e)
    return Text({ children: ['hint' in e.props ? e.props.hint : ''] })
  })
  return { clock, states }
}

const startSession = ($: Engine) => $.session.start({ cwd: '/project', surface: 'terminal', isInteractive: true })
const hint = ($: Engine, props: Partial<{ isDraft: boolean, isWorking: boolean, hint: string }> = {}, columns = 160) =>
  $.ui.mount({ plugin: 'statusline', surface: 'terminal', component: 'PromptHint', props: { isDraft: false, isWorking: false, hint: '-- INSERT -- (shift+tab to cycle)', ...props }, viewport: { columns, rows: 40 } })

test("draws Claude's own hint words first, minus the vim-mode word, then the script line, colours mapped to hex", async ($, on) => {
  world(on)
  await startSession($)
  const ui = await hint($, { hint: '-- INSERT -- (shift+tab to cycle) · ← 1 agent' })
  expect(await ui.find({ type: 'Text', text: '← 1 agent' })).toBeDefined()
  expect(await ui.find({ type: 'Text', text: '(shift+tab to cycle)' })).toBeUndefined()
  expect(await ui.find({ type: 'Text', text: '-- INSERT -- (shift+tab to cycle) · ← 1 agent' })).toBeUndefined()
  expect(await ui.find({ type: 'Text', text: 'ॐ' })).toBeDefined()
  expect(await ui.find({ type: 'Text', text: '5' })).toBeDefined()
  expect(await ui.find({ type: 'Text', text: 'waiting' })).toBeDefined()
})

test('leaves the engine hint alone until the script has answered', async ($, on) => {
  world(on, '')
  await startSession($)
  const ui = await hint($)
  expect(await ui.find({ type: 'Text', text: '-- INSERT -- (shift+tab to cycle)' })).toBeDefined()
})

test('draws nothing of its own when Claude has nothing to say but the dropped parts', async ($, on) => {
  world(on)
  await startSession($)
  const ui = await hint($)   // hint is only the vim word and the shortcuts reminder
  expect(await ui.find({ type: 'Text', text: ' · ' })).toBeUndefined()
  expect(await ui.find({ type: 'Text', text: 'ॐ' })).toBeDefined()
})

test('tells the script when you are typing or Claude is working, so ॐ is red only when idle', async ($, on) => {
  const { states } = world(on)
  await startSession($)
  await hint($, { isDraft: true })
  await hint($, { isDraft: false, isWorking: true, hint: 'esc to interrupt' })
  await hint($, { isDraft: false, isWorking: false })
  expect(states.length).toBe(4)   // session.start, then one run per change, none dropped
  expect(states.slice(-3)).toEqual(['draft', 'working', 'idle'])   // the first run reads whatever state is current
})
