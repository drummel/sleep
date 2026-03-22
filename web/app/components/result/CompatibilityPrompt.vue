<script setup lang="ts">
import { getChronotype, type ChronotypeId } from '@/lib/chronotypes'
import { trackEvent } from '@/lib/analytics'

const props = defineProps<{
  chronotype: string
  partnerRef: string | null
  referrerChronotype: string | null
}>()

const selfInfo = computed(() => getChronotype(props.chronotype as ChronotypeId))
const referrerInfo = computed(() =>
  props.referrerChronotype ? getChronotype(props.referrerChronotype as ChronotypeId) : null,
)

const hasPartner = computed(() => !!props.partnerRef && !!props.referrerChronotype)

function handleClick() {
  trackEvent({
    name: 'compatibility_tool_opened',
    data: { source: hasPartner.value ? 'result_partner' : 'result_solo' },
  })

  if (hasPartner.value) {
    navigateTo(`/compatibility?self=${props.chronotype}&partner=${props.referrerChronotype}`)
  } else {
    navigateTo(`/compatibility?self=${props.chronotype}`)
  }
}
</script>

<template>
  <section class="py-12 sm:py-16">
    <div class="max-w-lg mx-auto px-6">
      <div class="rounded-2xl border border-border bg-card p-8 sm:p-10">
        <!-- Personalized version (has partner referral) -->
        <template v-if="hasPartner && referrerInfo">
          <div class="flex items-center justify-center gap-3 mb-5">
            <span class="text-4xl">{{ selfInfo.emoji }}</span>
            <span class="text-xl text-muted-foreground/50 font-light">&</span>
            <span class="text-4xl">{{ referrerInfo.emoji }}</span>
          </div>

          <h3 class="text-xl sm:text-2xl font-semibold text-foreground text-center mb-3">
            See how your rhythms align
          </h3>
          <p class="text-sm text-muted-foreground text-center leading-relaxed mb-8">
            You're a {{ selfInfo.name }} and your partner is a {{ referrerInfo.name }}.
            Discover how your sleep schedules overlap, where they diverge, and how to make it work.
          </p>
        </template>

        <!-- Default version (no partner) -->
        <template v-else>
          <div class="flex items-center justify-center mb-5">
            <span class="text-4xl">{{ selfInfo.emoji }}</span>
          </div>

          <h3 class="text-xl sm:text-2xl font-semibold text-foreground text-center mb-3">
            Curious how your rhythm fits with someone you share a bed with?
          </h3>
          <p class="text-sm text-muted-foreground text-center leading-relaxed mb-8">
            Couples often have different chronotypes. That means different energy peaks,
            different sleep times, and different ideal routines. See how yours compare.
          </p>
        </template>

        <div class="text-center">
          <button
            class="group inline-flex items-center gap-2 h-11 px-6 rounded-full bg-primary text-primary-foreground text-sm font-medium transition-all duration-200 hover:opacity-90 hover:shadow-md hover:shadow-primary/20 active:scale-[0.98]"
            @click="handleClick"
          >
            Discover your compatibility
            <svg
              class="w-4 h-4 transition-transform duration-200 group-hover:translate-x-0.5"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
              stroke-width="2"
            >
              <path stroke-linecap="round" stroke-linejoin="round" d="M13 7l5 5m0 0l-5 5m5-5H6" />
            </svg>
          </button>
        </div>
      </div>
    </div>
  </section>
</template>
