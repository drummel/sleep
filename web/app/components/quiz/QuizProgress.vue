<script setup lang="ts">
const props = defineProps<{
  current: number
  total: number
}>()

const emit = defineEmits<{
  back: []
}>()

const percentage = computed(() => ((props.current + 1) / props.total) * 100)
</script>

<template>
  <div class="w-full space-y-3">
    <!-- Top row: back button + question counter -->
    <div class="flex items-center justify-between">
      <button
        v-if="current > 0"
        class="flex items-center gap-1.5 text-sm font-medium text-muted-foreground transition-colors duration-200 hover:text-foreground"
        @click="emit('back')"
      >
        <svg
          xmlns="http://www.w3.org/2000/svg"
          width="16"
          height="16"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
          stroke-linecap="round"
          stroke-linejoin="round"
        >
          <path d="M19 12H5" />
          <path d="m12 19-7-7 7-7" />
        </svg>
        Back
      </button>
      <div v-else />

      <span class="text-sm font-medium tracking-wide text-muted-foreground">
        Question {{ current + 1 }} of {{ total }}
      </span>
    </div>

    <!-- Progress bar -->
    <div class="relative h-1.5 w-full overflow-hidden rounded-full bg-secondary">
      <div
        class="absolute inset-y-0 left-0 rounded-full bg-primary transition-all duration-500 ease-out"
        :style="{ width: `${percentage}%` }"
      />
    </div>
  </div>
</template>
