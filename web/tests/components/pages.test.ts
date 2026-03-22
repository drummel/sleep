import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'
import { mount } from '@vue/test-utils'
import { nextTick, ref, computed } from 'vue'
import { quizQuestions } from '../../app/lib/quiz-questions'

// ─── Mocks ────────────────────────────────────────────────────────────────────

// Mock analytics module
vi.mock('../../app/lib/analytics', () => ({
  trackEvent: vi.fn(),
  getShareLinks: vi.fn((code: string, opts: { text: string; url: string }) => ({
    twitter: `https://twitter.com/intent/tweet?text=${encodeURIComponent(opts.text)}&url=${encodeURIComponent(opts.url)}`,
    whatsapp: `https://wa.me/?text=${encodeURIComponent(opts.text)}%20${encodeURIComponent(opts.url)}`,
    copy: opts.url,
  })),
  joinWaitlist: vi.fn().mockResolvedValue({ success: true, referral_code: 'ref_test123' }),
  submitFeatureSurvey: vi.fn().mockResolvedValue({ success: true }),
}))

// Create shared mock state for useQuiz
const mockCurrentQuestion = ref(0)
const mockIsComplete = ref(false)
const mockResult = ref<any>(null)
const mockPartnerRef = ref<string | null>(null)
const mockReferrerChronotype = ref<string | null>(null)
const mockEntryPoint = ref<'solo' | 'compatibility'>('solo')
const mockAnswers = ref<number[]>([])

const mockStartQuiz = vi.fn()
const mockAnswerQuestion = vi.fn()
const mockGoBack = vi.fn()
const mockSetPartnerRef = vi.fn()
const mockResetQuiz = vi.fn()

vi.mock('../../app/composables/useQuiz', () => ({
  useQuiz: () => ({
    currentQuestion: mockCurrentQuestion,
    isComplete: mockIsComplete,
    result: mockResult,
    totalQuestions: computed(() => quizQuestions.length),
    progress: computed(() => (mockCurrentQuestion.value / quizQuestions.length) * 100),
    currentQuestionData: computed(() => quizQuestions[mockCurrentQuestion.value] ?? null),
    isLastQuestion: computed(() => mockCurrentQuestion.value === quizQuestions.length - 1),
    startQuiz: mockStartQuiz,
    answerQuestion: mockAnswerQuestion,
    goBack: mockGoBack,
    setPartnerRef: mockSetPartnerRef,
    resetQuiz: mockResetQuiz,
    partnerRef: mockPartnerRef,
    referrerChronotype: mockReferrerChronotype,
    entryPoint: mockEntryPoint,
    answers: mockAnswers,
  }),
}))

// Mock useEmail composable
const mockReferralCode = ref<string | null>(null)

vi.mock('../../app/composables/useEmail', () => ({
  useEmail: () => ({
    email: ref(''),
    isSubmitted: ref(false),
    isLoading: ref(false),
    referralCode: mockReferralCode,
    error: ref(null),
    submitEmail: vi.fn().mockResolvedValue(true),
    submitPartnerModeEmail: vi.fn().mockResolvedValue(true),
    resetEmail: vi.fn(),
  }),
}))

// ─── Import page components after mocks ─────────────────────────────────────
import IndexPage from '../../app/pages/index.vue'
import QuizPage from '../../app/pages/quiz.vue'
import ResultPage from '../../app/pages/result.vue'
import CompatibilityPage from '../../app/pages/compatibility.vue'

// ─── Helpers ────────────────────────────────────────────────────────────────
function resetMocks() {
  mockCurrentQuestion.value = 0
  mockIsComplete.value = false
  mockResult.value = null
  mockPartnerRef.value = null
  mockReferrerChronotype.value = null
  mockEntryPoint.value = 'solo'
  mockAnswers.value = []
  mockReferralCode.value = null
  mockStartQuiz.mockClear()
  mockAnswerQuestion.mockClear()
  mockGoBack.mockClear()
  mockSetPartnerRef.mockClear()
  mockResetQuiz.mockClear()
}

