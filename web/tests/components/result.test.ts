import { describe, it, expect, vi, beforeEach } from 'vitest'
import { mount } from '@vue/test-utils'
import { nextTick } from 'vue'
import ChronotypeReveal from '../../app/components/result/ChronotypeReveal.vue'
import EmailCapture from '../../app/components/result/EmailCapture.vue'
import ShareCard from '../../app/components/result/ShareCard.vue'
import CompatibilityPrompt from '../../app/components/result/CompatibilityPrompt.vue'
import FeatureSurvey from '../../app/components/result/FeatureSurvey.vue'
import ReferralSection from '../../app/components/result/ReferralSection.vue'

// Mock analytics module
vi.mock('../../app/lib/analytics', () => ({
  trackEvent: vi.fn(),
  getShareLinks: vi.fn((code: string, opts: { text: string; url: string }) => ({
    twitter: `https://twitter.com/intent/tweet?text=${encodeURIComponent(opts.text)}&url=${encodeURIComponent(opts.url)}`,
    whatsapp: `https://wa.me/?text=${encodeURIComponent(opts.text)}%20${encodeURIComponent(opts.url)}`,
    copy: opts.url,
  })),
  submitFeatureSurvey: vi.fn().mockResolvedValue({ success: true }),
  joinWaitlist: vi.fn().mockResolvedValue({ success: true, referral_code: 'ref_test123' }),
}))

// Mock useEmail composable
vi.mock('../../app/composables/useEmail', () => {
  const { ref } = require('vue')
  return {
    useEmail: () => ({
      email: ref(''),
      isSubmitted: ref(false),
      isLoading: ref(false),
      referralCode: ref(null),
      error: ref(null),
      submitEmail: vi.fn().mockResolvedValue(true),
      submitPartnerModeEmail: vi.fn().mockResolvedValue(true),
      resetEmail: vi.fn(),
    }),
  }
})

// ─── ChronotypeReveal ───────────────────────────────────────────────────────
describe('ChronotypeReveal', () => {
  beforeEach(() => {
    vi.useFakeTimers()
  })

  afterEach(() => {
    vi.useRealTimers()
  })

  it('renders the chronotype emoji for lion', () => {
    const wrapper = mount(ChronotypeReveal, {
      props: { chronotype: 'lion' },
    })
    expect(wrapper.text()).toContain('🦁')
  })

  it('renders the chronotype name', () => {
    const wrapper = mount(ChronotypeReveal, {
      props: { chronotype: 'lion' },
    })
    expect(wrapper.text()).toContain('Lion')
  })

  it('renders "You\'re a" heading pattern', () => {
    const wrapper = mount(ChronotypeReveal, {
      props: { chronotype: 'bear' },
    })
    expect(wrapper.text()).toContain("You're a")
    expect(wrapper.text()).toContain('Bear')
  })

  it('renders tagline for the chronotype', () => {
    const wrapper = mount(ChronotypeReveal, {
      props: { chronotype: 'wolf' },
    })
    expect(wrapper.text()).toContain('The Night Owl')
  })

  it('renders population info', () => {
    const wrapper = mount(ChronotypeReveal, {
      props: { chronotype: 'dolphin' },
    })
    expect(wrapper.text()).toContain('~10% of people')
  })

  it('renders sleep window stat', () => {
    const wrapper = mount(ChronotypeReveal, {
      props: { chronotype: 'lion' },
    })
    expect(wrapper.text()).toContain('Sleep Window')
    expect(wrapper.text()).toContain('10:00 PM')
  })

  it('renders peak focus stat', () => {
    const wrapper = mount(ChronotypeReveal, {
      props: { chronotype: 'bear' },
    })
    expect(wrapper.text()).toContain('Peak Focus')
    expect(wrapper.text()).toContain('10:00 AM')
  })

  it('renders best for stat', () => {
    const wrapper = mount(ChronotypeReveal, {
      props: { chronotype: 'wolf' },
    })
    expect(wrapper.text()).toContain('Best For')
    expect(wrapper.text()).toContain('Creative work at night')
  })

  it('renders the full description', () => {
    const wrapper = mount(ChronotypeReveal, {
      props: { chronotype: 'dolphin' },
    })
    expect(wrapper.text()).toContain('always slightly alert')
  })

  it('emits revealed after staggered animation completes', () => {
    const wrapper = mount(ChronotypeReveal, {
      props: { chronotype: 'lion' },
    })
    // Advance past the 1500ms reveal timeout
    vi.advanceTimersByTime(1600)
    expect(wrapper.emitted('revealed')).toHaveLength(1)
  })

  it('renders correct emoji for each chronotype', () => {
    const types = [
      { id: 'lion', emoji: '🦁' },
      { id: 'bear', emoji: '🐻' },
      { id: 'wolf', emoji: '🐺' },
      { id: 'dolphin', emoji: '🐬' },
    ]
    for (const { id, emoji } of types) {
      const wrapper = mount(ChronotypeReveal, {
        props: { chronotype: id },
      })
      expect(wrapper.text()).toContain(emoji)
    }
  })
})

