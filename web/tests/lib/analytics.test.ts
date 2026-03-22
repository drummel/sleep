import { describe, it, expect, beforeEach, vi, afterEach } from 'vitest'
import { trackEvent, getEventLog, clearEventLog, getShareLinks, joinWaitlist, submitFeatureSurvey } from '../../app/lib/analytics'

describe('trackEvent', () => {
  beforeEach(() => {
    clearEventLog()
  })

  it('adds event to log', () => {
    trackEvent({ name: 'quiz_start', data: { source: 'hero' } })
    expect(getEventLog()).toHaveLength(1)
  })

  it('preserves event data', () => {
    trackEvent({ name: 'quiz_start', data: { source: 'hero' } })
    const log = getEventLog()
    expect(log[0].name).toBe('quiz_start')
    expect(log[0].data).toEqual({ source: 'hero' })
  })

  it('accumulates multiple events', () => {
    trackEvent({ name: 'quiz_start', data: { source: 'hero' } })
    trackEvent({ name: 'quiz_complete', data: { chronotype: 'wolf', time_spent_seconds: 45, entry_point: 'solo' } })
    expect(getEventLog()).toHaveLength(2)
  })

  it('tracks quiz_question_answered', () => {
    trackEvent({ name: 'quiz_question_answered', data: { question_number: 1, answer: 'Before 6:30 AM' } })
    expect(getEventLog()[0].name).toBe('quiz_question_answered')
  })

  it('tracks compatibility events', () => {
    trackEvent({ name: 'compatibility_tool_opened', data: { source: 'landing_page_section' } })
    trackEvent({ name: 'compatibility_card_generated', data: { pairing: 'wolf_bear' } })
    expect(getEventLog()).toHaveLength(2)
  })

  it('tracks share events', () => {
    trackEvent({ name: 'share_card_click', data: { platform: 'twitter', chronotype: 'wolf', card_type: 'solo' } })
    expect(getEventLog()[0].name).toBe('share_card_click')
  })

  it('tracks partner events', () => {
    trackEvent({ name: 'partner_invite_sent', data: { method: 'whatsapp' } })
    trackEvent({ name: 'partner_mode_interest', data: { pairing: 'wolf_bear' } })
    expect(getEventLog()).toHaveLength(2)
  })

  it('calls OperatorStack.track when available', () => {
    const mockTrack = vi.fn()
    ;(globalThis as any).window = { OperatorStack: { track: mockTrack } }
    trackEvent({ name: 'quiz_start', data: { source: 'test' } })
    expect(mockTrack).toHaveBeenCalledWith('quiz_start', { source: 'test' })
    delete (globalThis as any).window
  })

  it('logs in development mode', () => {
    const spy = vi.spyOn(console, 'log').mockImplementation(() => {})
    const origEnv = process.env.NODE_ENV
    process.env.NODE_ENV = 'development'
    trackEvent({ name: 'quiz_start', data: { source: 'test' } })
    expect(spy).toHaveBeenCalled()
    process.env.NODE_ENV = origEnv
    spy.mockRestore()
  })

  it('tracks all event types', () => {
    trackEvent({ name: 'quiz_abandoned', data: { last_question: 3, time_spent_seconds: 20 } })
    trackEvent({ name: 'email_signup', data: { chronotype: 'wolf', track: 'solo' } })
    trackEvent({ name: 'feature_vote', data: { features: ['adaptive_engine'], chronotype: 'wolf' } })
    trackEvent({ name: 'app_interest_click', data: { chronotype: 'wolf', track: 'solo' } })
    trackEvent({ name: 'referral_share', data: { method: 'copy' } })
    trackEvent({ name: 'compatibility_chronotype_selected', data: { position: 'self', chronotype: 'wolf' } })
    trackEvent({ name: 'compatibility_card_shared', data: { platform: 'instagram', pairing: 'wolf_bear' } })
    trackEvent({ name: 'partner_quiz_started', data: { referrer_chronotype: 'wolf' } })
    expect(getEventLog()).toHaveLength(8)
  })
})