// ─── Index Page ─────────────────────────────────────────────────────────────
describe('Index Page', () => {
  beforeEach(() => {
    resetMocks()
  })

  const globalStubs = {
    stubs: {
      LandingHeroSection: { template: '<div class="hero-stub" @click="$emit(\'start-quiz\')">Hero</div>', emits: ['start-quiz'] },
      LandingSocialProof: { template: '<div>SocialProof</div>' },
      LandingHowItWorks: { template: '<div>HowItWorks</div>' },
      LandingChronotypePreview: { template: '<div>ChronotypePreview</div>' },
      LandingFaqSection: { template: '<div>FaqSection</div>' },
      LandingCompatibilityTeaser: { template: '<div class="compat-stub" @click="$emit(\'compatibility-click\')">CompatibilityTeaser</div>', emits: ['compatibility-click'] },
      LandingFooterCta: { template: '<div class="footer-cta-stub" @click="$emit(\'start-quiz\')">FooterCta</div>', emits: ['start-quiz'] },
      LandingSiteFooter: { template: '<div>SiteFooter</div>' },
    },
  }

  it('renders without errors', () => {
    const wrapper = mount(IndexPage, { global: globalStubs })
    expect(wrapper.exists()).toBe(true)
  })

  it('renders all landing page sections', () => {
    const wrapper = mount(IndexPage, { global: globalStubs })
    expect(wrapper.text()).toContain('Hero')
    expect(wrapper.text()).toContain('SocialProof')
    expect(wrapper.text()).toContain('HowItWorks')
    expect(wrapper.text()).toContain('ChronotypePreview')
    expect(wrapper.text()).toContain('FaqSection')
    expect(wrapper.text()).toContain('CompatibilityTeaser')
    expect(wrapper.text()).toContain('FooterCta')
    expect(wrapper.text()).toContain('SiteFooter')
  })

  it('renders the root div with min-h-screen class', () => {
    const wrapper = mount(IndexPage, { global: globalStubs })
    expect(wrapper.find('.min-h-screen').exists()).toBe(true)
  })

  it('renders the root div with bg-slate-950 class', () => {
    const wrapper = mount(IndexPage, { global: globalStubs })
    expect(wrapper.find('.bg-slate-950').exists()).toBe(true)
  })
})

// ─── Quiz Page ──────────────────────────────────────────────────────────────
describe('Quiz Page', () => {
  beforeEach(() => {
    resetMocks()
  })

  const globalStubs = {
    stubs: {
      QuizProgress: {
        template: '<div class="progress-stub">Progress {{ current }}/{{ total }}</div>',
        props: ['current', 'total'],
        emits: ['back'],
      },
      QuizQuestion: {
        template: '<div class="question-stub">Question {{ questionNumber }}</div>',
        props: ['question', 'questionNumber'],
        emits: ['answer'],
      },
      Transition: { template: '<div><slot /></div>' },
    },
  }

  it('renders without errors', () => {
    const wrapper = mount(QuizPage, { global: globalStubs })
    expect(wrapper.exists()).toBe(true)
  })

  it('calls startQuiz on mount', () => {
    mount(QuizPage, { global: globalStubs })
    expect(mockStartQuiz).toHaveBeenCalledWith('quiz_page', 'solo')
  })

  it('renders the progress component with current question', () => {
    const wrapper = mount(QuizPage, { global: globalStubs })
    expect(wrapper.text()).toContain('Progress')
  })

  it('renders the question component', () => {
    const wrapper = mount(QuizPage, { global: globalStubs })
    expect(wrapper.find('.question-stub').exists()).toBe(true)
  })

  it('renders the wrapper layout with correct classes', () => {
    const wrapper = mount(QuizPage, { global: globalStubs })
    expect(wrapper.find('.min-h-screen').exists()).toBe(true)
  })

  it('renders the content container with max-w-xl', () => {
    const wrapper = mount(QuizPage, { global: globalStubs })
    expect(wrapper.find('.max-w-xl').exists()).toBe(true)
  })

  it('passes currentQuestion to the progress component', () => {
    mockCurrentQuestion.value = 3
    const wrapper = mount(QuizPage, { global: globalStubs })
    expect(wrapper.text()).toContain('Progress 3/')
  })

  it('passes currentQuestionData to the question component', () => {
    mockCurrentQuestion.value = 2
    const wrapper = mount(QuizPage, { global: globalStubs })
    expect(wrapper.find('.question-stub').text()).toContain('Question 2')
  })
})

