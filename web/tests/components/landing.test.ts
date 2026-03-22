import { describe, it, expect, vi } from 'vitest'
import { mount } from '@vue/test-utils'
import { nextTick } from 'vue'
import HeroSection from '../../app/components/landing/HeroSection.vue'
import SocialProof from '../../app/components/landing/SocialProof.vue'
import HowItWorks from '../../app/components/landing/HowItWorks.vue'
import ChronotypePreview from '../../app/components/landing/ChronotypePreview.vue'
import FaqSection from '../../app/components/landing/FaqSection.vue'
import CompatibilityTeaser from '../../app/components/landing/CompatibilityTeaser.vue'
import FooterCta from '../../app/components/landing/FooterCta.vue'
import SiteFooter from '../../app/components/landing/SiteFooter.vue'

// ─── HeroSection ──────────────────────────────────────────────────────────────
describe('HeroSection', () => {
  it('renders the headline text', () => {
    const wrapper = mount(HeroSection)
    expect(wrapper.text()).toContain('Your biology has a schedule.')
    expect(wrapper.text()).toContain('Start following it.')
  })

  it('renders the subheadline text', () => {
    const wrapper = mount(HeroSection)
    expect(wrapper.text()).toContain('Discover your chronotype')
  })

  it('renders the CTA button with correct text', () => {
    const wrapper = mount(HeroSection)
    const button = wrapper.find('button')
    expect(button.exists()).toBe(true)
    expect(button.text()).toContain('Take the Free Quiz')
  })

  it('emits start-quiz when CTA button is clicked', async () => {
    const wrapper = mount(HeroSection)
    await wrapper.find('button').trigger('click')
    expect(wrapper.emitted('start-quiz')).toHaveLength(1)
  })

  it('renders the "60 seconds" reassurance text', () => {
    const wrapper = mount(HeroSection)
    expect(wrapper.text()).toContain('60 seconds. No signup required.')
  })
})

// ─── SocialProof ──────────────────────────────────────────────────────────────
describe('SocialProof', () => {
  it('renders trust text with user count', () => {
    const wrapper = mount(SocialProof)
    expect(wrapper.text()).toContain('10,000+')
    expect(wrapper.text()).toContain('discovered their chronotype')
  })

  it('renders star rating', () => {
    const wrapper = mount(SocialProof)
    expect(wrapper.text()).toContain('4.8')
    // 5 star SVGs
    const stars = wrapper.findAll('svg')
    expect(stars.length).toBe(5)
  })

  it('renders as a section element', () => {
    const wrapper = mount(SocialProof)
    expect(wrapper.find('section').exists()).toBe(true)
  })
})

// ─── HowItWorks ──────────────────────────────────────────────────────────────
describe('HowItWorks', () => {
  it('renders the section heading', () => {
    const wrapper = mount(HowItWorks)
    expect(wrapper.text()).toContain('How It Works')
  })

  it('renders 3 steps', () => {
    const wrapper = mount(HowItWorks)
    expect(wrapper.text()).toContain('Take the Quiz')
    expect(wrapper.text()).toContain('Discover Your Type')
    expect(wrapper.text()).toContain('Get Your Schedule')
  })

  it('renders step numbers 1, 2, 3', () => {
    const wrapper = mount(HowItWorks)
    const text = wrapper.text()
    expect(text).toContain('1')
    expect(text).toContain('2')
    expect(text).toContain('3')
  })

  it('renders step descriptions', () => {
    const wrapper = mount(HowItWorks)
    expect(wrapper.text()).toContain('8 quick questions')
    expect(wrapper.text()).toContain('Lion, Bear, Wolf, or Dolphin')
    expect(wrapper.text()).toContain('Personalized daily timing')
  })

  it('renders subtitle text', () => {
    const wrapper = mount(HowItWorks)
    expect(wrapper.text()).toContain('Three steps to a schedule built for your biology.')
  })
})