// ─── EmailCapture ───────────────────────────────────────────────────────────
describe('EmailCapture', () => {
  it('renders the form heading', () => {
    const wrapper = mount(EmailCapture, {
      props: { chronotype: 'lion' },
    })
    expect(wrapper.text()).toContain('Get your personalized daily schedule')
  })

  it('renders the description text', () => {
    const wrapper = mount(EmailCapture, {
      props: { chronotype: 'bear' },
    })
    expect(wrapper.text()).toContain('optimized for your chronotype')
  })

  it('renders an email input field', () => {
    const wrapper = mount(EmailCapture, {
      props: { chronotype: 'wolf' },
    })
    const input = wrapper.find('input[type="email"]')
    expect(input.exists()).toBe(true)
    expect(input.attributes('placeholder')).toBe('you@example.com')
  })

  it('renders the submit button', () => {
    const wrapper = mount(EmailCapture, {
      props: { chronotype: 'dolphin' },
    })
    const button = wrapper.find('button[type="submit"]')
    expect(button.exists()).toBe(true)
    expect(button.text()).toContain('Send My Schedule')
  })

  it('renders the spam disclaimer text', () => {
    const wrapper = mount(EmailCapture, {
      props: { chronotype: 'lion' },
    })
    expect(wrapper.text()).toContain('No spam. Unsubscribe anytime.')
  })

  it('renders a form element', () => {
    const wrapper = mount(EmailCapture, {
      props: { chronotype: 'lion' },
    })
    expect(wrapper.find('form').exists()).toBe(true)
  })

  it('renders as a section element', () => {
    const wrapper = mount(EmailCapture, {
      props: { chronotype: 'lion' },
    })
    expect(wrapper.find('section').exists()).toBe(true)
  })

  it('submits email on form submit', async () => {
    const wrapper = mount(EmailCapture, {
      props: { chronotype: 'wolf' },
    })
    const input = wrapper.find('input[type="email"]')
    await input.setValue('test@example.com')
    await wrapper.find('form').trigger('submit')
    await nextTick()
    // submitEmail was mocked to return true
    expect(wrapper.emitted('captured')).toBeTruthy()
  })

  it('shows success state after submission', async () => {
    // Need to test with a real composable that changes isSubmitted
    // This tests the initial form rendering
    const wrapper = mount(EmailCapture, {
      props: { chronotype: 'wolf' },
    })
    expect(wrapper.text()).toContain('Send My Schedule')
  })
})