// ─── Result Page ────────────────────────────────────────────────────────────
describe('Result Page', () => {
  beforeEach(() => {
    resetMocks()
  })

  const globalStubs = {
    stubs: {
      ChronotypeReveal: {
        template: '<div class="reveal-stub"><button class="trigger-revealed" @click="$emit(\'revealed\')">Reveal</button> {{ chronotype }}</div>',
        props: ['chronotype'],
        emits: ['revealed'],
      },
      EmailCapture: {
        template: '<div class="email-stub">EmailCapture</div>',
        props: ['chronotype'],
        emits: ['captured'],
      },
      ShareCard: {
        template: '<div class="share-stub">ShareCard</div>',
        props: ['chronotype', 'referralCode'],
      },
      CompatibilityPrompt: {
        template: '<div class="compat-stub">CompatibilityPrompt</div>',
        props: ['chronotype', 'partnerRef', 'referrerChronotype'],
      },
      FeatureSurvey: {
        template: '<div class="survey-stub">FeatureSurvey</div>',
        props: ['chronotype', 'goal', 'track'],
        emits: ['submitted'],
      },
      ReferralSection: {
        template: '<div class="referral-stub">ReferralSection</div>',
        props: ['referralCode'],
      },
      Transition: { template: '<div><slot /></div>' },
    },
  }

  it('renders nothing when result is null (redirects to quiz)', () => {
    mockResult.value = null
    const wrapper = mount(ResultPage, { global: globalStubs })
    // The template has v-if="result", so no content should render
    expect(wrapper.find('.reveal-stub').exists()).toBe(false)
  })

  it('renders chronotype reveal when result is present', () => {
    mockResult.value = { chronotype: 'lion', goal: 'Focus better' }
    const wrapper = mount(ResultPage, { global: globalStubs })
    expect(wrapper.find('.reveal-stub').exists()).toBe(true)
    expect(wrapper.text()).toContain('Reveal lion')
  })

  it('passes chronotype to the reveal component', () => {
    mockResult.value = { chronotype: 'bear', goal: 'Sleep more' }
    const wrapper = mount(ResultPage, { global: globalStubs })
    expect(wrapper.text()).toContain('Reveal bear')
  })

  it('renders email capture section when showEmailCapture is true', async () => {
    vi.useFakeTimers()
    mockResult.value = { chronotype: 'wolf', goal: 'Be creative' }
    const wrapper = mount(ResultPage, { global: globalStubs })
    // Click the reveal trigger button to emit 'revealed'
    await wrapper.find('.trigger-revealed').trigger('click')
    // Wait for the 400ms setTimeout
    vi.advanceTimersByTime(500)
    await nextTick()
    expect(wrapper.find('.email-stub').exists()).toBe(true)
    vi.useRealTimers()
  })

  it('renders the min-h-screen container when result exists', () => {
    mockResult.value = { chronotype: 'dolphin', goal: 'Reduce stress' }
    const wrapper = mount(ResultPage, { global: globalStubs })
    expect(wrapper.find('.min-h-screen').exists()).toBe(true)
  })

  it('renders the max-w-3xl content container', () => {
    mockResult.value = { chronotype: 'lion', goal: 'Focus better' }
    const wrapper = mount(ResultPage, { global: globalStubs })
    expect(wrapper.find('.max-w-3xl').exists()).toBe(true)
  })

  it('does not render post-reveal sections initially', () => {
    mockResult.value = { chronotype: 'bear', goal: 'Sleep more' }
    const wrapper = mount(ResultPage, { global: globalStubs })
    // showEmailCapture is false initially
    expect(wrapper.find('.share-stub').exists()).toBe(false)
    expect(wrapper.find('.compat-stub').exists()).toBe(false)
    expect(wrapper.find('.survey-stub').exists()).toBe(false)
    expect(wrapper.find('.referral-stub').exists()).toBe(false)
  })

  it('renders all post-reveal sections after reveal completes', async () => {
    vi.useFakeTimers()
    mockResult.value = { chronotype: 'wolf', goal: 'Be creative' }
    const wrapper = mount(ResultPage, { global: globalStubs })
    await wrapper.find('.trigger-revealed').trigger('click')
    vi.advanceTimersByTime(500)
    await nextTick()
    expect(wrapper.find('.email-stub').exists()).toBe(true)
    expect(wrapper.find('.share-stub').exists()).toBe(true)
    expect(wrapper.find('.compat-stub').exists()).toBe(true)
    expect(wrapper.find('.survey-stub').exists()).toBe(true)
    expect(wrapper.find('.referral-stub').exists()).toBe(true)
    vi.useRealTimers()
  })
})