// ─── ChronotypePreview ──────────────────────────────────────────────────────
describe('ChronotypePreview', () => {
  it('renders 4 chronotype cards', () => {
    const wrapper = mount(ChronotypePreview)
    const cards = wrapper.findAll('.grid > div')
    expect(cards.length).toBe(4)
  })

  it('renders correct chronotype names', () => {
    const wrapper = mount(ChronotypePreview)
    expect(wrapper.text()).toContain('Lion')
    expect(wrapper.text()).toContain('Bear')
    expect(wrapper.text()).toContain('Wolf')
    expect(wrapper.text()).toContain('Dolphin')
  })

  it('renders correct emojis', () => {
    const wrapper = mount(ChronotypePreview)
    const text = wrapper.text()
    expect(text).toContain('🦁')
    expect(text).toContain('🐻')
    expect(text).toContain('🐺')
    expect(text).toContain('🐬')
  })

  it('renders taglines for each chronotype', () => {
    const wrapper = mount(ChronotypePreview)
    expect(wrapper.text()).toContain('The Early Riser')
    expect(wrapper.text()).toContain('The Solar Tracker')
    expect(wrapper.text()).toContain('The Night Owl')
    expect(wrapper.text()).toContain('The Light Sleeper')
  })

  it('renders population percentages', () => {
    const wrapper = mount(ChronotypePreview)
    expect(wrapper.text()).toContain('~15% of people')
    expect(wrapper.text()).toContain('~50% of people')
    expect(wrapper.text()).toContain('~10% of people')
  })

  it('renders the section heading', () => {
    const wrapper = mount(ChronotypePreview)
    expect(wrapper.text()).toContain('Four Chronotypes. Which One Are You?')
  })
})

// ─── FaqSection ─────────────────────────────────────────────────────────────
describe('FaqSection', () => {
  it('renders the section heading', () => {
    const wrapper = mount(FaqSection)
    expect(wrapper.text()).toContain('Questions & Answers')
  })

  it('renders all 5 FAQ questions', () => {
    const wrapper = mount(FaqSection)
    expect(wrapper.text()).toContain('What is a chronotype?')
    expect(wrapper.text()).toContain('Is the quiz accurate?')
    expect(wrapper.text()).toContain('Is it really free?')
    expect(wrapper.text()).toContain('How long does it take?')
    expect(wrapper.text()).toContain('Will you sell my data?')
  })

  it('starts with all FAQs closed (answers hidden via max-h-0)', () => {
    const wrapper = mount(FaqSection)
    const answerContainers = wrapper.findAll('.max-h-0')
    expect(answerContainers.length).toBe(5)
  })

  it('toggles FAQ open on click', async () => {
    const wrapper = mount(FaqSection)
    const buttons = wrapper.findAll('button')
    // Click first FAQ
    await buttons[0].trigger('click')
    await nextTick()
    // First answer container should now have max-h-64 (open)
    const openContainers = wrapper.findAll('.max-h-64')
    expect(openContainers.length).toBe(1)
  })

  it('closes an open FAQ when clicked again', async () => {
    const wrapper = mount(FaqSection)
    const buttons = wrapper.findAll('button')
    // Open first FAQ
    await buttons[0].trigger('click')
    await nextTick()
    expect(wrapper.findAll('.max-h-64').length).toBe(1)
    // Close it
    await buttons[0].trigger('click')
    await nextTick()
    expect(wrapper.findAll('.max-h-64').length).toBe(0)
    expect(wrapper.findAll('.max-h-0').length).toBe(5)
  })

  it('closes previous FAQ when opening a new one', async () => {
    const wrapper = mount(FaqSection)
    const buttons = wrapper.findAll('button')
    // Open first FAQ
    await buttons[0].trigger('click')
    await nextTick()
    // Open second FAQ (first should close)
    await buttons[1].trigger('click')
    await nextTick()
    const openContainers = wrapper.findAll('.max-h-64')
    expect(openContainers.length).toBe(1)
  })

  it('renders FAQ answers in the DOM', () => {
    const wrapper = mount(FaqSection)
    // Answers are in DOM but hidden, check they exist
    expect(wrapper.text()).toContain('chronotype is your body')
    expect(wrapper.text()).toContain('Dr. Michael Breus')
  })
})