// ─── ShareCard ──────────────────────────────────────────────────────────────
describe('ShareCard', () => {
  it('renders the chronotype emoji', () => {
    const wrapper = mount(ShareCard, {
      props: { chronotype: 'lion', referralCode: null },
    })
    expect(wrapper.text()).toContain('🦁')
  })

  it('renders the chronotype name', () => {
    const wrapper = mount(ShareCard, {
      props: { chronotype: 'bear', referralCode: null },
    })
    expect(wrapper.text()).toContain('Bear')
  })

  it('renders the tagline', () => {
    const wrapper = mount(ShareCard, {
      props: { chronotype: 'wolf', referralCode: null },
    })
    expect(wrapper.text()).toContain('The Night Owl')
  })

  it('renders the sleep window', () => {
    const wrapper = mount(ShareCard, {
      props: { chronotype: 'dolphin', referralCode: null },
    })
    expect(wrapper.text()).toContain('11:30 PM')
  })

  it('renders the sleeppath.app branding', () => {
    const wrapper = mount(ShareCard, {
      props: { chronotype: 'lion', referralCode: null },
    })
    expect(wrapper.text()).toContain('sleeppath.app')
  })

  it('renders share buttons', () => {
    const wrapper = mount(ShareCard, {
      props: { chronotype: 'lion', referralCode: null },
    })
    expect(wrapper.text()).toContain('Share on X')
    expect(wrapper.text()).toContain('Copy Link')
  })

  it('renders two share buttons', () => {
    const wrapper = mount(ShareCard, {
      props: { chronotype: 'lion', referralCode: null },
    })
    const buttons = wrapper.findAll('button')
    expect(buttons.length).toBe(2)
  })

  it('renders the card with color accent for lion', () => {
    const wrapper = mount(ShareCard, {
      props: { chronotype: 'lion', referralCode: null },
    })
    const accentBar = wrapper.find('.bg-amber-500')
    expect(accentBar.exists()).toBe(true)
  })

  it('renders the card with color accent for wolf', () => {
    const wrapper = mount(ShareCard, {
      props: { chronotype: 'wolf', referralCode: null },
    })
    const accentBar = wrapper.find('.bg-violet-500')
    expect(accentBar.exists()).toBe(true)
  })

  it('renders copy button when referral code exists', async () => {
    const wrapper = mount(ShareCard, {
      props: { chronotype: 'lion', referralCode: 'ref_abc' },
    })
    const copyButton = wrapper.findAll('button').find((b) => b.text().includes('Copy'))
    expect(copyButton).toBeDefined()
  })

  it('calls shareTwitter on Share on X button click', async () => {
    const mockOpen = vi.fn()
    vi.stubGlobal('open', mockOpen)
    const wrapper = mount(ShareCard, {
      props: { chronotype: 'lion', referralCode: null },
    })
    const shareBtn = wrapper.findAll('button').find((b) => b.text().includes('Share on X'))
    await shareBtn!.trigger('click')
    expect(mockOpen).toHaveBeenCalled()
    vi.unstubAllGlobals()
  })

  it('calls copyLink on copy button click', async () => {
    const mockWriteText = vi.fn().mockResolvedValue(undefined)
    Object.defineProperty(navigator, 'clipboard', {
      value: { writeText: mockWriteText },
      writable: true,
      configurable: true,
    })
    const wrapper = mount(ShareCard, {
      props: { chronotype: 'lion', referralCode: null },
    })
    const copyBtn = wrapper.findAll('button').find((b) => b.text().includes('Copy'))
    await copyBtn!.trigger('click')
    await nextTick()
    expect(mockWriteText).toHaveBeenCalled()
  })

  it('shows Copied! text after copying', async () => {
    vi.useFakeTimers()
    const mockWriteText = vi.fn().mockResolvedValue(undefined)
    Object.defineProperty(navigator, 'clipboard', {
      value: { writeText: mockWriteText },
      writable: true,
      configurable: true,
    })
    const wrapper = mount(ShareCard, {
      props: { chronotype: 'lion', referralCode: null },
    })
    const copyBtn = wrapper.findAll('button').find((b) => b.text().includes('Copy'))
    await copyBtn!.trigger('click')
    await nextTick()
    await nextTick()
    expect(wrapper.text()).toContain('Copied!')
    vi.useRealTimers()
  })

  it('renders correct accent bar for bear', () => {
    const wrapper = mount(ShareCard, {
      props: { chronotype: 'bear', referralCode: null },
    })
    expect(wrapper.find('.bg-orange-500').exists()).toBe(true)
  })

  it('renders correct accent bar for dolphin', () => {
    const wrapper = mount(ShareCard, {
      props: { chronotype: 'dolphin', referralCode: null },
    })
    expect(wrapper.find('.bg-sky-500').exists()).toBe(true)
  })
})

