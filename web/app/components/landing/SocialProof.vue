<script setup lang="ts">
const stars = 5
const rating = 4.8
</script>

<template>
  <section class="bg-slate-950 border-y border-white/5">
    <div class="max-w-4xl mx-auto px-6 py-8 flex flex-col sm:flex-row items-center justify-center gap-4 sm:gap-8">
      <!-- Star rating -->
      <div class="flex items-center gap-1.5">
        <div class="flex items-center gap-0.5">
          <svg
            v-for="i in stars"
            :key="i"
            class="w-4 h-4 text-amber-400"
            fill="currentColor"
            viewBox="0 0 20 20"
          >
            <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
          </svg>
        </div>
        <span class="text-sm text-slate-400 font-light">{{ rating }}</span>
      </div>

      <!-- Divider -->
      <div class="hidden sm:block w-px h-4 bg-white/10" />

      <!-- Social proof text -->
      <p class="text-sm text-slate-400 font-light tracking-wide">
        Join <span class="text-slate-300 font-medium">10,000+</span> people who've discovered their chronotype
      </p>
    </div>
  </section>
</template>
