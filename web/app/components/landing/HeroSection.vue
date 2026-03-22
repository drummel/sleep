<script setup lang="ts">
const emit = defineEmits<{
  'start-quiz': []
}>()
</script>

<template>
  <section class="relative min-h-[90vh] flex items-center justify-center overflow-hidden bg-slate-950">
    <!-- Abstract gradient background decoration -->
    <div class="absolute inset-0 pointer-events-none">
      <!-- Moon glow -->
      <div
        class="absolute top-1/4 right-1/4 w-96 h-96 rounded-full opacity-20 blur-3xl bg-indigo-500"
      />
      <!-- Secondary glow -->
      <div
        class="absolute bottom-1/3 left-1/6 w-72 h-72 rounded-full opacity-15 blur-3xl bg-violet-400"
      />
      <!-- Subtle star-like dots -->
      <div class="absolute top-[15%] left-[20%] w-1.5 h-1.5 rounded-full bg-white/30" />
      <div class="absolute top-[25%] right-[30%] w-1 h-1 rounded-full bg-white/20" />
      <div class="absolute top-[40%] left-[60%] w-1 h-1 rounded-full bg-white/25" />
      <div class="absolute top-[12%] right-[15%] w-1.5 h-1.5 rounded-full bg-white/15" />
      <div class="absolute bottom-[35%] left-[35%] w-1 h-1 rounded-full bg-white/20" />
      <div class="absolute top-[55%] right-[45%] w-0.5 h-0.5 rounded-full bg-white/30" />
      <div class="absolute top-[8%] left-[45%] w-1 h-1 rounded-full bg-white/15" />
      <div class="absolute bottom-[20%] right-[20%] w-1 h-1 rounded-full bg-white/20" />
      <!-- Gradient overlay from bottom -->
      <div class="absolute inset-x-0 bottom-0 h-48 bg-gradient-to-t from-slate-950 to-transparent" />
    </div>

    <!-- Content -->
    <div class="relative z-10 max-w-3xl mx-auto px-6 text-center">
      <h1
        class="text-4xl sm:text-5xl md:text-6xl lg:text-7xl font-light tracking-tight text-white leading-[1.1] mb-6"
      >
        Your biology has a schedule.
        <span class="block mt-2 bg-gradient-to-r from-indigo-300 to-violet-300 bg-clip-text text-transparent">
          Start following it.
        </span>
      </h1>

      <p class="text-lg sm:text-xl text-slate-400 font-light max-w-xl mx-auto mb-10 leading-relaxed">
        Discover your chronotype and unlock the schedule your body was designed for.
        Better sleep, sharper focus, more energy — all by working
        <em class="text-slate-300">with</em> your biology.
      </p>

      <div class="flex flex-col items-center gap-4">
        <button
          class="group relative inline-flex items-center justify-center px-8 py-4 text-base font-medium text-white bg-indigo-600 rounded-full transition-all duration-300 hover:bg-indigo-500 hover:shadow-lg hover:shadow-indigo-500/25 hover:-translate-y-0.5 active:translate-y-0"
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

        <p class="text-sm text-slate-500 font-light tracking-wide">
          60 seconds. No signup required.
        </p>
      </div>
    </div>
  </section>
</template>