describe('clearEventLog', () => {
  it('clears all events', () => {
    trackEvent({ name: 'quiz_start', data: { source: 'hero' } })
    clearEventLog()
    expect(getEventLog()).toHaveLength(0)
  })
})

describe('getEventLog', () => {
  beforeEach(() => clearEventLog())

  it('returns a copy', () => {
    trackEvent({ name: 'quiz_start', data: { source: 'hero' } })
    const log = getEventLog()
    log.push({ name: 'quiz_start', data: { source: 'fake' } })
    expect(getEventLog()).toHaveLength(1)
  })
})

describe('getShareLinks', () => {
  it('returns twitter link', () => {
    const links = getShareLinks('ref_abc', { text: 'Test', url: 'https://example.com' })
    expect(links.twitter).toContain('twitter.com')
    expect(links.twitter).toContain('Test')
  })

  it('returns whatsapp link', () => {
    const links = getShareLinks('ref_abc', { text: 'Test', url: 'https://example.com' })
    expect(links.whatsapp).toContain('wa.me')
  })

  it('returns copy link', () => {
    const links = getShareLinks('ref_abc', { text: 'Test', url: 'https://example.com' })
    expect(links.copy).toBe('https://example.com')
  })

  it('encodes text properly', () => {
    const links = getShareLinks('ref_abc', { text: 'Hello World!', url: 'https://example.com' })
    expect(links.twitter).toContain('Hello%20World!')
  })
})

describe('joinWaitlist', () => {
  afterEach(() => {
    delete (globalThis as any).window
  })

  it('returns success with referral code', async () => {
    const result = await joinWaitlist({
      email: 'test@example.com',
      waitlist_id: 'wl_solo',
    })
    expect(result.success).toBe(true)
    expect(result.referral_code).toMatch(/^ref_/)
  })

  it('generates unique codes', async () => {
    const r1 = await joinWaitlist({ email: 'a@example.com', waitlist_id: 'wl_solo' })
    const r2 = await joinWaitlist({ email: 'b@example.com', waitlist_id: 'wl_solo' })
    expect(r1.referral_code).not.toBe(r2.referral_code)
  })

  it('calls OperatorStack when available', async () => {
    const mockJoin = vi.fn().mockResolvedValue({ success: true, referral_code: 'ref_mock' })
    ;(globalThis as any).window = { OperatorStack: { joinWaitlist: mockJoin } }
    const result = await joinWaitlist({ email: 'test@example.com', waitlist_id: 'wl_solo' })
    expect(mockJoin).toHaveBeenCalled()
    expect(result.referral_code).toBe('ref_mock')
  })

  it('accepts metadata', async () => {
    const result = await joinWaitlist({
      email: 'test@example.com',
      waitlist_id: 'wl_partner_mode',
      metadata: { pairing: 'wolf_bear' },
    })
    expect(result.success).toBe(true)
  })
})

describe('submitFeatureSurvey', () => {
  afterEach(() => {
    delete (globalThis as any).window
  })

  it('returns success', async () => {
    const result = await submitFeatureSurvey({
      email: 'test@example.com',
      chronotype: 'wolf',
      goal: 'test',
      features: ['adaptive_engine'],
      feature_count: 1,
      track: 'solo',
      submitted_at: new Date().toISOString(),
    })
    expect(result.success).toBe(true)
  })

  it('calls OperatorStack when available', async () => {
    const mockSubmit = vi.fn().mockResolvedValue({ success: true })
    ;(globalThis as any).window = { OperatorStack: { submitForm: mockSubmit } }
    await submitFeatureSurvey({
      email: 'test@example.com',
      chronotype: 'wolf',
      goal: 'test',
      features: ['adaptive_engine'],
      feature_count: 1,
      track: 'solo',
      submitted_at: new Date().toISOString(),
    })
    expect(mockSubmit).toHaveBeenCalledWith('frm_feature_interest', expect.any(Object))
  })
})
