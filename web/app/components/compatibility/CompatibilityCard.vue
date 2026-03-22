<script setup lang="ts">
import { getPairing } from '@/lib/compatibility'
import { getChronotype } from '@/lib/chronotypes'
import type { ChronotypeId } from '@/lib/chronotypes'

const props = defineProps<{
  selfType: string
  partnerType: string
}>()

const self = computed(() => getChronotype(props.selfType as ChronotypeId))
const partner = computed(() => getChronotype(props.partnerType as ChronotypeId))
const pairing = computed(() => getPairing(props.selfType as ChronotypeId, props.partnerType as ChronotypeId))

const overlapDots = computed(() => {
  const score = pairing.value.overlapScore
  return Array.from({ length: 5 }, (_, i) => i < score)
})
</script>

<template>
  <div class="relative mx-auto w-full max-w-md">
    <!-- Gradient border wrapper -->
    <div class="absolute -inset-px rounded-3xl bg-gradient-to-br from-indigo-400 via-violet-400 to-sky-400 opacity-60 blur-[1px]" />

    <!-- Card body -->
    <div class="relative overflow-hidden rounded-3xl bg-card shadow-2xl shadow-primary/10">
      <!-- Top gradient accent -->
      <div class="h-1.5 bg-gradient-to-r from-indigo-400 via-violet-400 to-sky-400" />

      <!-- Content -->
      <div class="px-6 pb-6 pt-7 sm:px-8 sm:pb-8 sm:pt-9">
        <!-- Chronotype pair display -->
        <div class="flex items-center justify-center gap-5 sm:gap-8">
          <!-- Self -->
          <div class="flex flex-col items-center gap-2">
            <div
              class="flex h-20 w-20 items-center justify-center rounded-2xl sm:h-24 sm:w-24"
              :class="self.bgColor"
            >
              <span class="text-4xl sm:text-5xl">{{ self.emoji }}</span>
            </div>
            <div class="text-center">
              <p class="text-sm font-semibold text-foreground">{{ self.name }}</p>
              <p class="text-xs text-muted-foreground">You</p>
            </div>
          </div>

          <!-- Heart / connector -->
          <div class="flex flex-col items-center gap-1 pt-1">
            <div class="flex h-10 w-10 items-center justify-center rounded-full bg-primary/10">
              <svg class="h-5 w-5 text-primary" fill="currentColor" viewBox="0 0 24 24">
                <path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z" />
              </svg>
            </div>
            <div class="h-6 w-px bg-border" />
          </div>

          <!-- Partner -->
          <div class="flex flex-col items-center gap-2">
            <div
              class="flex h-20 w-20 items-center justify-center rounded-2xl sm:h-24 sm:w-24"
              :class="partner.bgColor"
            >
              <span class="text-4xl sm:text-5xl">{{ partner.emoji }}</span>
            </div>
            <div class="text-center">
              <p class="text-sm font-semibold text-foreground">{{ partner.name }}</p>
              <p class="text-xs text-muted-foreground">Them</p>
            </div>
          </div>
        </div>

        <!-- Divider -->
        <div class="my-6 h-px bg-gradient-to-r from-transparent via-border to-transparent" />

        <!-- Pairing name -->
        <h3 class="text-center text-xl font-semibold tracking-tight text-foreground sm:text-2xl">
          {{ pairing.name }}
        </h3>

        <!-- Details -->
        <div class="mt-5 space-y-4">
          <!-- Best overlap window -->
          <div class="rounded-xl bg-secondary/50 px-4 py-3">
            <p class="text-xs font-medium uppercase tracking-wider text-muted-foreground">
              Best Overlap Window
            </p>
            <p class="mt-1 text-base font-semibold text-foreground">
              {{ pairing.bestWindow }}
            </p>
          </div>

          <!-- Worth knowing -->
          <div class="rounded-xl bg-secondary/50 px-4 py-3">
            <p class="text-xs font-medium uppercase tracking-wider text-muted-foreground">
              Worth Knowing
            </p>
            <p class="mt-1 text-sm font-light leading-relaxed text-foreground/80">
              {{ pairing.worthKnowing }}
            </p>
          </div>

          <!-- Overlap score -->
          <div class="flex items-center justify-between rounded-xl bg-secondary/50 px-4 py-3">
            <p class="text-xs font-medium uppercase tracking-wider text-muted-foreground">
              Overlap Score
            </p>
            <div class="flex items-center gap-1.5">
              <span
                v-for="(filled, i) in overlapDots"
                :key="i"
                class="h-2.5 w-2.5 rounded-full transition-colors duration-300"
                :class="filled ? 'bg-primary' : 'bg-border'"
              />
              <span class="ml-2 text-xs font-semibold text-muted-foreground">
                {{ pairing.overlapScore }}/5
              </span>
            </div>
          </div>
        </div>

        <!-- Branding footer -->
        <div class="mt-6 flex items-center justify-center gap-2 border-t border-border pt-4">
          <div class="h-4 w-4 rounded-full bg-gradient-to-br from-indigo-500 to-violet-500" />
          <p class="text-xs font-medium tracking-wide text-muted-foreground">
            sleeppath.app/compatibility
          </p>
        </div>
      </div>
    </div>
  </div>
</template>
