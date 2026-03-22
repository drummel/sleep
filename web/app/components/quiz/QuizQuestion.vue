<script setup lang="ts">
import type { QuizQuestion } from '@/lib/quiz-questions'

const props = defineProps<{
  question: QuizQuestion
  questionNumber: number
}>()

const emit = defineEmits<{
  answer: [index: number]
}>()

const selectedIndex = ref<number | null>(null)
const animationKey = ref(0)

watch(
  () => props.questionNumber,
  () => {
    selectedIndex.value = null
    animationKey.value++
  },
)

function selectAnswer(index: number) {
  if (selectedIndex.value !== null) return
  selectedIndex.value = index

  setTimeout(() => {
    emit('answer', index)
  }, 300)
}
</script>

<template>
  <div :key="animationKey" class="space-y-8">
    <!-- Question text -->
    <div class="animate-fade-in-up space-y-3 text-center">
      <h2 class="text-2xl font-semibold leading-snug tracking-tight text-foreground sm:text-3xl">
        {{ question.question }}
      </h2>
      <p class="mx-auto max-w-md text-base text-muted-foreground">
        {{ question.context }}
      </p>
    </div>

    <!-- Answer cards -->
    <div class="mx-auto grid max-w-lg gap-3">
      <button
        v-for="(answer, index) in question.answers"
        :key="`${animationKey}-${index}`"
        class="animate-fade-in-up group relative w-full rounded-xl border border-border bg-card px-5 py-4 text-left transition-all duration-200"
        :class="[
          `stagger-${index + 1}`,
          selectedIndex === index
            ? 'border-primary bg-primary/5 ring-1 ring-primary/30'
            : selectedIndex !== null
              ? 'opacity-50'
              : 'hover:border-primary/40 hover:bg-accent/50 hover:shadow-sm',
        ]"
        :style="{ opacity: 0 }"
        :disabled="selectedIndex !== null"
        @click="selectAnswer(index)"
      >
        <div class="flex items-center gap-4">
          <!-- Option indicator -->
          <span
            class="flex h-8 w-8 shrink-0 items-center justify-center rounded-full border text-sm font-medium transition-all duration-200"
            :class="
              selectedIndex === index
                ? 'border-primary bg-primary text-primary-foreground'
                : 'border-border text-muted-foreground group-hover:border-primary/40 group-hover:text-foreground'
            "
          >
            {{ String.fromCharCode(65 + index) }}
          </span>

          <span
            class="text-sm font-medium leading-snug transition-colors duration-200 sm:text-base"
            :class="
              selectedIndex === index
                ? 'text-foreground'
                : 'text-foreground/80 group-hover:text-foreground'
            "
          >
            {{ answer.text }}
          </span>
        </div>
      </button>
    </div>
  </div>
</template>
