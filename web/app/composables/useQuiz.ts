import { ref, computed } from 'vue'
import { quizQuestions, calculateChronotype, type QuizResult } from '@/lib/quiz-questions'
import { trackEvent } from '@/lib/analytics'

const currentQuestion = ref(0)
const answers = ref<number[]>([])
const isComplete = ref(false)
const result = ref<QuizResult | null>(null)
const startTime = ref<number>(0)
const entryPoint = ref<'solo' | 'compatibility'>('solo')
const partnerRef = ref<string | null>(null)
const referrerChronotype = ref<string | null>(null)

export function useQuiz() {
  const totalQuestions = computed(() => quizQuestions.length)
  const progress = computed(() => (currentQuestion.value / totalQuestions.value) * 100)
  const currentQuestionData = computed(() => quizQuestions[currentQuestion.value] ?? null)
  const isLastQuestion = computed(() => currentQuestion.value === totalQuestions.value - 1)

  function startQuiz(source: string = 'hero', entry: 'solo' | 'compatibility' = 'solo') {
    currentQuestion.value = 0
    answers.value = []
    isComplete.value = false
    result.value = null
    startTime.value = Date.now()
    entryPoint.value = entry

    trackEvent({ name: 'quiz_start', data: { source } })
  }

  function answerQuestion(answerIndex: number) {
    const question = quizQuestions[currentQuestion.value]
    if (!question) return

    answers.value = [...answers.value.slice(0, currentQuestion.value), answerIndex]

    trackEvent({
      name: 'quiz_question_answered',
      data: {
        question_number: currentQuestion.value + 1,
        answer: question.answers[answerIndex]?.text ?? '',
      },
    })

    if (currentQuestion.value < totalQuestions.value - 1) {
      currentQuestion.value++
    } else {
      completeQuiz()
    }
  }

  function goBack() {
    if (currentQuestion.value > 0) {
      currentQuestion.value--
    }
  }

  function completeQuiz() {
    const elapsed = Math.round((Date.now() - startTime.value) / 1000)
    const quizResult = calculateChronotype(answers.value)
    result.value = quizResult
    isComplete.value = true

    trackEvent({
      name: 'quiz_complete',
      data: {
        chronotype: quizResult.chronotype,
        time_spent_seconds: elapsed,
        entry_point: entryPoint.value,
      },
    })
  }

  function setPartnerRef(ref: string | null, type: string | null) {
    partnerRef.value = ref
    referrerChronotype.value = type
  }

  function resetQuiz() {
    currentQuestion.value = 0
    answers.value = []
    isComplete.value = false
    result.value = null
    startTime.value = 0
  }

  return {
    currentQuestion,
    answers,
    isComplete,
    result,
    entryPoint,
    partnerRef,
    referrerChronotype,
    totalQuestions,
    progress,
    currentQuestionData,
    isLastQuestion,
    startQuiz,
    answerQuestion,
    goBack,
    completeQuiz,
    setPartnerRef,
    resetQuiz,
  }
}