// ─── Compatibility Page ─────────────────────────────────────────────────────
describe('Compatibility Page', () => {
  beforeEach(() => {
    resetMocks()
  })

  const globalStubs = {
    stubs: {
      CompatibilityChronotypePicker: {
        template: '<div class="picker-stub"><button class="pick-lion" @click="$emit(\'update:modelValue\', \'lion\')">Pick Lion</button><button class="pick-bear" @click="$emit(\'update:modelValue\', \'bear\')">Pick Bear</button><button class="pick-wolf" @click="$emit(\'update:modelValue\', \'wolf\')">Pick Wolf</button><button class="pick-dolphin" @click="$emit(\'update:modelValue\', \'dolphin\')">Pick Dolphin</button><span>{{ label }} picker</span></div>',
        props: ['label', 'modelValue'],
        emits: ['update:modelValue'],
      },
      CompatibilityCompatibilityCard: {
        template: '<div class="card-stub">Card {{ selfType }} + {{ partnerType }}</div>',
        props: ['selfType', 'partnerType'],
      },
      CompatibilityCompatibilityShare: {
        template: '<div class="share-stub">Share</div>',
        props: ['selfType', 'partnerType', 'referralCode'],
        emits: ['shared', 'invite-sent', 'partner-mode-interest'],
      },
      LandingSiteFooter: { template: '<div>SiteFooter</div>' },
      NuxtLink: { template: '<a><slot /></a>' },
      Transition: { template: '<div><slot /></div>' },
    },
  }

  it('renders without errors', () => {
    const wrapper = mount(CompatibilityPage, { global: globalStubs })
    expect(wrapper.exists()).toBe(true)
  })

  it('renders the hero section with title', () => {
    const wrapper = mount(CompatibilityPage, { global: globalStubs })
    expect(wrapper.text()).toContain('How do your sleep')
    expect(wrapper.text()).toContain('align?')
  })

  it('renders the Sleep Compatibility badge', () => {
    const wrapper = mount(CompatibilityPage, { global: globalStubs })
    expect(wrapper.text()).toContain('Sleep Compatibility')
  })

  it('renders the hero description text', () => {
    const wrapper = mount(CompatibilityPage, { global: globalStubs })
    expect(wrapper.text()).toContain('Compare chronotypes with your partner')
  })

  it('renders Step 1 heading', () => {
    const wrapper = mount(CompatibilityPage, { global: globalStubs })
    expect(wrapper.text()).toContain("What's your chronotype?")
  })

  it('renders the "Take the 60-sec quiz" option initially', () => {
    const wrapper = mount(CompatibilityPage, { global: globalStubs })
    expect(wrapper.text()).toContain('Take the 60-sec quiz')
  })

  it('renders the "I already know mine" option initially', () => {
    const wrapper = mount(CompatibilityPage, { global: globalStubs })
    expect(wrapper.text()).toContain('I already know mine')
  })

  it('shows self chronotype picker after clicking "I already know mine"', async () => {
    const wrapper = mount(CompatibilityPage, { global: globalStubs })
    const knowButton = wrapper.findAll('button').find((b) => b.text().includes('I already know mine'))
    await knowButton!.trigger('click')
    await nextTick()
    expect(wrapper.text()).toContain('Your chronotype picker')
  })

  it('does not show Step 2 initially', () => {
    const wrapper = mount(CompatibilityPage, { global: globalStubs })
    expect(wrapper.text()).not.toContain("What's their chronotype?")
  })

  it('shows Step 2 after selecting self type', async () => {
    const wrapper = mount(CompatibilityPage, { global: globalStubs })
    const knowButton = wrapper.findAll('button').find((b) => b.text().includes('I already know mine'))
    await knowButton!.trigger('click')
    await nextTick()
    // Click the lion pick button inside the self picker stub
    await wrapper.find('.pick-lion').trigger('click')
    await nextTick()
    expect(wrapper.text()).toContain("What's their chronotype?")
  })

  it('does not show result section when only self type is selected', async () => {
    const wrapper = mount(CompatibilityPage, { global: globalStubs })
    const knowButton = wrapper.findAll('button').find((b) => b.text().includes('I already know mine'))
    await knowButton!.trigger('click')
    await nextTick()
    await wrapper.find('.pick-lion').trigger('click')
    await nextTick()
    expect(wrapper.find('.card-stub').exists()).toBe(false)
  })

  it('shows result section when both types are selected', async () => {
    const wrapper = mount(CompatibilityPage, { global: globalStubs })
    // Select self type
    const selfKnowButton = wrapper.findAll('button').find((b) => b.text().includes('I already know mine'))
    await selfKnowButton!.trigger('click')
    await nextTick()
    await wrapper.find('.pick-lion').trigger('click')
    await nextTick()

    // Select partner type
    const partnerKnowButton = wrapper.findAll('button').find((b) => b.text().includes('I know theirs too'))
    await partnerKnowButton!.trigger('click')
    await nextTick()
    // There are now two picker stubs; the partner picker is the second one
    const partnerPicker = wrapper.findAll('.picker-stub')[1]
    await partnerPicker.find('.pick-wolf').trigger('click')
    await nextTick()

    expect(wrapper.find('.card-stub').exists()).toBe(true)
    expect(wrapper.text()).toContain('Card lion + wolf')
  })

  it('shows share section when both types are selected', async () => {
    const wrapper = mount(CompatibilityPage, { global: globalStubs })
    const selfKnowButton = wrapper.findAll('button').find((b) => b.text().includes('I already know mine'))
    await selfKnowButton!.trigger('click')
    await nextTick()
    await wrapper.find('.pick-bear').trigger('click')
    await nextTick()

    const partnerKnowButton = wrapper.findAll('button').find((b) => b.text().includes('I know theirs too'))
    await partnerKnowButton!.trigger('click')
    await nextTick()
    const partnerPicker = wrapper.findAll('.picker-stub')[1]
    await partnerPicker.find('.pick-dolphin').trigger('click')
    await nextTick()

    expect(wrapper.find('.share-stub').exists()).toBe(true)
  })

  it('renders "Your Result" divider when result is shown', async () => {
    const wrapper = mount(CompatibilityPage, { global: globalStubs })
    const selfKnowButton = wrapper.findAll('button').find((b) => b.text().includes('I already know mine'))
    await selfKnowButton!.trigger('click')
    await nextTick()
    await wrapper.find('.pick-lion').trigger('click')
    await nextTick()

    const partnerKnowButton = wrapper.findAll('button').find((b) => b.text().includes('I know theirs too'))
    await partnerKnowButton!.trigger('click')
    await nextTick()
    const partnerPicker = wrapper.findAll('.picker-stub')[1]
    await partnerPicker.find('.pick-wolf').trigger('click')
    await nextTick()

    expect(wrapper.text()).toContain('Your Result')
  })

  it('renders the "Don\'t know their chronotype yet?" section when result is not shown', () => {
    const wrapper = mount(CompatibilityPage, { global: globalStubs })
    expect(wrapper.text()).toContain("Don't know their chronotype yet?")
  })

  it('hides the "Don\'t know their chronotype yet?" section when result is shown', async () => {
    const wrapper = mount(CompatibilityPage, { global: globalStubs })
    const selfKnowButton = wrapper.findAll('button').find((b) => b.text().includes('I already know mine'))
    await selfKnowButton!.trigger('click')
    await nextTick()
    await wrapper.find('.pick-lion').trigger('click')
    await nextTick()

    const partnerKnowButton = wrapper.findAll('button').find((b) => b.text().includes('I know theirs too'))
    await partnerKnowButton!.trigger('click')
    await nextTick()
    const partnerPicker = wrapper.findAll('.picker-stub')[1]
    await partnerPicker.find('.pick-bear').trigger('click')
    await nextTick()

    expect(wrapper.text()).not.toContain("Don't know their chronotype yet?")
  })

  it('renders the footer', () => {
    const wrapper = mount(CompatibilityPage, { global: globalStubs })
    expect(wrapper.text()).toContain('SiteFooter')
  })

  it('renders the bg-slate-950 background', () => {
    const wrapper = mount(CompatibilityPage, { global: globalStubs })
    expect(wrapper.find('.bg-slate-950').exists()).toBe(true)
  })

  it('renders step number 1 indicator', () => {
    const wrapper = mount(CompatibilityPage, { global: globalStubs })
    const stepIndicator = wrapper.findAll('.rounded-full').find((el) => el.text() === '1')
    expect(stepIndicator).toBeDefined()
  })

  it('renders "They can take the quiz too" option in Step 2', async () => {
    const wrapper = mount(CompatibilityPage, { global: globalStubs })
    const selfKnowButton = wrapper.findAll('button').find((b) => b.text().includes('I already know mine'))
    await selfKnowButton!.trigger('click')
    await nextTick()
    await wrapper.find('.pick-lion').trigger('click')
    await nextTick()

    expect(wrapper.text()).toContain('They can take the quiz too')
  })

  it('renders "Take the quiz yourself" link in the bottom section', () => {
    const wrapper = mount(CompatibilityPage, { global: globalStubs })
    expect(wrapper.text()).toContain('Take the quiz yourself')
  })

  it('renders "Copy quiz link for them" button in the bottom section', () => {
    const wrapper = mount(CompatibilityPage, { global: globalStubs })
    expect(wrapper.text()).toContain('Copy quiz link for them')
  })

  it('renders step number 2 indicator when Step 2 is visible', async () => {
    const wrapper = mount(CompatibilityPage, { global: globalStubs })
    const selfKnowButton = wrapper.findAll('button').find((b) => b.text().includes('I already know mine'))
    await selfKnowButton!.trigger('click')
    await nextTick()
    await wrapper.find('.pick-lion').trigger('click')
    await nextTick()

    const stepIndicator = wrapper.findAll('.rounded-full').find((el) => el.text() === '2')
    expect(stepIndicator).toBeDefined()
  })

  it('renders the "Send them a link" description in Step 2', async () => {
    const wrapper = mount(CompatibilityPage, { global: globalStubs })
    const selfKnowButton = wrapper.findAll('button').find((b) => b.text().includes('I already know mine'))
    await selfKnowButton!.trigger('click')
    await nextTick()
    await wrapper.find('.pick-lion').trigger('click')
    await nextTick()

    expect(wrapper.text()).toContain('Send them a link to find their type')
  })
})
