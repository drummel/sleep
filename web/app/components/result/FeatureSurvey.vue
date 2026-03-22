<script setup lang="ts">
import { submitFeatureSurvey, trackEvent } from '@/lib/analytics'

const props = defineProps<{
  chronotype: string
  goal: string
  track: string
}>()

const emit = defineEmits<{
  submitted: []
}>()

const features = [
  { id: 'adaptive_engine', label: 'Daily schedule that adapts to my actual sleep' },
  { id: 'caffeine_cutoff', label: 'Smart caffeine timing' },
  { id: 'peak_focus', label: 'Focus window alerts' },
  { id: 'wind_down', label: 'Wind-down and sleep coaching' },
  { id: 'weekly_patterns', label: 'Weekly patterns and trends' },
  { id: 'watch_complication', label: 'Apple Watch energy state' },
  { id: 'calendar_export', label: 'Calendar integration' },
  { id: 'night_shift', label: 'Night shift / irregular schedule support' },
  { id: 'partner_mode', label: "Partner Mode \u2014 see how your schedule fits with your partner\u2019s" },
] as const

const selected = ref<string[]>([])
const isSubmitting = ref(false)
const isSubmitted = ref(false)

const maxReached = computed(() => selected.value.length >= 3)

function toggle(id: string) {
  const index = selected.value.indexOf(id)
  if (index >= 0) {
    selected.value = selected.value.filter((s) => s !== id)
  } else if (!maxReached.value) {
    selected.value = [...selected.value, id]
  }
}

function isSelected(id: string) {
  return selected.value.includes(id)
}

function isDisabled(id: string) {
  return maxReached.value && !isSelected(id)
}

async function handleSubmit() {
  if (selected.value.length === 0 || isSubmitting.value) return

  isSubmitting.value = true

  try {
    await submitFeatureSurvey({
      chronotype: props.chronotype,
      goal: props.goal,
      features: selected.value,
      feature_count: selected.value.length,
      track: props.track,
      submitted_at: new Date().toISOString(),
    })

    trackEvent({
      name: 'feature_vote',
      data: { features: selected.value, chronotype: props.chronotype },
    })

    isSubmitted.value = true
    emit('submitted')
  } finally {
    isSubmitting.value = false
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
          Thanks for voting!
        </h3>
        <p class="text-sm text-muted-foreground">
          Your picks help us build what matters most.
        </p>
      </div>

      <!-- Survey form -->
      <div v-else>
        <div class="text-center mb-8">
          <h2 class="text-xl sm:text-2xl font-semibold text-foreground mb-2">
            Which features matter most to you?
          </h2>
          <p class="text-sm text-muted-foreground">
            Pick up to 3 — this helps us prioritize what to build first.
          </p>
        </div>

        <!-- Feature grid -->
        <div class="space-y-2.5">
          <button
            v-for="feature in features"
            :key="feature.id"
            type="button"
            :disabled="isDisabled(feature.id)"
            class="group w-full flex items-center gap-3.5 rounded-xl border p-4 text-left text-sm transition-all duration-200"
            :class="[
              isSelected(feature.id)
                ? 'border-primary/40 bg-primary/[0.04] shadow-sm'
                : 'border-border bg-card hover:border-border/80 hover:bg-secondary/50',
              isDisabled(feature.id) ? 'opacity-40 cursor-not-allowed' : 'cursor-pointer',
            ]"
            @click="toggle(feature.id)"
          >
            <!-- Checkbox -->
            <div
              class="flex-shrink-0 w-5 h-5 rounded-md border-2 flex items-center justify-center transition-all duration-200"
              :class="
                isSelected(feature.id)
                  ? 'border-primary bg-primary'
                  : 'border-muted-foreground/30 group-hover:border-muted-foreground/50'
              "
            >
              <svg
                v-if="isSelected(feature.id)"
                class="w-3 h-3 text-primary-foreground"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
                stroke-width="3"
              >
                <path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7" />
              </svg>
            </div>

            <!-- Label -->
            <span
              class="leading-snug transition-colors duration-200"
              :class="isSelected(feature.id) ? 'text-foreground font-medium' : 'text-muted-foreground'"
            >
              {{ feature.label }}
            </span>
          </button>
        </div>

        <!-- Selection count + submit -->
        <div class="mt-8 flex flex-col items-center gap-3">
          <p class="text-xs text-muted-foreground/70">
            {{ selected.length }} / 3 selected
          </p>

          <button
            type="button"
            :disabled="selected.length === 0 || isSubmitting"
            class="h-11 px-8 rounded-full bg-primary text-primary-foreground text-sm font-medium transition-all duration-200 hover:opacity-90 hover:shadow-md hover:shadow-primary/20 active:scale-[0.98] disabled:opacity-40 disabled:cursor-not-allowed"
            @click="handleSubmit"
          >
            <span v-if="isSubmitting" class="inline-flex items-center gap-2">
              <svg class="w-4 h-4 animate-spin" viewBox="0 0 24 24" fill="none">
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" />
                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
              </svg>
              Submitting...
            </span>
            <span v-else>Submit My Picks</span>
          </button>
        </div>
      </div>
    </div>
  </section>
</template>
