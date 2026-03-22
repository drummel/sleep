<script setup lang="ts">
const emit = defineEmits<{
  'start-quiz': []
}>()
</script>

<template>
  <section class="relative py-24 sm:py-32 overflow-hidden">
    <!-- Gradient background -->
    <div class="absolute inset-0 bg-gradient-to-b from-slate-950 via-indigo-950/50 to-slate-950" />
    <div class="absolute inset-0 bg-[radial-gradient(ellipse_at_center,rgba(99,102,241,0.1),transparent_70%)]" />

    <div class="relative z-10 max-w-2xl mx-auto px-6 text-center">
      <h2 class="text-3xl sm:text-4xl md:text-5xl font-light text-white tracking-tight mb-5">
        Ready to discover your chronotype?
      </h2>

      <p class="text-slate-400 font-light text-lg mb-10 max-w-lg mx-auto">
        It takes 60 seconds and could change the way you structure every day.
      </p>

      <button
        class="group inline-flex items-center justify-center px-8 py-4 text-base font-medium text-white bg-indigo-600 rounded-full transition-all duration-300 hover:bg-indigo-500 hover:shadow-lg hover:shadow-indigo-500/25 hover:-translate-y-0.5 active:translate-y-0"
        @click="emit('start-quiz')"
      >
        Take the Free Quiz
        <svg
          class="ml-2 w-4 h-4 transition-transform duration-300 group-hover:translate-x-1"
          fill="none"
          viewBox="0 0 24 24"
          stroke="currentColor"
          stroke-width="2"
        >
          <path stroke-linecap="round" stroke-linejoin="round" d="M13 7l5 5m0 0l-5 5m5-5H6" />
        </svg>
      </button>
    </div>
  </section>
</template>