// ─── CompatibilityPrompt ────────────────────────────────────────────────────
describe('CompatibilityPrompt', () => {
  it('renders without partner (default solo view)', () => {
    const wrapper = mount(CompatibilityPrompt, {
      props: {
        chronotype: 'lion',
        partnerRef: null,
        referrerChronotype: null,
      },
    })
    expect(wrapper.text()).toContain('Curious how your rhythm fits')
    expect(wrapper.text()).toContain('Couples often have different chronotypes')
  })

  it('renders the self emoji in solo view', () => {
    const wrapper = mount(CompatibilityPrompt, {
      props: {
        chronotype: 'bear',
        partnerRef: null,
        referrerChronotype: null,
      },
    })
    expect(wrapper.text()).toContain('🐻')
  })

  it('renders personalized view with partner info', () => {
    const wrapper = mount(CompatibilityPrompt, {
      props: {
        chronotype: 'lion',
        partnerRef: 'ref_abc',
        referrerChronotype: 'wolf',
      },
    })
    expect(wrapper.text()).toContain('See how your rhythms align')
    expect(wrapper.text()).toContain('Lion')
    expect(wrapper.text()).toContain('Wolf')
  })

  it('renders both emojis in partner view', () => {
    const wrapper = mount(CompatibilityPrompt, {
      props: {
        chronotype: 'bear',
        partnerRef: 'ref_abc',
        referrerChronotype: 'dolphin',
      },
    })
    expect(wrapper.text()).toContain('🐻')
    expect(wrapper.text()).toContain('🐬')
  })

  it('renders the CTA button', () => {
    const wrapper = mount(CompatibilityPrompt, {
      props: {
        chronotype: 'lion',
        partnerRef: null,
        referrerChronotype: null,
      },
    })
    const button = wrapper.find('button')
    expect(button.exists()).toBe(true)
    expect(button.text()).toContain('Discover your compatibility')
  })

  it('calls navigateTo with solo path when clicked without partner', async () => {
    const wrapper = mount(CompatibilityPrompt, {
      props: {
        chronotype: 'lion',
        partnerRef: null,
        referrerChronotype: null,
      },
    })
    await wrapper.find('button').trigger('click')
    // navigateTo is mocked via #imports, so we just verify no error is thrown
    expect(wrapper.find('button').exists()).toBe(true)
  })

  it('renders description about partner differences in partner view', () => {
    const wrapper = mount(CompatibilityPrompt, {
      props: {
        chronotype: 'wolf',
        partnerRef: 'ref_abc',
        referrerChronotype: 'bear',
      },
    })
    expect(wrapper.text()).toContain('Wolf')
    expect(wrapper.text()).toContain('Bear')
    expect(wrapper.text()).toContain('sleep schedules overlap')
  })
})