// ─── CompatibilityTeaser ────────────────────────────────────────────────────
describe('CompatibilityTeaser', () => {
  it('renders the CTA text', () => {
    const wrapper = mount(CompatibilityTeaser, {
      global: {
        stubs: {
          NuxtLink: {
            template: '<a @click="$emit(\'click\')"><slot /></a>',
          },
        },
      },
    })
    expect(wrapper.text()).toContain('Do you sleep with a Wolf?')
    expect(wrapper.text()).toContain('Find out.')
  })

  it('renders the description text', () => {
    const wrapper = mount(CompatibilityTeaser, {
      global: {
        stubs: {
          NuxtLink: {
            template: '<a><slot /></a>',
          },
        },
      },
    })
    expect(wrapper.text()).toContain('Couples often have different biological clocks')
  })

  it('emits compatibility-click when CTA link is clicked', async () => {
    const wrapper = mount(CompatibilityTeaser, {
      global: {
        stubs: {
          NuxtLink: {
            template: '<a @click="$emit(\'click\')"><slot /></a>',
          },
        },
      },
    })
    await wrapper.find('a').trigger('click')
    expect(wrapper.emitted('compatibility-click')).toBeTruthy()
    expect(wrapper.emitted('compatibility-click')!.length).toBeGreaterThanOrEqual(1)
  })

  it('renders the "See how it works" link text', () => {
    const wrapper = mount(CompatibilityTeaser, {
      global: {
        stubs: {
          NuxtLink: {
            template: '<a><slot /></a>',
          },
        },
      },
    })
    expect(wrapper.text()).toContain('See how it works')
  })

  it('renders the "No account needed" reassurance', () => {
    const wrapper = mount(CompatibilityTeaser, {
      global: {
        stubs: {
          NuxtLink: {
            template: '<a><slot /></a>',
          },
        },
      },
    })
    expect(wrapper.text()).toContain('No account needed')
  })
})

// ─── FooterCta ──────────────────────────────────────────────────────────────
describe('FooterCta', () => {
  it('renders the CTA heading', () => {
    const wrapper = mount(FooterCta)
    expect(wrapper.text()).toContain('Ready to discover your chronotype?')
  })

  it('renders the CTA button', () => {
    const wrapper = mount(FooterCta)
    const button = wrapper.find('button')
    expect(button.exists()).toBe(true)
    expect(button.text()).toContain('Take the Free Quiz')
  })

  it('emits start-quiz when button is clicked', async () => {
    const wrapper = mount(FooterCta)
    await wrapper.find('button').trigger('click')
    expect(wrapper.emitted('start-quiz')).toHaveLength(1)
  })

  it('renders the description text', () => {
    const wrapper = mount(FooterCta)
    expect(wrapper.text()).toContain('60 seconds')
    expect(wrapper.text()).toContain('change the way you structure every day')
  })
})

// ─── SiteFooter ─────────────────────────────────────────────────────────────
describe('SiteFooter', () => {
  it('renders copyright text', () => {
    const wrapper = mount(SiteFooter)
    expect(wrapper.text()).toContain('2026 Fibonacci Labs')
  })

  it('renders a footer element', () => {
    const wrapper = mount(SiteFooter)
    expect(wrapper.find('footer').exists()).toBe(true)
  })

  it('renders Privacy and Terms links', () => {
    const wrapper = mount(SiteFooter)
    expect(wrapper.text()).toContain('Privacy')
    expect(wrapper.text()).toContain('Terms')
  })

  it('renders navigation links as anchor elements', () => {
    const wrapper = mount(SiteFooter)
    const links = wrapper.findAll('a')
    expect(links.length).toBe(2)
  })
})
