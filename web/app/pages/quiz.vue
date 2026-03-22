<script setup lang="ts">
import { useQuiz } from '@/composables/useQuiz'

const route = useRoute()

const {
  currentQuestion,
  totalQuestions,
  currentQuestionData,
  isComplete,
  startQuiz,
  answerQuestion,
  goBack,
  setPartnerRef,
} = useQuiz()

onMounted(() => {
  const partnerRef = route.query.partner_ref as string | undefined
  const referrerType = route.query.referrer_type as string | undefined

  if (partnerRef) {
    setPartnerRef(partnerRef, referrerType ?? null)
  }

  const entry = partnerRef ? 'compatibility' : 'solo'
  startQuiz('quiz_page', entry)
})

watch(isComplete, (complete) => {
  if (complete) {
    navigateTo('/result')
  }
})
</script>

<template>
  <div class="flex min-h-screen flex-col items-center justify-start px-4 py-8 sm:py-12">
    <div class="w-full max-w-xl space-y-10">
      <!-- Progress -->
      <QuizProgress
        :current="currentQuestion"
        :total="totalQuestions"
        @back="goBack"
      />

      <!-- Question -->
      <Transition name="quiz-slide" mode="out-in">
        <QuizQuestion
          v-if="currentQuestionData"
          :key="currentQuestion"
          :question="currentQuestionData"
          :question-number="currentQuestion"
          @answer="answerQuestion"
        />
      </Transition>
    </div>
  </div>
</template>

<style scoped>
.quiz-slide-enter-active {
  transition: all 0.35s ease-out;
}
.quiz-slide-leave-active {
  transition: all 0.2s ease-in;
}
.quiz-slide-enter-from {
  opacity: 0;
  transform: translateX(24px);
}
.quiz-slide-leave-to {
  opacity: 0;
  transform: translateX(-24px);
}
</style>
