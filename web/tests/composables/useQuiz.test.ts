import { describe, it, expect, beforeEach, vi } from 'vitest'
import { useQuiz } from '../../app/composables/useQuiz'
import { clearEventLog, getEventLog } from '../../app/lib/analytics'

describe('useQuiz', () => {
  beforeEach(() => {
    const { resetQuiz } = useQuiz()
    resetQuiz()
    clearEventLog()
  })

  it('initializes with correct defaults', () => {
    const { currentQuestion, isComplete, result, totalQuestions } = useQuiz()
    expect(currentQuestion.value).toBe(0)
    expect(isComplete.value).toBe(false)
    expect(result.value).toBeNull()
    expect(totalQuestions.value).toBe(8)
  })

  it('starts quiz with analytics event', () => {
    const { startQuiz, currentQuestion } = useQuiz()
    startQuiz('hero')
    expect(currentQuestion.value).toBe(0)
    const events = getEventLog()
    expect(events.some(e => e.name === 'quiz_start')).toBe(true)
  })

  it('advances question on answer', () => {
    const { startQuiz, answerQuestion, currentQuestion } = useQuiz()
    startQuiz('hero')
    answerQuestion(0)
    expect(currentQuestion.value).toBe(1)
  })

  it('tracks answer events', () => {
    const { startQuiz, answerQuestion } = useQuiz()
    startQuiz('hero')
    answerQuestion(0)
    const events = getEventLog()
    expect(events.some(e => e.name === 'quiz_question_answered')).toBe(true)
  })

  it('completes after 8 answers', () => {
    const { startQuiz, answerQuestion, isComplete, result } = useQuiz()
    startQuiz('hero')
    for (let i = 0; i < 8; i++) {
      answerQuestion(0)
    }
    expect(isComplete.value).toBe(true)
    expect(result.value).not.toBeNull()
    expect(result.value?.chronotype).toBe('lion')
  })

  it('calculates wolf correctly', () => {
    const { startQuiz, answerQuestion, result } = useQuiz()
    startQuiz('hero')
    for (let i = 0; i < 8; i++) {
      answerQuestion(2)
    }
    expect(result.value?.chronotype).toBe('wolf')
  })

  it('tracks quiz_complete event', () => {
    const { startQuiz, answerQuestion } = useQuiz()
    startQuiz('hero')
    for (let i = 0; i < 8; i++) {
      answerQuestion(0)
    }
    const events = getEventLog()
    expect(events.some(e => e.name === 'quiz_complete')).toBe(true)
  })

  it('goBack decrements question', () => {
    const { startQuiz, answerQuestion, goBack, currentQuestion } = useQuiz()
    startQuiz('hero')
    answerQuestion(0)
    answerQuestion(1)
    expect(currentQuestion.value).toBe(2)
    goBack()
    expect(currentQuestion.value).toBe(1)
  })

  it('goBack does nothing at question 0', () => {
    const { startQuiz, goBack, currentQuestion } = useQuiz()
    startQuiz('hero')
    goBack()
    expect(currentQuestion.value).toBe(0)
  })

  it('computes progress correctly', () => {
    const { startQuiz, answerQuestion, progress } = useQuiz()
    startQuiz('hero')
    expect(progress.value).toBe(0)
    answerQuestion(0)
    expect(progress.value).toBe(12.5)
    answerQuestion(0)
    expect(progress.value).toBe(25)
  })

  it('computes currentQuestionData', () => {
    const { startQuiz, currentQuestionData } = useQuiz()
    startQuiz('hero')
    expect(currentQuestionData.value).not.toBeNull()
    expect(currentQuestionData.value?.id).toBe(1)
    expect(currentQuestionData.value?.answers).toHaveLength(4)
  })

  it('computes isLastQuestion', () => {
    const { startQuiz, answerQuestion, isLastQuestion } = useQuiz()
    startQuiz('hero')
    expect(isLastQuestion.value).toBe(false)
    for (let i = 0; i < 7; i++) {
      answerQuestion(0)
    }
    expect(isLastQuestion.value).toBe(true)
  })

  it('stores partner ref', () => {
    const { setPartnerRef, partnerRef, referrerChronotype } = useQuiz()
    setPartnerRef('ref_abc123', 'wolf')
    expect(partnerRef.value).toBe('ref_abc123')
    expect(referrerChronotype.value).toBe('wolf')
  })

  it('resetQuiz clears state', () => {
    const { startQuiz, answerQuestion, resetQuiz, currentQuestion, isComplete } = useQuiz()
    startQuiz('hero')
    answerQuestion(0)
    answerQuestion(0)
    resetQuiz()
    expect(currentQuestion.value).toBe(0)
    expect(isComplete.value).toBe(false)
  })

  it('handles entry point', () => {
    const { startQuiz, entryPoint } = useQuiz()
    startQuiz('hero', 'compatibility')
    expect(entryPoint.value).toBe('compatibility')
  })

  it('stores answers correctly', () => {
    const { startQuiz, answerQuestion, answers } = useQuiz()
    startQuiz('hero')
    answerQuestion(0)
    answerQuestion(2)
    answerQuestion(1)
    expect(answers.value).toEqual([0, 2, 1])
  })
})