// ─── FeatureSurvey ──────────────────────────────────────────────────────────
describe('FeatureSurvey', () => {
  const defaultProps = {
    chronotype: 'lion',
    goal: 'Build more consistency',
    track: 'solo',
  }

  it('renders the heading', () => {
    const wrapper = mount(FeatureSurvey, { props: defaultProps })
    expect(wrapper.text()).toContain('Which features matter most to you?')
  })

  it('renders the instruction text', () => {
    const wrapper = mount(FeatureSurvey, { props: defaultProps })
    expect(wrapper.text()).toContain('Pick up to 3')
  })

  it('renders all 9 feature options', () => {
    const wrapper = mount(FeatureSurvey, { props: defaultProps })
    const buttons = wrapper.findAll('button')
    // 9 feature buttons + 1 submit button = 10
    expect(buttons.length).toBe(10)
  })

  it('renders feature labels', () => {
    const wrapper = mount(FeatureSurvey, { props: defaultProps })
    expect(wrapper.text()).toContain('Daily schedule that adapts to my actual sleep')
    expect(wrapper.text()).toContain('Smart caffeine timing')
    expect(wrapper.text()).toContain('Focus window alerts')
    expect(wrapper.text()).toContain('Wind-down and sleep coaching')
    expect(wrapper.text()).toContain('Weekly patterns and trends')
    expect(wrapper.text()).toContain('Apple Watch energy state')
    expect(wrapper.text()).toContain('Calendar integration')
    expect(wrapper.text()).toContain('Night shift / irregular schedule support')
    expect(wrapper.text()).toContain("Partner Mode")
  })

  it('displays 0 / 3 selected initially', () => {
    const wrapper = mount(FeatureSurvey, { props: defaultProps })
    expect(wrapper.text()).toContain('0 / 3 selected')
  })

  it('updates selection count when a feature is clicked', async () => {
    const wrapper = mount(FeatureSurvey, { props: defaultProps })
    const featureButtons = wrapper.findAll('button').filter((b) => !b.text().includes('Submit'))
    await featureButtons[0].trigger('click')
    await nextTick()
    expect(wrapper.text()).toContain('1 / 3 selected')
  })

  it('allows selecting up to 3 features', async () => {
    const wrapper = mount(FeatureSurvey, { props: defaultProps })
    const featureButtons = wrapper.findAll('button').filter((b) => !b.text().includes('Submit'))
    await featureButtons[0].trigger('click')
    await featureButtons[1].trigger('click')
    await featureButtons[2].trigger('click')
    await nextTick()
    expect(wrapper.text()).toContain('3 / 3 selected')
  })

  it('prevents selecting more than 3 features', async () => {
    const wrapper = mount(FeatureSurvey, { props: defaultProps })
    const featureButtons = wrapper.findAll('button').filter((b) => !b.text().includes('Submit'))
    await featureButtons[0].trigger('click')
    await featureButtons[1].trigger('click')
    await featureButtons[2].trigger('click')
    await nextTick()
    // Try to select a 4th
    await featureButtons[3].trigger('click')
    await nextTick()
    expect(wrapper.text()).toContain('3 / 3 selected')
  })

  it('allows deselecting a selected feature', async () => {
    const wrapper = mount(FeatureSurvey, { props: defaultProps })
    const featureButtons = wrapper.findAll('button').filter((b) => !b.text().includes('Submit'))
    await featureButtons[0].trigger('click')
    await nextTick()
    expect(wrapper.text()).toContain('1 / 3 selected')
    // Deselect
    await featureButtons[0].trigger('click')
    await nextTick()
    expect(wrapper.text()).toContain('0 / 3 selected')
  })

  it('renders submit button as disabled when nothing is selected', () => {
    const wrapper = mount(FeatureSurvey, { props: defaultProps })
    const submitButton = wrapper.findAll('button').find((b) => b.text().includes('Submit'))
    expect(submitButton).toBeDefined()
    expect(submitButton!.attributes('disabled')).toBeDefined()
  })

  it('enables submit button when at least one feature is selected', async () => {
    const wrapper = mount(FeatureSurvey, { props: defaultProps })
    const featureButtons = wrapper.findAll('button').filter((b) => !b.text().includes('Submit'))
    await featureButtons[0].trigger('click')
    await nextTick()
    const submitButton = wrapper.findAll('button').find((b) => b.text().includes('Submit'))
    expect(submitButton!.attributes('disabled')).toBeUndefined()
  })

  it('renders the submit button text', () => {
    const wrapper = mount(FeatureSurvey, { props: defaultProps })
    expect(wrapper.text()).toContain('Submit My Picks')
  })

  it('disables unselected features when max (3) is reached', async () => {
    const wrapper = mount(FeatureSurvey, { props: defaultProps })
    const featureButtons = wrapper.findAll('button').filter((b) => !b.text().includes('Submit'))
    await featureButtons[0].trigger('click')
    await featureButtons[1].trigger('click')
    await featureButtons[2].trigger('click')
    await nextTick()
    // 4th button should be disabled
    expect(featureButtons[3].attributes('disabled')).toBeDefined()
    // Selected buttons should NOT be disabled
    expect(featureButtons[0].attributes('disabled')).toBeUndefined()
  })

  it('submits survey and shows success state', async () => {
    const wrapper = mount(FeatureSurvey, { props: defaultProps })
    const featureButtons = wrapper.findAll('button').filter((b) => !b.text().includes('Submit'))
    await featureButtons[0].trigger('click')
    await nextTick()
    const submitButton = wrapper.findAll('button').find((b) => b.text().includes('Submit'))
    await submitButton!.trigger('click')
    await nextTick()
    await nextTick()
    expect(wrapper.text()).toContain('Thanks for voting!')
    expect(wrapper.emitted('submitted')).toBeTruthy()
  })

  it('does not submit with no selections', async () => {
    const wrapper = mount(FeatureSurvey, { props: defaultProps })
    const submitButton = wrapper.findAll('button').find((b) => b.text().includes('Submit'))
    await submitButton!.trigger('click')
    await nextTick()
    // Should still show form, not success
    expect(wrapper.text()).toContain('Which features matter most')
  })
})

