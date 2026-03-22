import { describe, it, expect, beforeEach } from 'vitest'
import { useEmail } from '../../app/composables/useEmail'
import { clearEventLog, getEventLog } from '../../app/lib/analytics'

describe('useEmail', () => {
  beforeEach(() => {
    const { resetEmail } = useEmail()
    resetEmail()
    clearEventLog()
  })

  it('initializes with empty state', () => {
    const { email, isSubmitted, isLoading, referralCode, error } = useEmail()
    expect(email.value).toBe('')
    expect(isSubmitted.value).toBe(false)
    expect(isLoading.value).toBe(false)
    expect(referralCode.value).toBeNull()
    expect(error.value).toBeNull()
  })

  it('rejects invalid email', async () => {
    const { email, submitEmail, error } = useEmail()
    email.value = 'not-an-email'
    const success = await submitEmail('wolf')
    expect(success).toBe(false)
    expect(error.value).toContain('valid email')
  })

  it('rejects empty email', async () => {
    const { submitEmail, error } = useEmail()
    const success = await submitEmail('wolf')
    expect(success).toBe(false)
    expect(error.value).toContain('valid email')
  })

  it('submits valid email successfully', async () => {
    const { email, submitEmail, isSubmitted, referralCode } = useEmail()
    email.value = 'test@example.com'
    const success = await submitEmail('wolf')
    expect(success).toBe(true)
    expect(isSubmitted.value).toBe(true)
    expect(referralCode.value).toMatch(/^ref_/)
  })

  it('tracks email_signup event', async () => {
    const { email, submitEmail } = useEmail()
    email.value = 'test@example.com'
    await submitEmail('wolf', 'solo')
    const events = getEventLog()
    expect(events.some(e => e.name === 'email_signup')).toBe(true)
  })

  it('submits partner mode email', async () => {
    const { email, submitPartnerModeEmail, isSubmitted } = useEmail()
    email.value = 'test@example.com'
    const success = await submitPartnerModeEmail('wolf_bear')
    expect(success).toBe(true)
    expect(isSubmitted.value).toBe(true)
  })

  it('tracks partner_mode_interest event', async () => {
    const { email, submitPartnerModeEmail } = useEmail()
    email.value = 'test@example.com'
    await submitPartnerModeEmail('wolf_bear')
    const events = getEventLog()
    expect(events.some(e => e.name === 'partner_mode_interest')).toBe(true)
  })

  it('rejects invalid email for partner mode', async () => {
    const { submitPartnerModeEmail, error } = useEmail()
    const success = await submitPartnerModeEmail('wolf_bear')
    expect(success).toBe(false)
    expect(error.value).toBeTruthy()
  })

  it('resetEmail clears all state', async () => {
    const { email, submitEmail, resetEmail, isSubmitted, referralCode, error } = useEmail()
    email.value = 'test@example.com'
    await submitEmail('wolf')
    resetEmail()
    expect(email.value).toBe('')
    expect(isSubmitted.value).toBe(false)
    expect(referralCode.value).toBeNull()
    expect(error.value).toBeNull()
  })
})
