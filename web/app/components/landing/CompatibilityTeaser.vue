<script setup lang="ts">
const emit = defineEmits<{
  'compatibility-click': []
}>()
</script>

<template>
  <section class="bg-slate-950 py-24 sm:py-32">
    <div class="max-w-3xl mx-auto px-6">
      <div class="relative rounded-3xl border border-white/10 bg-gradient-to-br from-white/[0.04] to-transparent p-8 sm:p-12 text-center overflow-hidden">
        <!-- Subtle decorative glow -->
        <div class="absolute -top-24 -right-24 w-64 h-64 rounded-full bg-violet-500/10 blur-3xl pointer-events-none" />
        <div class="absolute -bottom-24 -left-24 w-64 h-64 rounded-full bg-indigo-500/10 blur-3xl pointer-events-none" />

        <div class="relative z-10">
          <h2 class="text-2xl sm:text-3xl md:text-4xl font-light text-white tracking-tight leading-snug mb-5">
            Do you sleep with a Wolf?<br class="hidden sm:block" />
            A Lion? <span class="text-indigo-400">Find out.</span>
          </h2>

          <p class="text-slate-400 font-light text-lg leading-relaxed max-w-xl mx-auto mb-8">
            Couples often have different biological clocks. Understanding your partner's
            chronotype can transform how you navigate mornings, evenings, and everything in between.
          </p>

          <NuxtLink
            to="/compatibility"
            class="inline-flex items-center justify-center px-7 py-3.5 text-sm font-medium text-indigo-400 border border-indigo-500/30 rounded-full transition-all duration-300 hover:bg-indigo-500/10 hover:border-indigo-500/50 hover:-translate-y-0.5"
            @click="emit('compatibility-click')"
          >
            See how it works
            <svg
              class="ml-2 w-4 h-4"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
              stroke-width="2"
            >
              <path stroke-linecap="round" stroke-linejoin="round" d="M13 7l5 5m0 0l-5 5m5-5H6" />
            </svg>
          </NuxtLink>

          <p class="mt-4 text-xs text-slate-500 font-light">
            No account needed. Works even if they don't take the quiz.
          </p>
        </div>
      </div>
    </div>
  </section>
</template>
