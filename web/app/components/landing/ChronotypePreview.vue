<script setup lang="ts">
import { chronotypes, chronotypeOrder } from '@/lib/chronotypes'

const cards = chronotypeOrder.map((id) => chronotypes[id])
</script>

<template>
  <section class="bg-slate-950 py-24 sm:py-32">
    <div class="max-w-5xl mx-auto px-6">
      <!-- Section headline -->
      <div class="text-center mb-16">
        <h2 class="text-3xl sm:text-4xl font-light text-white tracking-tight">
          Four Chronotypes. Which One Are You?
        </h2>
        <p class="mt-4 text-slate-400 font-light text-lg">
          Everyone falls into one of four biological sleep patterns.
        </p>
      </div>

      <!-- Chronotype cards -->
      <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
        <div
          v-for="type in cards"
          :key="type.id"
          :class="[
            'group relative rounded-2xl border p-6 transition-all duration-300',
            'hover:-translate-y-1 hover:shadow-lg',
            type.borderColor,
            type.bgColor,
          ]"
        >
          <!-- Emoji -->
          <div class="text-4xl mb-4">
            {{ type.emoji }}
          </div>

          <!-- Name -->
          <h3 :class="['text-xl font-medium mb-1', type.color]">
            {{ type.name }}
          </h3>

          <!-- Tagline -->
          <p class="text-slate-600 text-sm font-medium mb-3">
            {{ type.tagline }}
          </p>

          <!-- Population -->
          <p class="text-xs text-slate-400 font-light">
            {{ type.population }}
          </p>
        </div>
      </div>
    </div>
  </section>
</template>
