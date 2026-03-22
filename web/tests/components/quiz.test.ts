import { describe, it, expect, vi } from 'vitest'
import { mount } from '@vue/test-utils'
import { nextTick } from 'vue'
import QuizProgress from '../../app/components/quiz/QuizProgress.vue'
import QuizQuestion from '../../app/components/quiz/QuizQuestion.vue'
import { quizQuestions } from '../../app/lib/quiz-questions'

// ─── QuizProgress ─────────────────────────────────────────────────────────────
describe('QuizProgress', () => {
  it('renders the question counter text', () => {
    const wrapper = mount(QuizProgress, {
      props: { current: 0, total: 8 },
    })
    expect(wrapper.text()).toContain('Question 1 of 8')
  })

  it('updates question counter for different current values', () => {
    const wrapper = mount(QuizProgress, {
      props: { current: 4, total: 8 },
    })
    expect(wrapper.text()).toContain('Question 5 of 8')
  })

  it('renders the progress bar', () => {
    const wrapper = mount(QuizProgress, {
      props: { current: 0, total: 8 },
    })
    const progressBar = wrapper.find('.bg-primary')
    expect(progressBar.exists()).toBe(true)
  })

  it('sets correct progress bar width', () => {
    const wrapper = mount(QuizProgress, {
      props: { current: 3, total: 8 },
    })
    const bar = wrapper.find('.bg-primary')
    // (3+1)/8 * 100 = 50%
    expect(bar.attributes('style')).toContain('width: 50%')
  })

  it('hides the back button on first question', () => {
    const wrapper = mount(QuizProgress, {
      props: { current: 0, total: 8 },
    })
    const buttons = wrapper.findAll('button')
    expect(buttons.length).toBe(0)
  })

  it('shows the back button when not on first question', () => {
    const wrapper = mount(QuizProgress, {
      props: { current: 1, total: 8 },
    })
    const button = wrapper.find('button')
    expect(button.exists()).toBe(true)
    expect(button.text()).toContain('Back')
  })

  it('emits back when back button is clicked', async () => {
    const wrapper = mount(QuizProgress, {
      props: { current: 2, total: 8 },
    })
    await wrapper.find('button').trigger('click')
    expect(wrapper.emitted('back')).toHaveLength(1)
  })

  it('displays progress at 100% for last question', () => {
    const wrapper = mount(QuizProgress, {
      props: { current: 7, total: 8 },
    })
    const bar = wrapper.find('.bg-primary')
    expect(bar.attributes('style')).toContain('width: 100%')
  })
})

// ─── QuizQuestion ─────────────────────────────────────────────────────────────
describe('QuizQuestion', () => {
  const sampleQuestion = quizQuestions[0]

  it('renders the question text', () => {
    const wrapper = mount(QuizQuestion, {
      props: { question: sampleQuestion, questionNumber: 0 },
    })
    expect(wrapper.text()).toContain(sampleQuestion.question)
  })

  it('renders the context text', () => {
    const wrapper = mount(QuizQuestion, {
      props: { question: sampleQuestion, questionNumber: 0 },
    })
    expect(wrapper.text()).toContain(sampleQuestion.context)
  })

  it('renders 4 answer options', () => {
    const wrapper = mount(QuizQuestion, {
      props: { question: sampleQuestion, questionNumber: 0 },
    })
    const buttons = wrapper.findAll('button')
    expect(buttons.length).toBe(4)
  })

  it('renders answer text for all options', () => {
    const wrapper = mount(QuizQuestion, {
      props: { question: sampleQuestion, questionNumber: 0 },
    })
    sampleQuestion.answers.forEach((answer) => {
      expect(wrapper.text()).toContain(answer.text)
    })
  })

  it('renders option letters A, B, C, D', () => {
    const wrapper = mount(QuizQuestion, {
      props: { question: sampleQuestion, questionNumber: 0 },
    })
    const text = wrapper.text()
    expect(text).toContain('A')
    expect(text).toContain('B')
    expect(text).toContain('C')
    expect(text).toContain('D')
  })

  it('emits answer with correct index after click with delay', async () => {
    vi.useFakeTimers()
    const wrapper = mount(QuizQuestion, {
      props: { question: sampleQuestion, questionNumber: 0 },
    })
    const buttons = wrapper.findAll('button')
    await buttons[2].trigger('click')
    // Answer is emitted after 300ms timeout
    vi.advanceTimersByTime(300)
    expect(wrapper.emitted('answer')).toBeTruthy()
    expect(wrapper.emitted('answer')![0]).toEqual([2])
    vi.useRealTimers()
  })

  it('disables buttons after an answer is selected', async () => {
    vi.useFakeTimers()
    const wrapper = mount(QuizQuestion, {
      props: { question: sampleQuestion, questionNumber: 0 },
    })
    const buttons = wrapper.findAll('button')
    await buttons[0].trigger('click')
    await nextTick()
    // All buttons should be disabled after selection
    buttons.forEach((btn) => {
      expect(btn.attributes('disabled')).toBeDefined()
    })
    vi.useRealTimers()
  })

  it('prevents multiple answers from being selected', async () => {
    vi.useFakeTimers()
    const wrapper = mount(QuizQuestion, {
      props: { question: sampleQuestion, questionNumber: 0 },
    })
    const buttons = wrapper.findAll('button')
    await buttons[0].trigger('click')
    await buttons[1].trigger('click')
    vi.advanceTimersByTime(300)
    // Only first answer should be emitted
    expect(wrapper.emitted('answer')!.length).toBe(1)
    expect(wrapper.emitted('answer')![0]).toEqual([0])
    vi.useRealTimers()
  })

  it('renders different question content when question prop changes', async () => {
    const secondQuestion = quizQuestions[1]
    const wrapper = mount(QuizQuestion, {
      props: { question: sampleQuestion, questionNumber: 0 },
    })
    expect(wrapper.text()).toContain(sampleQuestion.question)

    await wrapper.setProps({ question: secondQuestion, questionNumber: 1 })
    await nextTick()
    expect(wrapper.text()).toContain(secondQuestion.question)
  })

  it('applies selected styling to the clicked answer', async () => {
    const wrapper = mount(QuizQuestion, {
      props: { question: sampleQuestion, questionNumber: 0 },
    })
    const buttons = wrapper.findAll('button')
    await buttons[1].trigger('click')
    await nextTick()
    expect(buttons[1].classes()).toContain('border-primary')
  })
})
