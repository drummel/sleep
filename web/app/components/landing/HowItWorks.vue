<script setup lang="ts">
const steps = [
  {
    number: 1,
    title: 'Take the Quiz',
    description: '8 quick questions about your natural rhythms — when you wake, when you focus, when you fade.',
  },
  {
    number: 2,
    title: 'Discover Your Type',
    description: 'Lion, Bear, Wolf, or Dolphin — learn which biological pattern drives your energy and sleep.',
  },
  {
    number: 3,
    title: 'Get Your Schedule',
    description: 'Personalized daily timing for peak performance, better sleep, and more energy.',
  },
]
</script>

<template>
  <section class="bg-slate-950 py-24 sm:py-32">
    <div class="max-w-5xl mx-auto px-6">
      <!-- Section headline -->
      <div class="text-center mb-16">
        <h2 class="text-3xl sm:text-4xl font-light text-white tracking-tight">
          How It Works
        </h2>
        <p class="mt-4 text-slate-400 font-light text-lg">
          Three steps to a schedule built for your biology.
        </p>
      </div>

      <!-- Steps -->
      <div class="grid grid-cols-1 md:grid-cols-3 gap-8 md:gap-12">
        <div
          v-for="step in steps"
          :key="step.number"
          class="relative text-center md:text-left"
        >
          <!-- Numbered circle -->
          <div class="flex justify-center md:justify-start mb-6">
            <div
              class="w-12 h-12 rounded-full border border-indigo-500/30 bg-indigo-500/10 flex items-center justify-center"
            >
              <span class="text-indigo-400 font-light text-lg">{{ step.number }}</span>
            </div>
          </div>

          <!-- Content -->
          <h3 class="text-xl font-medium text-white mb-3">
            {{ step.title }}
          </h3>
          <p class="text-slate-400 font-light leading-relaxed">
            {{ step.description }}
          </p>

          <!-- Connector line (hidden on mobile and last item) -->
          <div
            v-if="step.number < 3"
            class="hidden md:block absolute top-6 left-[calc(50%+2rem)] w-[calc(100%-4rem)] h-px bg-gradient-to-r from-indigo-500/20 to-transparent"
          />
        </div>
      </div>
    </div>
  </section>
</template>