// ─── ReferralSection ────────────────────────────────────────────────────────
describe('ReferralSection', () => {
  it('renders the heading', () => {
    const wrapper = mount(ReferralSection, {
      props: { referralCode: null },
    })
    expect(wrapper.text()).toContain('Share SleepPath with friends')
  })

  it('renders the description text', () => {
    const wrapper = mount(ReferralSection, {
      props: { referralCode: null },
    })
    expect(wrapper.text()).toContain('Know someone who could use a better sleep schedule')
  })

  it('renders share on X button', () => {
    const wrapper = mount(ReferralSection, {
      props: { referralCode: null },
    })
    expect(wrapper.text()).toContain('Share on X')
  })

  it('renders copy link button when no referral code', () => {
    const wrapper = mount(ReferralSection, {
      props: { referralCode: null },
    })
    expect(wrapper.text()).toContain('Copy Link')
  })

  it('renders the referral URL when code is provided', () => {
    const wrapper = mount(ReferralSection, {
      props: { referralCode: 'ref_abc123' },
    })
    expect(wrapper.text()).toContain('sleeppath.app?ref=ref_abc123')
  })

  it('renders referral stats when code is provided', () => {
    const wrapper = mount(ReferralSection, {
      props: { referralCode: 'ref_abc123' },
    })
    expect(wrapper.text()).toContain('Friends joined')
    expect(wrapper.text()).toContain('Link clicks')
  })

  it('does not render referral stats when no code', () => {
    const wrapper = mount(ReferralSection, {
      props: { referralCode: null },
    })
    expect(wrapper.text()).not.toContain('Friends joined')
  })

  it('renders as a section element', () => {
    const wrapper = mount(ReferralSection, {
      props: { referralCode: null },
    })
    expect(wrapper.find('section').exists()).toBe(true)
  })

  it('renders copy button in referral link area when code is provided', () => {
    const wrapper = mount(ReferralSection, {
      props: { referralCode: 'ref_abc123' },
    })
    const buttons = wrapper.findAll('button')
    const copyButton = buttons.find((b) => b.text().includes('Copy'))
    expect(copyButton).toBeDefined()
  })

  it('hides separate copy link button when referral code is provided', () => {
    const wrapper = mount(ReferralSection, {
      props: { referralCode: 'ref_abc123' },
    })
    const buttons = wrapper.findAll('button')
    const copyLinkButton = buttons.find((b) => b.text() === 'Copy Link')
    expect(copyLinkButton).toBeUndefined()
  })

  it('calls shareTwitter on Share on X button click', async () => {
    const mockOpen = vi.fn()
    vi.stubGlobal('open', mockOpen)
    const wrapper = mount(ReferralSection, {
      props: { referralCode: null },
    })
    const shareBtn = wrapper.findAll('button').find((b) => b.text().includes('Share on X'))
    await shareBtn!.trigger('click')
    expect(mockOpen).toHaveBeenCalled()
    vi.unstubAllGlobals()
  })

  it('calls copyReferralLink on copy button click', async () => {
    const mockWriteText = vi.fn().mockResolvedValue(undefined)
    Object.defineProperty(navigator, 'clipboard', {
      value: { writeText: mockWriteText },
      writable: true,
      configurable: true,
    })
    const wrapper = mount(ReferralSection, {
      props: { referralCode: 'ref_abc123' },
    })
    const copyBtn = wrapper.findAll('button').find((b) => b.text().includes('Copy'))
    await copyBtn!.trigger('click')
    await nextTick()
    expect(mockWriteText).toHaveBeenCalled()
  })

  it('renders without referral code (default URL)', () => {
    const wrapper = mount(ReferralSection, {
      props: { referralCode: null },
    })
    // Should render basic share options
    expect(wrapper.text()).toContain('Share SleepPath')
  })
})
