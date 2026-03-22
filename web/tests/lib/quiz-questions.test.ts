import { describe, it, expect } from 'vitest'
import { quizQuestions, calculateChronotype } from '../../app/lib/quiz-questions'

describe('quizQuestions', () => {
  it('has 8 questions', () => {
    expect(quizQuestions).toHaveLength(8)
  })

  it('each question has 4 answers', () => {
    for (const q of quizQuestions) {
      expect(q.answers).toHaveLength(4)
    }
  })

  it('question ids are sequential 1-8', () => {
    const ids = quizQuestions.map(q => q.id)
    expect(ids).toEqual([1, 2, 3, 4, 5, 6, 7, 8])
  })

  it('each question has required fields', () => {
    for (const q of quizQuestions) {
      expect(q.id).toBeGreaterThan(0)
      expect(q.question).toBeTruthy()
      expect(q.context).toBeTruthy()
      expect(q.answers).toBeDefined()
    }
  })

  it('each answer has point values for all 4 types', () => {
    for (const q of quizQuestions) {
      for (const a of q.answers) {
        expect(a.text).toBeTruthy()
        expect(a.points.lion).toBeDefined()
        expect(a.points.bear).toBeDefined()
        expect(a.points.wolf).toBeDefined()
        expect(a.points.dolphin).toBeDefined()
      }
    }
  })

  it('point values are non-negative', () => {
    for (const q of quizQuestions) {
      for (const a of q.answers) {
        expect(a.points.lion).toBeGreaterThanOrEqual(0)
        expect(a.points.bear).toBeGreaterThanOrEqual(0)
        expect(a.points.wolf).toBeGreaterThanOrEqual(0)
        expect(a.points.dolphin).toBeGreaterThanOrEqual(0)
      }
    }
  })
})

describe('calculateChronotype', () => {
  it('returns lion for all first answers', () => {
    const result = calculateChronotype([0, 0, 0, 0, 0, 0, 0, 0])
    expect(result.chronotype).toBe('lion')
  })

  it('returns bear for all second answers', () => {
    const result = calculateChronotype([1, 1, 1, 1, 1, 1, 1, 1])
    expect(result.chronotype).toBe('bear')
  })

  it('returns wolf for all third answers', () => {
    const result = calculateChronotype([2, 2, 2, 2, 2, 2, 2, 2])
    expect(result.chronotype).toBe('wolf')
  })

  it('returns dolphin for all fourth answers', () => {
    const result = calculateChronotype([3, 3, 3, 3, 3, 3, 3, 3])
    expect(result.chronotype).toBe('dolphin')
  })

  it('returns correct scores structure', () => {
    const result = calculateChronotype([0, 0, 0, 0, 0, 0, 0, 0])
    expect(result.scores).toBeDefined()
    expect(result.scores.lion).toBeGreaterThan(0)
    expect(typeof result.scores.bear).toBe('number')
    expect(typeof result.scores.wolf).toBe('number')
    expect(typeof result.scores.dolphin).toBe('number')
  })

  it('returns goal from last question', () => {
    const result = calculateChronotype([0, 0, 0, 0, 0, 0, 0, 0])
    expect(result.goal).toBe('Protect my morning routine and wind down earlier')
  })

  it('returns wolf goal for third answers', () => {
    const result = calculateChronotype([2, 2, 2, 2, 2, 2, 2, 2])
    expect(result.goal).toBe('Actually work with my night-owl schedule, not fight it')
  })

  it('returns answers array', () => {
    const answers = [0, 1, 2, 3, 0, 1, 2, 3]
    const result = calculateChronotype(answers)
    expect(result.answers).toEqual(answers)
  })

  it('handles empty answers', () => {
    const result = calculateChronotype([])
    expect(result.chronotype).toBeDefined()
    expect(Object.values(result.scores).every(s => s === 0)).toBe(true)
  })

  it('handles partial answers', () => {
    const result = calculateChronotype([0, 0, 0])
    expect(result.chronotype).toBeDefined()
    // Goal uses last answer index against last question — with index 0 it resolves to first option
    expect(result.goal).toBeTruthy()
  })

  it('wolf gets 24 points for all wolf answers', () => {
    const result = calculateChronotype([2, 2, 2, 2, 2, 2, 2, 2])
    expect(result.scores.wolf).toBe(24)
  })

  it('lion score is highest for all first answers', () => {
    const result = calculateChronotype([0, 0, 0, 0, 0, 0, 0, 0])
    expect(result.scores.lion).toBeGreaterThan(result.scores.bear)
    expect(result.scores.lion).toBeGreaterThan(result.scores.wolf)
    expect(result.scores.lion).toBeGreaterThan(result.scores.dolphin)
  })

  it('mixed answers produce valid result', () => {
    const result = calculateChronotype([0, 1, 2, 3, 3, 2, 1, 0])
    expect(['lion', 'bear', 'wolf', 'dolphin']).toContain(result.chronotype)
  })
})
