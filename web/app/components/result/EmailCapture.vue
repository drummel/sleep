<script setup lang="ts">
import { useEmail } from '@/composables/useEmail'

const props = defineProps<{
  chronotype: string
}>()

const emit = defineEmits<{
  captured: []
}>()

const { email, isSubmitted, isLoading, error, submitEmail } = useEmail()

async function handleSubmit() {
  const success = await submitEmail(props.chronotype)
  if (success) {
    emit('captured')
  }
}
</script>

<template>
  <section class="py-12 sm:py-16">
    <div class="max-w-lg mx-auto px-6">
      <!-- Success state -->
      <div
        v-if="isSubmitted"
        class="text-center animate-fade-in-up"
      >
        <div class="inline-flex items-center justify-center w-14 h-14 rounded-full bg-emerald-50 mb-4">
          <svg class="w-7 h-7 text-emerald-500" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7" />
          </svg>
        </div>
        <h3 class="text-xl font-semibold text-foreground mb-2">
          You're on the list!
        </h3>
        <p class="text-sm text-muted-foreground">
          We'll send your personalized daily schedule soon.
        </p>
      </div>

      <!-- Capture form -->
      <div v-else class="text-center">
        <h2 class="text-xl sm:text-2xl font-semibold text-foreground mb-2">
          Get your personalized daily schedule
        </h2>
        <p class="text-sm text-muted-foreground mb-8">
          We'll build a schedule optimized for your chronotype and send it straight to your inbox.
        </p>

        <form
          class="flex flex-col sm:flex-row gap-3"
          @submit.prevent="handleSubmit"
        >
          <div class="relative flex-1">
            <input
              v-model="email"
              type="email"
              required
              placeholder="you@example.com"
              autocomplete="email"
              class="w-full h-12 px-4 rounded-xl border border-border bg-card text-foreground text-sm placeholder:text-muted-foreground/60 focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary transition-all duration-200"
              :class="{ 'border-destructive focus:ring-destructive/30': error }"
            />
          </div>

          <button
            type="submit"
            :disabled="isLoading"
            class="h-12 px-6 rounded-xl bg-primary text-primary-foreground text-sm font-medium transition-all duration-200 hover:opacity-90 hover:shadow-md hover:shadow-primary/20 active:scale-[0.98] disabled:opacity-50 disabled:cursor-not-allowed whitespace-nowrap"
          >
            <span v-if="isLoading" class="inline-flex items-center gap-2">
              <svg class="w-4 h-4 animate-spin" viewBox="0 0 24 24" fill="none">
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" />
                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
              </svg>
              Sending...
            </span>
            <span v-else>Send My Schedule</span>
          </button>
        </form>

        <p
          v-if="error"
          class="mt-3 text-sm text-destructive animate-fade-in"
        >
          {{ error }}
        </p>

        <p class="mt-4 text-xs text-muted-foreground/60">
          No spam. Unsubscribe anytime.
        </p>
      </div>
    </div>
  </section>
</template>
