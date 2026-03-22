<script setup lang="ts">
import { getChronotype, type ChronotypeId } from '@/lib/chronotypes'

const props = defineProps<{
  chronotype: string
}>()

const emit = defineEmits<{
  revealed: []
}>()

const info = computed(() => getChronotype(props.chronotype as ChronotypeId))
const isRevealed = ref(false)
const showStats = ref(false)
const showDescription = ref(false)

onMounted(() => {
  // Staggered reveal animation
  setTimeout(() => {
    isRevealed.value = true
  }, 300)
  setTimeout(() => {
    showStats.value = true
  }, 1000)
  setTimeout(() => {
    showDescription.value = true
    emit('revealed')
  }, 1500)
})
</script>

<template>
  <section class="relative py-16 sm:py-24 overflow-hidden">
    <!-- Background glow matching chronotype -->
    <div class="absolute inset-0 pointer-events-none">
      <div
        class="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[600px] h-[600px] rounded-full opacity-[0.08] blur-[100px] transition-opacity duration-1000"
        :class="[
          chronotype === 'lion' ? 'bg-amber-500' : '',
          chronotype === 'bear' ? 'bg-orange-500' : '',
          chronotype === 'wolf' ? 'bg-violet-500' : '',
          chronotype === 'dolphin' ? 'bg-sky-500' : '',
          isRevealed ? 'opacity-[0.08]' : 'opacity-0',
        ]"
      />
    </div>

    <div class="relative z-10 max-w-2xl mx-auto px-6 text-center">
      <!-- Emoji reveal -->
      <div
        class="transition-all duration-700 ease-out"
        :class="isRevealed ? 'opacity-100 scale-100' : 'opacity-0 scale-50'"
      >
        <span class="text-7xl sm:text-8xl md:text-9xl block mb-6 drop-shadow-lg">
          {{ info.emoji }}
        </span>
      </div>

      <!-- "You're a ___!" -->
      <div
        class="transition-all duration-600 ease-out delay-200"
        :class="isRevealed ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-6'"
      >
        <h1 class="text-3xl sm:text-4xl md:text-5xl font-bold tracking-tight text-foreground mb-3">
          You're a
          <span :class="info.color">{{ info.name }}</span>!
        </h1>
        <p class="text-lg sm:text-xl font-light text-muted-foreground">
          {{ info.tagline }}
        </p>
        <p class="mt-2 text-sm text-muted-foreground/70">
          {{ info.population }}
        </p>
      </div>

      <!-- Key stats -->
      <div
        class="mt-12 grid grid-cols-1 sm:grid-cols-3 gap-4 transition-all duration-600 ease-out"
        :class="showStats ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-8'"
      >
        <div
          class="rounded-xl border border-border bg-card p-5 text-left"
        >
          <div class="text-xs font-medium uppercase tracking-wider text-muted-foreground mb-1.5">
            Sleep Window
          </div>
          <div class="text-base font-semibold text-foreground">
            {{ info.sleepWindow }}
          </div>
        </div>

        <div
          class="rounded-xl border border-border bg-card p-5 text-left"
        >
          <div class="text-xs font-medium uppercase tracking-wider text-muted-foreground mb-1.5">
            Peak Focus
          </div>
          <div class="text-base font-semibold text-foreground">
            {{ info.peakFocus }}
          </div>
        </div>

        <div
          class="rounded-xl border border-border bg-card p-5 text-left"
        >
          <div class="text-xs font-medium uppercase tracking-wider text-muted-foreground mb-1.5">
            Best For
          </div>
          <div class="text-sm font-medium text-foreground leading-snug">
            {{ info.bestFor }}
          </div>
        </div>
      </div>

      <!-- Full description -->
      <div
        class="mt-10 transition-all duration-600 ease-out"
        :class="showDescription ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-6'"
      >
        <p class="text-base sm:text-lg leading-relaxed text-muted-foreground font-light max-w-xl mx-auto">
          {{ info.description }}
        </p>
      </div>
    </div>
  </section>
</template>
