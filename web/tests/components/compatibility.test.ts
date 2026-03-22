import { describe, it, expect, vi, afterEach } from 'vitest'
import { mount } from '@vue/test-utils'
import { nextTick } from 'vue'
import ChronotypePicker from '../../app/components/compatibility/ChronotypePicker.vue'
import CompatibilityCard from '../../app/components/compatibility/CompatibilityCard.vue'
import CompatibilityShare from '../../app/components/compatibility/CompatibilityShare.vue'

// Mock analytics module
vi.mock('../../app/lib/analytics', () => ({
  trackEvent: vi.fn(),
  getShareLinks: vi.fn((code: string, opts: { text: string; url: string }) => ({
    twitter: `https://twitter.com/intent/tweet?text=${encodeURIComponent(opts.text)}&url=${encodeURIComponent(opts.url)}`,
    whatsapp: `https://wa.me/?text=${encodeURIComponent(opts.text)}%20${encodeURIComponent(opts.url)}`,
    copy: opts.url,
  })),
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

// ─── ChronotypePicker ───────────────────────────────────────────────────────
describe('ChronotypePicker', () => {
  it('renders the label text', () => {
    const wrapper = mount(ChronotypePicker, {
      props: { label: 'Your chronotype', modelValue: null },
    })
    expect(wrapper.text()).toContain('Your chronotype')
  })

  it('renders 4 chronotype cards', () => {
    const wrapper = mount(ChronotypePicker, {
      props: { label: 'Pick yours', modelValue: null },
    })
    const buttons = wrapper.findAll('button')
    expect(buttons.length).toBe(4)
  })

  it('renders all chronotype names', () => {
    const wrapper = mount(ChronotypePicker, {
      props: { label: 'Your type', modelValue: null },
    })
    expect(wrapper.text()).toContain('Lion')
    expect(wrapper.text()).toContain('Bear')
    expect(wrapper.text()).toContain('Wolf')
    expect(wrapper.text()).toContain('Dolphin')
  })

  it('renders all chronotype emojis', () => {
    const wrapper = mount(ChronotypePicker, {
      props: { label: 'Your type', modelValue: null },
    })
    expect(wrapper.text()).toContain('🦁')
    expect(wrapper.text()).toContain('🐻')
    expect(wrapper.text()).toContain('🐺')
    expect(wrapper.text()).toContain('🐬')
  })

  it('renders taglines for each chronotype', () => {
    const wrapper = mount(ChronotypePicker, {
      props: { label: 'Your type', modelValue: null },
    })
    expect(wrapper.text()).toContain('The Early Riser')
    expect(wrapper.text()).toContain('The Solar Tracker')
    expect(wrapper.text()).toContain('The Night Owl')
    expect(wrapper.text()).toContain('The Light Sleeper')
  })

  it('emits update:modelValue when a card is clicked', async () => {
    const wrapper = mount(ChronotypePicker, {
      props: { label: 'Your type', modelValue: null },
    })
    const buttons = wrapper.findAll('button')
    await buttons[0].trigger('click')
    expect(wrapper.emitted('update:modelValue')).toBeTruthy()
    expect(wrapper.emitted('update:modelValue')![0]).toEqual(['lion'])
  })

  it('emits correct value for each chronotype', async () => {
    const wrapper = mount(ChronotypePicker, {
      props: { label: 'Your type', modelValue: null },
    })
    const buttons = wrapper.findAll('button')
    await buttons[1].trigger('click')
    expect(wrapper.emitted('update:modelValue')![0]).toEqual(['bear'])
    await buttons[2].trigger('click')
    expect(wrapper.emitted('update:modelValue')![1]).toEqual(['wolf'])
    await buttons[3].trigger('click')
    expect(wrapper.emitted('update:modelValue')![2]).toEqual(['dolphin'])
  })

  it('highlights the selected card with primary border', () => {
    const wrapper = mount(ChronotypePicker, {
      props: { label: 'Your type', modelValue: 'bear' },
    })
    const buttons = wrapper.findAll('button')
    // Bear is index 1
    expect(buttons[1].classes()).toContain('border-primary')
  })

  it('shows selection indicator checkmark on selected card', () => {
    const wrapper = mount(ChronotypePicker, {
      props: { label: 'Your type', modelValue: 'wolf' },
    })
    // The selection indicator div with bg-primary and checkmark should exist
    const indicator = wrapper.find('.bg-primary')
    expect(indicator.exists()).toBe(true)
  })

  it('does not show selection indicator when nothing is selected', () => {
    const wrapper = mount(ChronotypePicker, {
      props: { label: 'Your type', modelValue: null },
    })
    // No card should have the bg-primary/5 active styling
    const buttons = wrapper.findAll('button')
    buttons.forEach((btn) => {
      expect(btn.classes()).not.toContain('border-primary')
    })
  })

  it('renders different labels correctly', () => {
    const wrapper = mount(ChronotypePicker, {
      props: { label: "Their chronotype", modelValue: null },
    })
    expect(wrapper.text()).toContain("Their chronotype")
  })

  it('applies active background class on selected card', () => {
    const wrapper = mount(ChronotypePicker, {
      props: { label: 'Your type', modelValue: 'lion' },
    })
    const buttons = wrapper.findAll('button')
    expect(buttons[0].classes()).toContain('bg-primary/5')
  })

  it('applies inactive border class on unselected cards', () => {
    const wrapper = mount(ChronotypePicker, {
      props: { label: 'Your type', modelValue: 'lion' },
    })
    const buttons = wrapper.findAll('button')
    // Bear (index 1) should have the inactive border style
    expect(buttons[1].classes()).toContain('border-border')
  })

  it('does not show checkmark indicator on unselected cards', () => {
    const wrapper = mount(ChronotypePicker, {
      props: { label: 'Your type', modelValue: 'dolphin' },
    })
    // Only one selection indicator should exist (on dolphin, index 3)
    const indicators = wrapper.findAll('.bg-primary')
    expect(indicators.length).toBe(1)
  })

  it('renders the chronotype cards in correct order: lion, bear, wolf, dolphin', () => {
    const wrapper = mount(ChronotypePicker, {
      props: { label: 'Your type', modelValue: null },
    })
    const buttons = wrapper.findAll('button')
    expect(buttons[0].text()).toContain('Lion')
    expect(buttons[1].text()).toContain('Bear')
    expect(buttons[2].text()).toContain('Wolf')
    expect(buttons[3].text()).toContain('Dolphin')
  })

  it('renders emoji within each button alongside its name', () => {
    const wrapper = mount(ChronotypePicker, {
      props: { label: 'Your type', modelValue: null },
    })
    const buttons = wrapper.findAll('button')
    expect(buttons[0].text()).toContain('🦁')
    expect(buttons[0].text()).toContain('Lion')
    expect(buttons[2].text()).toContain('🐺')
    expect(buttons[2].text()).toContain('Wolf')
  })

  it('emits the correct type id when clicking each card sequentially', async () => {
    const wrapper = mount(ChronotypePicker, {
      props: { label: 'Your type', modelValue: null },
    })
    const buttons = wrapper.findAll('button')
    await buttons[0].trigger('click')
    await buttons[3].trigger('click')
    const emitted = wrapper.emitted('update:modelValue')!
    expect(emitted[0]).toEqual(['lion'])
    expect(emitted[1]).toEqual(['dolphin'])
  })

  it('applies selected text color on the selected card name', () => {
    const wrapper = mount(ChronotypePicker, {
      props: { label: 'Your type', modelValue: 'bear' },
    })
    const buttons = wrapper.findAll('button')
    // The selected bear card should have text-foreground on the name span
    const nameSpan = buttons[1].findAll('span').find(s => s.text() === 'Bear')
    expect(nameSpan?.classes()).toContain('text-foreground')
  })
})

// ─── CompatibilityCard ──────────────────────────────────────────────────────
describe('CompatibilityCard', () => {
  it('renders both chronotype emojis', () => {
    const wrapper = mount(CompatibilityCard, {
      props: { selfType: 'lion', partnerType: 'wolf' },
    })
    expect(wrapper.text()).toContain('🦁')
    expect(wrapper.text()).toContain('🐺')
  })

  it('renders both chronotype names', () => {
    const wrapper = mount(CompatibilityCard, {
      props: { selfType: 'bear', partnerType: 'dolphin' },
    })
    expect(wrapper.text()).toContain('Bear')
    expect(wrapper.text()).toContain('Dolphin')
  })

  it('renders "You" and "Them" labels', () => {
    const wrapper = mount(CompatibilityCard, {
      props: { selfType: 'lion', partnerType: 'bear' },
    })
    expect(wrapper.text()).toContain('You')
    expect(wrapper.text()).toContain('Them')
  })

  it('renders the pairing name', () => {
    const wrapper = mount(CompatibilityCard, {
      props: { selfType: 'lion', partnerType: 'wolf' },
    })
    expect(wrapper.text()).toContain('The Midnight Sun Pair')
  })

  it('renders the best overlap window', () => {
    const wrapper = mount(CompatibilityCard, {
      props: { selfType: 'lion', partnerType: 'wolf' },
    })
    expect(wrapper.text()).toContain('Best Overlap Window')
    expect(wrapper.text()).toContain('12:00 PM')
  })

  it('renders the worth knowing section', () => {
    const wrapper = mount(CompatibilityCard, {
      props: { selfType: 'bear', partnerType: 'bear' },
    })
    expect(wrapper.text()).toContain('Worth Knowing')
    expect(wrapper.text()).toContain('most common pairing')
  })

  it('renders the overlap score', () => {
    const wrapper = mount(CompatibilityCard, {
      props: { selfType: 'bear', partnerType: 'bear' },
    })
    expect(wrapper.text()).toContain('Overlap Score')
    expect(wrapper.text()).toContain('5/5')
  })

  it('renders correct overlap score for low-overlap pairing', () => {
    const wrapper = mount(CompatibilityCard, {
      props: { selfType: 'lion', partnerType: 'wolf' },
    })
    expect(wrapper.text()).toContain('1/5')
  })

  it('renders 5 overlap dots', () => {
    const wrapper = mount(CompatibilityCard, {
      props: { selfType: 'lion', partnerType: 'bear' },
    })
    // Find the overlap score area — should have 5 dot spans
    const dots = wrapper.findAll('.rounded-full.h-2\\.5')
    expect(dots.length).toBe(5)
  })

  it('renders the sleeppath.app/compatibility branding', () => {
    const wrapper = mount(CompatibilityCard, {
      props: { selfType: 'lion', partnerType: 'bear' },
    })
    expect(wrapper.text()).toContain('sleeppath.app/compatibility')
  })

  it('renders correct pairing for same types', () => {
    const wrapper = mount(CompatibilityCard, {
      props: { selfType: 'wolf', partnerType: 'wolf' },
    })
    expect(wrapper.text()).toContain('The Late Night Society')
    expect(wrapper.text()).toContain('5/5')
  })

  it('renders the best window for bear-lion pairing', () => {
    const wrapper = mount(CompatibilityCard, {
      props: { selfType: 'bear', partnerType: 'lion' },
    })
    expect(wrapper.text()).toContain('The Early Start and the Steady State')
    expect(wrapper.text()).toContain('8:00 AM')
  })

  it('renders dolphin-dolphin pairing correctly', () => {
    const wrapper = mount(CompatibilityCard, {
      props: { selfType: 'dolphin', partnerType: 'dolphin' },
    })
    expect(wrapper.text()).toContain('The Midnight Overthinkers')
    expect(wrapper.text()).toContain('4/5')
  })

  it('renders bear-wolf pairing with correct overlap score', () => {
    const wrapper = mount(CompatibilityCard, {
      props: { selfType: 'bear', partnerType: 'wolf' },
    })
    expect(wrapper.text()).toContain('The Night Owl and the Middler')
    expect(wrapper.text()).toContain('3/5')
  })

  it('renders dolphin-wolf pairing correctly', () => {
    const wrapper = mount(CompatibilityCard, {
      props: { selfType: 'dolphin', partnerType: 'wolf' },
    })
    expect(wrapper.text()).toContain('Two Restless Ones')
    expect(wrapper.text()).toContain('3/5')
  })

  it('renders bear-dolphin pairing correctly', () => {
    const wrapper = mount(CompatibilityCard, {
      props: { selfType: 'bear', partnerType: 'dolphin' },
    })
    expect(wrapper.text()).toContain('The Easygoing and the Alert')
    expect(wrapper.text()).toContain('3/5')
  })

  it('renders dolphin-lion pairing correctly', () => {
    const wrapper = mount(CompatibilityCard, {
      props: { selfType: 'dolphin', partnerType: 'lion' },
    })
    expect(wrapper.text()).toContain('The Early Riser and the Light Sleeper')
    expect(wrapper.text()).toContain('3/5')
  })

  it('renders lion-lion pairing correctly', () => {
    const wrapper = mount(CompatibilityCard, {
      props: { selfType: 'lion', partnerType: 'lion' },
    })
    expect(wrapper.text()).toContain('The Dawn Chorus')
    expect(wrapper.text()).toContain('5/5')
  })

  it('renders the correct number of filled dots for overlap score 3', () => {
    const wrapper = mount(CompatibilityCard, {
      props: { selfType: 'bear', partnerType: 'wolf' },
    })
    const dots = wrapper.findAll('.rounded-full.h-2\\.5')
    const filledDots = dots.filter(d => d.classes().includes('bg-primary'))
    const emptyDots = dots.filter(d => d.classes().includes('bg-border'))
    expect(filledDots.length).toBe(3)
    expect(emptyDots.length).toBe(2)
  })

  it('renders the correct number of filled dots for overlap score 1', () => {
    const wrapper = mount(CompatibilityCard, {
      props: { selfType: 'lion', partnerType: 'wolf' },
    })
    const dots = wrapper.findAll('.rounded-full.h-2\\.5')
    const filledDots = dots.filter(d => d.classes().includes('bg-primary'))
    expect(filledDots.length).toBe(1)
  })

  it('renders self with correct bgColor class', () => {
    const wrapper = mount(CompatibilityCard, {
      props: { selfType: 'lion', partnerType: 'bear' },
    })
    // Lion has bgColor 'bg-amber-50'
    expect(wrapper.find('.bg-amber-50').exists()).toBe(true)
  })

  it('renders partner with correct bgColor class', () => {
    const wrapper = mount(CompatibilityCard, {
      props: { selfType: 'lion', partnerType: 'wolf' },
    })
    // Wolf has bgColor 'bg-violet-50'
    expect(wrapper.find('.bg-violet-50').exists()).toBe(true)
  })

  it('renders worth knowing text for lion-wolf pairing', () => {
    const wrapper = mount(CompatibilityCard, {
      props: { selfType: 'lion', partnerType: 'wolf' },
    })
    expect(wrapper.text()).toContain('hardest pairing for shared time')
  })

  it('is symmetric: wolf-bear produces the same pairing as bear-wolf', () => {
    const wrapper1 = mount(CompatibilityCard, {
      props: { selfType: 'wolf', partnerType: 'bear' },
    })
    const wrapper2 = mount(CompatibilityCard, {
      props: { selfType: 'bear', partnerType: 'wolf' },
    })
    // Same pairing name for both orderings
    expect(wrapper1.text()).toContain('The Night Owl and the Middler')
    expect(wrapper2.text()).toContain('The Night Owl and the Middler')
  })
})

// ─── CompatibilityShare ─────────────────────────────────────────────────────
describe('CompatibilityShare', () => {
  afterEach(() => {
    vi.restoreAllMocks()
  })

  it('renders the "Share your result" heading', () => {
    const wrapper = mount(CompatibilityShare, {
      props: { selfType: 'lion', partnerType: 'wolf', referralCode: null },
    })
    expect(wrapper.text()).toContain('Share your result')
  })

  it('renders share description text', () => {
    const wrapper = mount(CompatibilityShare, {
      props: { selfType: 'lion', partnerType: 'wolf', referralCode: null },
    })
    expect(wrapper.text()).toContain('Screenshot-worthy and ready to send')
  })

  it('renders Instagram share button', () => {
    const wrapper = mount(CompatibilityShare, {
      props: { selfType: 'lion', partnerType: 'wolf', referralCode: null },
    })
    expect(wrapper.text()).toContain('Instagram')
  })

  it('renders WhatsApp share button', () => {
    const wrapper = mount(CompatibilityShare, {
      props: { selfType: 'lion', partnerType: 'wolf', referralCode: null },
    })
    expect(wrapper.text()).toContain('WhatsApp')
  })

  it('renders Copy Link button', () => {
    const wrapper = mount(CompatibilityShare, {
      props: { selfType: 'lion', partnerType: 'wolf', referralCode: null },
    })
    expect(wrapper.text()).toContain('Copy Link')
  })

  it('renders the "Send them the quiz" section', () => {
    const wrapper = mount(CompatibilityShare, {
      props: { selfType: 'lion', partnerType: 'wolf', referralCode: null },
    })
    expect(wrapper.text()).toContain('Send them the quiz')
    expect(wrapper.text()).toContain('Get their real result')
  })

  it('renders WhatsApp invite button', () => {
    const wrapper = mount(CompatibilityShare, {
      props: { selfType: 'bear', partnerType: 'dolphin', referralCode: null },
    })
    expect(wrapper.text()).toContain('Send via WhatsApp')
  })

  it('renders Copy Quiz Link button', () => {
    const wrapper = mount(CompatibilityShare, {
      props: { selfType: 'bear', partnerType: 'dolphin', referralCode: null },
    })
    expect(wrapper.text()).toContain('Copy Quiz Link')
  })

  it('renders the Partner Mode section', () => {
    const wrapper = mount(CompatibilityShare, {
      props: { selfType: 'lion', partnerType: 'wolf', referralCode: null },
    })
    expect(wrapper.text()).toContain('Partner Mode')
    expect(wrapper.text()).toContain('Coming Soon')
  })

  it('renders the partner mode description', () => {
    const wrapper = mount(CompatibilityShare, {
      props: { selfType: 'lion', partnerType: 'wolf', referralCode: null },
    })
    expect(wrapper.text()).toContain('Shared schedules, wind-down nudges')
  })

  it('renders the email form for partner mode interest', () => {
    const wrapper = mount(CompatibilityShare, {
      props: { selfType: 'lion', partnerType: 'wolf', referralCode: null },
    })
    const emailInput = wrapper.find('input[type="email"]')
    expect(emailInput.exists()).toBe(true)
  })

  it('renders the Notify Me button', () => {
    const wrapper = mount(CompatibilityShare, {
      props: { selfType: 'lion', partnerType: 'wolf', referralCode: null },
    })
    expect(wrapper.text()).toContain('Notify Me')
  })

  it('emits shared when Instagram button is clicked', async () => {
    // Mock window.alert for Instagram sharing
    vi.spyOn(window, 'alert').mockImplementation(() => {})
    const wrapper = mount(CompatibilityShare, {
      props: { selfType: 'lion', partnerType: 'wolf', referralCode: null },
    })
    const instagramButton = wrapper.findAll('button').find((b) => b.text().includes('Instagram'))
    await instagramButton!.trigger('click')
    expect(wrapper.emitted('shared')).toHaveLength(1)
  })

  it('emits invite-sent when copy quiz link is clicked', async () => {
    const writeText = vi.fn().mockResolvedValue(undefined)
    Object.defineProperty(navigator, 'clipboard', {
      value: { writeText },
      writable: true,
      configurable: true,
    })
    const wrapper = mount(CompatibilityShare, {
      props: { selfType: 'lion', partnerType: 'wolf', referralCode: null },
    })
    const copyButton = wrapper.findAll('button').find((b) => b.text().includes('Copy Quiz Link'))
    await copyButton!.trigger('click')
    await nextTick()
    expect(wrapper.emitted('invite-sent')).toHaveLength(1)
  })

  it('emits shared when copy link is clicked', async () => {
    const writeText = vi.fn().mockResolvedValue(undefined)
    Object.defineProperty(navigator, 'clipboard', {
      value: { writeText },
      writable: true,
      configurable: true,
    })
    const wrapper = mount(CompatibilityShare, {
      props: { selfType: 'lion', partnerType: 'wolf', referralCode: null },
    })
    const copyButton = wrapper.findAll('button').find((b) => b.text() === 'Copy Link')
    await copyButton!.trigger('click')
    await nextTick()
    expect(wrapper.emitted('shared')).toHaveLength(1)
  })

  it('emits shared when WhatsApp share button is clicked', async () => {
    vi.spyOn(window, 'open').mockImplementation(() => null)
    const wrapper = mount(CompatibilityShare, {
      props: { selfType: 'lion', partnerType: 'wolf', referralCode: null },
    })
    const whatsappButtons = wrapper.findAll('button').filter((b) => b.text().includes('WhatsApp'))
    // The first WhatsApp button is the share one (not the invite one)
    const shareWhatsApp = whatsappButtons[0]
    await shareWhatsApp.trigger('click')
    expect(wrapper.emitted('shared')).toHaveLength(1)
    expect(window.open).toHaveBeenCalled()
  })

  it('emits invite-sent when WhatsApp invite button is clicked', async () => {
    vi.spyOn(window, 'open').mockImplementation(() => null)
    const wrapper = mount(CompatibilityShare, {
      props: { selfType: 'bear', partnerType: 'dolphin', referralCode: null },
    })
    const sendButton = wrapper.findAll('button').find((b) => b.text().includes('Send via WhatsApp'))
    await sendButton!.trigger('click')
    expect(wrapper.emitted('invite-sent')).toHaveLength(1)
    expect(window.open).toHaveBeenCalled()
  })

  it('emits partner-mode-interest when email form is submitted', async () => {
    const wrapper = mount(CompatibilityShare, {
      props: { selfType: 'lion', partnerType: 'wolf', referralCode: null },
    })
    const form = wrapper.find('form')
    await form.trigger('submit')
    await nextTick()
    expect(wrapper.emitted('partner-mode-interest')).toHaveLength(1)
  })

  it('includes referral code in share URL when provided', () => {
    const wrapper = mount(CompatibilityShare, {
      props: { selfType: 'lion', partnerType: 'wolf', referralCode: 'ref_abc123' },
    })
    // The component should use the referral code; verify it renders without error
    expect(wrapper.text()).toContain('Share your result')
  })

  it('shows "Copied!" text after copy link is clicked', async () => {
    const writeText = vi.fn().mockResolvedValue(undefined)
    Object.defineProperty(navigator, 'clipboard', {
      value: { writeText },
      writable: true,
      configurable: true,
    })
    const wrapper = mount(CompatibilityShare, {
      props: { selfType: 'lion', partnerType: 'wolf', referralCode: null },
    })
    const copyButton = wrapper.findAll('button').find((b) => b.text() === 'Copy Link')
    await copyButton!.trigger('click')
    await nextTick()
    expect(wrapper.text()).toContain('Copied!')
  })

  it('shows "Copied!" text after copy quiz link is clicked', async () => {
    const writeText = vi.fn().mockResolvedValue(undefined)
    Object.defineProperty(navigator, 'clipboard', {
      value: { writeText },
      writable: true,
      configurable: true,
    })
    const wrapper = mount(CompatibilityShare, {
      props: { selfType: 'lion', partnerType: 'wolf', referralCode: null },
    })
    const copyButton = wrapper.findAll('button').find((b) => b.text().includes('Copy Quiz Link'))
    await copyButton!.trigger('click')
    await nextTick()
    expect(wrapper.text()).toContain('Copied!')
  })

  it('calls navigator.clipboard.writeText when copy link is clicked', async () => {
    const writeText = vi.fn().mockResolvedValue(undefined)
    Object.defineProperty(navigator, 'clipboard', {
      value: { writeText },
      writable: true,
      configurable: true,
    })
    const wrapper = mount(CompatibilityShare, {
      props: { selfType: 'lion', partnerType: 'wolf', referralCode: null },
    })
    const copyButton = wrapper.findAll('button').find((b) => b.text() === 'Copy Link')
    await copyButton!.trigger('click')
    await nextTick()
    expect(writeText).toHaveBeenCalledWith('https://sleeppath.app/compatibility')
  })

  it('includes referral code in clipboard text when provided', async () => {
    const writeText = vi.fn().mockResolvedValue(undefined)
    Object.defineProperty(navigator, 'clipboard', {
      value: { writeText },
      writable: true,
      configurable: true,
    })
    const wrapper = mount(CompatibilityShare, {
      props: { selfType: 'lion', partnerType: 'wolf', referralCode: 'ref_xyz' },
    })
    const copyButton = wrapper.findAll('button').find((b) => b.text() === 'Copy Link')
    await copyButton!.trigger('click')
    await nextTick()
    expect(writeText).toHaveBeenCalledWith('https://sleeppath.app/compatibility?ref=ref_xyz')
  })

  it('calls navigator.clipboard.writeText with invite link when copy quiz link is clicked', async () => {
    const writeText = vi.fn().mockResolvedValue(undefined)
    Object.defineProperty(navigator, 'clipboard', {
      value: { writeText },
      writable: true,
      configurable: true,
    })
    const wrapper = mount(CompatibilityShare, {
      props: { selfType: 'bear', partnerType: 'dolphin', referralCode: null },
    })
    const copyButton = wrapper.findAll('button').find((b) => b.text().includes('Copy Quiz Link'))
    await copyButton!.trigger('click')
    await nextTick()
    expect(writeText).toHaveBeenCalledWith(
      expect.stringContaining('https://sleeppath.app/quiz?')
    )
    expect(writeText).toHaveBeenCalledWith(
      expect.stringContaining('entry=compatibility')
    )
    expect(writeText).toHaveBeenCalledWith(
      expect.stringContaining('referrer_type=bear')
    )
  })

  it('opens WhatsApp URL when WhatsApp share button is clicked', async () => {
    const openSpy = vi.spyOn(window, 'open').mockImplementation(() => null)
    const wrapper = mount(CompatibilityShare, {
      props: { selfType: 'lion', partnerType: 'wolf', referralCode: null },
    })
    const whatsappButtons = wrapper.findAll('button').filter((b) => b.text().includes('WhatsApp'))
    await whatsappButtons[0].trigger('click')
    expect(openSpy).toHaveBeenCalledWith(
      expect.stringContaining('wa.me'),
      '_blank',
      'noopener'
    )
  })

  it('opens WhatsApp invite URL when send via WhatsApp is clicked', async () => {
    const openSpy = vi.spyOn(window, 'open').mockImplementation(() => null)
    const wrapper = mount(CompatibilityShare, {
      props: { selfType: 'lion', partnerType: 'wolf', referralCode: null },
    })
    const sendButton = wrapper.findAll('button').find((b) => b.text().includes('Send via WhatsApp'))
    await sendButton!.trigger('click')
    expect(openSpy).toHaveBeenCalledWith(
      expect.stringContaining('wa.me'),
      '_blank',
      'noopener'
    )
  })

  it('calls window.alert when Instagram button is clicked', async () => {
    const alertSpy = vi.spyOn(window, 'alert').mockImplementation(() => {})
    const wrapper = mount(CompatibilityShare, {
      props: { selfType: 'lion', partnerType: 'wolf', referralCode: null },
    })
    const instagramButton = wrapper.findAll('button').find((b) => b.text().includes('Instagram'))
    await instagramButton!.trigger('click')
    expect(alertSpy).toHaveBeenCalledWith(
      expect.stringContaining('Screenshot the compatibility card')
    )
  })

  it('renders email input with correct placeholder', () => {
    const wrapper = mount(CompatibilityShare, {
      props: { selfType: 'lion', partnerType: 'wolf', referralCode: null },
    })
    const input = wrapper.find('input[type="email"]')
    expect(input.attributes('placeholder')).toBe('you@example.com')
  })

  it('renders email input with autocomplete attribute', () => {
    const wrapper = mount(CompatibilityShare, {
      props: { selfType: 'lion', partnerType: 'wolf', referralCode: null },
    })
    const input = wrapper.find('input[type="email"]')
    expect(input.attributes('autocomplete')).toBe('email')
  })

  it('renders three share buttons in the share section', () => {
    const wrapper = mount(CompatibilityShare, {
      props: { selfType: 'lion', partnerType: 'wolf', referralCode: null },
    })
    // Instagram, WhatsApp, Copy Link in the share section
    const allButtons = wrapper.findAll('button')
    const shareButtons = allButtons.filter((b) =>
      b.text().includes('Instagram') ||
      (b.text().includes('WhatsApp') && !b.text().includes('Send via')) ||
      b.text() === 'Copy Link'
    )
    expect(shareButtons.length).toBe(3)
  })

  it('renders two invite action buttons', () => {
    const wrapper = mount(CompatibilityShare, {
      props: { selfType: 'lion', partnerType: 'wolf', referralCode: null },
    })
    const allButtons = wrapper.findAll('button')
    const inviteButtons = allButtons.filter((b) =>
      b.text().includes('Send via WhatsApp') ||
      b.text().includes('Copy Quiz Link')
    )
    expect(inviteButtons.length).toBe(2)
  })

  it('does not emit shared when clipboard.writeText fails', async () => {
    const writeText = vi.fn().mockRejectedValue(new Error('clipboard error'))
    Object.defineProperty(navigator, 'clipboard', {
      value: { writeText },
      writable: true,
      configurable: true,
    })
    const wrapper = mount(CompatibilityShare, {
      props: { selfType: 'lion', partnerType: 'wolf', referralCode: null },
    })
    const copyButton = wrapper.findAll('button').find((b) => b.text() === 'Copy Link')
    await copyButton!.trigger('click')
    await nextTick()
    expect(wrapper.emitted('shared')).toBeUndefined()
  })

  it('does not emit invite-sent when clipboard.writeText fails for quiz link', async () => {
    const writeText = vi.fn().mockRejectedValue(new Error('clipboard error'))
    Object.defineProperty(navigator, 'clipboard', {
      value: { writeText },
      writable: true,
      configurable: true,
    })
    const wrapper = mount(CompatibilityShare, {
      props: { selfType: 'lion', partnerType: 'wolf', referralCode: null },
    })
    const copyButton = wrapper.findAll('button').find((b) => b.text().includes('Copy Quiz Link'))
    await copyButton!.trigger('click')
    await nextTick()
    expect(wrapper.emitted('invite-sent')).toBeUndefined()
  })

  it('renders with different chronotype pairing props', () => {
    const wrapper = mount(CompatibilityShare, {
      props: { selfType: 'dolphin', partnerType: 'dolphin', referralCode: 'ref_test' },
    })
    expect(wrapper.text()).toContain('Share your result')
    expect(wrapper.text()).toContain('Send them the quiz')
    expect(wrapper.text()).toContain('Partner Mode')
  })
})
