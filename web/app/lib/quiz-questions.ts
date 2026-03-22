import type { ChronotypeId } from './chronotypes'

export interface QuizAnswer {
  text: string
  points: Record<ChronotypeId, number>
}

export interface QuizQuestion {
  id: number
  question: string
  context: string
  answers: QuizAnswer[]
}

export const quizQuestions: QuizQuestion[] = [
  {
    id: 1,
    question: 'What time do you naturally wake up on days with no alarm?',
    context: 'Think about weekends or vacations — when your body decides.',
    answers: [
      { text: 'Before 6:30 AM', points: { lion: 3, bear: 1, wolf: 0, dolphin: 1 } },
      { text: '6:30 – 8:00 AM', points: { lion: 1, bear: 3, wolf: 0, dolphin: 1 } },
      { text: '8:00 – 10:00 AM', points: { lion: 0, bear: 1, wolf: 3, dolphin: 0 } },
      { text: 'It varies wildly', points: { lion: 0, bear: 0, wolf: 1, dolphin: 3 } },
    ],
  },
  {
    id: 2,
    question: 'When do you feel your sharpest during the day?',
    context: 'When is your brain on fire — solving hard problems, writing, creating?',
    answers: [
      { text: 'First thing in the morning', points: { lion: 3, bear: 1, wolf: 0, dolphin: 0 } },
      { text: 'Late morning to early afternoon', points: { lion: 1, bear: 3, wolf: 0, dolphin: 1 } },
      { text: 'Late afternoon to evening', points: { lion: 0, bear: 1, wolf: 3, dolphin: 1 } },
      { text: 'It comes in unpredictable bursts', points: { lion: 0, bear: 0, wolf: 1, dolphin: 3 } },
    ],
  },
  {
    id: 3,
    question: 'How would you describe your sleep quality?',
    context: 'On a typical night, not your best or worst.',
    answers: [
      { text: 'I sleep deeply and wake refreshed', points: { lion: 2, bear: 3, wolf: 1, dolphin: 0 } },
      { text: 'Pretty solid — occasional restlessness', points: { lion: 2, bear: 2, wolf: 1, dolphin: 1 } },
      { text: 'I struggle to fall asleep but sleep well eventually', points: { lion: 0, bear: 0, wolf: 3, dolphin: 1 } },
      { text: 'Light and fitful — I wake up often', points: { lion: 0, bear: 0, wolf: 0, dolphin: 3 } },
    ],
  },
  {
    id: 4,
    question: 'When do you prefer to exercise?',
    context: 'If you had total control over your schedule.',
    answers: [
      { text: 'Early morning — before the day starts', points: { lion: 3, bear: 1, wolf: 0, dolphin: 1 } },
      { text: 'Mid-day or lunch break', points: { lion: 1, bear: 3, wolf: 0, dolphin: 1 } },
      { text: 'Evening — after work or dinner', points: { lion: 0, bear: 1, wolf: 3, dolphin: 0 } },
      { text: 'Whenever I actually have the energy', points: { lion: 0, bear: 0, wolf: 1, dolphin: 3 } },
    ],
  },
  {
    id: 5,
    question: 'If you could eat dinner at any time, when would it be?',
    context: 'No social obligations — just your body\'s preference.',
    answers: [
      { text: '5:30 – 6:30 PM', points: { lion: 3, bear: 1, wolf: 0, dolphin: 1 } },
      { text: '6:30 – 7:30 PM', points: { lion: 1, bear: 3, wolf: 1, dolphin: 1 } },
      { text: '8:00 – 9:30 PM', points: { lion: 0, bear: 1, wolf: 3, dolphin: 0 } },
      { text: 'My hunger doesn\'t follow a pattern', points: { lion: 0, bear: 0, wolf: 1, dolphin: 3 } },
    ],
  },
  {
    id: 6,
    question: 'How do you feel about mornings?',
    context: 'Be honest — not aspirational.',
    answers: [
      { text: 'I love them — best part of my day', points: { lion: 3, bear: 1, wolf: 0, dolphin: 0 } },
      { text: 'Fine once I\'m up and moving', points: { lion: 1, bear: 3, wolf: 0, dolphin: 1 } },
      { text: 'They\'re painful — I\'m a zombie until 10 AM', points: { lion: 0, bear: 0, wolf: 3, dolphin: 1 } },
      { text: 'Depends on the night — sometimes great, sometimes awful', points: { lion: 0, bear: 1, wolf: 1, dolphin: 3 } },
    ],
  },
  {
    id: 7,
    question: 'How quickly do you fall asleep at night?',
    context: 'When you actually get into bed intending to sleep.',
    answers: [
      { text: 'Within 5 minutes — I\'m out', points: { lion: 3, bear: 2, wolf: 0, dolphin: 0 } },
      { text: '10–20 minutes — fairly normal', points: { lion: 1, bear: 3, wolf: 1, dolphin: 0 } },
      { text: '20–45 minutes — my mind takes a while to wind down', points: { lion: 0, bear: 0, wolf: 3, dolphin: 1 } },
      { text: '45+ minutes — my brain won\'t shut off', points: { lion: 0, bear: 0, wolf: 1, dolphin: 3 } },
    ],
  },
  {
    id: 8,
    question: 'What\'s your biggest sleep-related goal?',
    context: 'The one thing that would change your daily experience the most.',
    answers: [
      { text: 'Protect my morning routine and wind down earlier', points: { lion: 3, bear: 1, wolf: 0, dolphin: 0 } },
      { text: 'Build more consistency — same time every day', points: { lion: 1, bear: 3, wolf: 1, dolphin: 1 } },
      { text: 'Actually work with my night-owl schedule, not fight it', points: { lion: 0, bear: 0, wolf: 3, dolphin: 0 } },
      { text: 'Figure out why my sleep is so unpredictable', points: { lion: 0, bear: 0, wolf: 0, dolphin: 3 } },
    ],
  },
]

export interface QuizResult {
  chronotype: ChronotypeId
  scores: Record<ChronotypeId, number>
  answers: number[]
  goal: string
}

export function calculateChronotype(answers: number[]): QuizResult {
  const scores: Record<ChronotypeId, number> = { lion: 0, bear: 0, wolf: 0, dolphin: 0 }

  answers.forEach((answerIndex, questionIndex) => {
    const question = quizQuestions[questionIndex]
    if (question && question.answers[answerIndex]) {
      const points = question.answers[answerIndex].points
      scores.lion += points.lion
      scores.bear += points.bear
      scores.wolf += points.wolf
      scores.dolphin += points.dolphin
    }
  })

  const chronotype = (Object.entries(scores) as [ChronotypeId, number][])
    .sort(([, a], [, b]) => b - a)[0][0]

  const lastQuestion = quizQuestions[quizQuestions.length - 1]
  const goalAnswer = answers[answers.length - 1]
  const goal = lastQuestion?.answers[goalAnswer]?.text ?? ''

  return { chronotype, scores, answers, goal }
}
