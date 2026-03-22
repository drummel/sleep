<script setup lang="ts">
import { useQuiz } from '@/composables/useQuiz'
import { useEmail } from '@/composables/useEmail'

const {
  result,
  partnerRef,
  referrerChronotype,
  entryPoint,
} = useQuiz()

const { referralCode } = useEmail()

// Redirect to quiz if no result
onMounted(() => {
  if (!result.value) {
    navigateTo('/quiz')
  }
})

const chronotype = computed(() => result.value?.chronotype ?? '')
const goal = computed(() => result.value?.goal ?? '')
const track = computed(() => entryPoint.value ?? 'solo')

const showEmailCapture = ref(false)
const emailCaptured = ref(false)

function onRevealed() {
  // Gate: show email capture after reveal animation completes
  setTimeout(() => {
    showEmailCapture.value = true
  }, 400)
}

function onEmailCaptured() {
  emailCaptured.value = true
}
</script>

<template>
  <div v-if="result" class="min-h-screen">
    <div class="max-w-3xl mx-auto">
      <!-- 1. Chronotype Reveal -->
      <ChronotypeReveal
        :chronotype="chronotype"
        @revealed="onRevealed"
      />

      <!-- 2. Email Capture (gated — appears after reveal) -->
      <Transition name="fade-up">
        <EmailCapture
          v-if="showEmailCapture"
          :chronotype="chronotype"
          @captured="onEmailCaptured"
        />
      </Transition>

      <!-- 3. Share Card -->
      <Transition name="fade-up">
        <ShareCard
          v-if="showEmailCapture"
          :chronotype="chronotype"
          :referral-code="referralCode"
        />
      </Transition>

      <!-- 4. Compatibility Prompt -->
      <Transition name="fade-up">
        <CompatibilityPrompt
          v-if="showEmailCapture"
          :chronotype="chronotype"
          :partner-ref="partnerRef"
          :referrer-chronotype="referrerChronotype"
        />
      </Transition>

      <!-- 5. Feature Survey -->
      <Transition name="fade-up">
        <FeatureSurvey
          v-if="showEmailCapture"
          :chronotype="chronotype"
          :goal="goal"
          :track="track"
          @submitted="() => {}"
        />
      </Transition>

      <!-- 6. Referral Section -->
      <Transition name="fade-up">
        <ReferralSection
          v-if="showEmailCapture"
          :referral-code="referralCode"
        />
      </Transition>

      <!-- Bottom spacing -->
      <div class="h-16 sm:h-24" />
    </div>
  </div>
</template>

<style scoped>
.fade-up-enter-active {
  transition: all 0.5s ease-out;
}
.fade-up-leave-active {
  transition: all 0.3s ease-in;
}
.fade-up-enter-from {
  opacity: 0;
  transform: translateY(16px);
}
.fade-up-leave-to {
  opacity: 0;
  transform: translateY(-8px);
}
</style>
