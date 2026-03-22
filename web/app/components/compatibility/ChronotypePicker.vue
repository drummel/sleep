<script setup lang="ts">
import { chronotypes, chronotypeOrder } from '@/lib/chronotypes'
import type { ChronotypeId } from '@/lib/chronotypes'

defineProps<{
  label: string
  modelValue: string | null
}>()

const emit = defineEmits<{
  'update:modelValue': [value: string]
}>()

const types = chronotypeOrder.map((id) => chronotypes[id])
</script>

<template>
  <div class="space-y-4">
    <p class="text-sm font-medium text-muted-foreground tracking-wide uppercase">
      {{ label }}
    </p>

    <div class="grid grid-cols-2 lg:grid-cols-4 gap-3">
      <button
        v-for="type in types"
        :key="type.id"
        class="group relative flex flex-col items-center gap-2.5 rounded-2xl border-2 px-4 py-5 transition-all duration-300 hover:-translate-y-0.5 hover:shadow-md"
        :class="[
          modelValue === type.id
            ? 'border-primary bg-primary/5 shadow-md shadow-primary/10'
            : 'border-border bg-card hover:border-primary/30 hover:bg-card',
        ]"
        @click="emit('update:modelValue', type.id)"
      >
        <!-- Selection indicator -->
        <div
          v-if="modelValue === type.id"
          class="absolute top-2.5 right-2.5 flex h-5 w-5 items-center justify-center rounded-full bg-primary"
        >
          <svg
            class="h-3 w-3 text-primary-foreground"
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
            stroke-width="3"
          >
            <path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7" />
          </svg>
        </div>

        <!-- Emoji -->
        <span class="text-4xl transition-transform duration-300 group-hover:scale-110">
          {{ type.emoji }}
        </span>

        <!-- Name -->
        <span
          class="text-sm font-semibold tracking-wide transition-colors duration-300"
          :class="modelValue === type.id ? 'text-foreground' : 'text-muted-foreground group-hover:text-foreground'"
        >
          {{ type.name }}
        </span>

        <!-- Tagline -->
        <span
          class="text-xs font-light leading-snug text-center"
          :class="modelValue === type.id ? 'text-muted-foreground' : 'text-muted-foreground/60'"
        >
          {{ type.tagline }}
        </span>
      </button>
    </div>
  </div>
</template>
