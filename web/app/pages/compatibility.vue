<script setup lang="ts">
import { trackEvent } from '@/lib/analytics'
import { useEmail } from '@/composables/useEmail'
import type { ChronotypeId } from '@/lib/chronotypes'

// Head metadata
useHead({
  title: 'Sleep Compatibility — SleepPath',
  meta: [
    { name: 'description', content: 'Discover your sleep compatibility. Compare chronotypes with your partner and find your best overlap window.' },
    { property: 'og:title', content: 'Sleep Compatibility — SleepPath' },
    { property: 'og:description', content: 'Are you a Lion dating a Wolf? Find out how your sleep rhythms align.' },
    { property: 'og:url', content: 'https://sleeppath.app/compatibility' },
    { property: 'og:type', content: 'website' },
    { name: 'twitter:card', content: 'summary_large_image' },
    { name: 'twitter:title', content: 'Sleep Compatibility — SleepPath' },
    { name: 'twitter:description', content: 'Are you a Lion dating a Wolf? Find out how your sleep rhythms align.' },
  ],
})

const route = useRoute()
const { referralCode } = useEmail()

// State
const selfType = ref<string | null>(null)
const partnerType = ref<string | null>(null)
const selfKnown = ref(false)
const partnerKnown = ref(false)

// Pre-fill from query param
onMounted(() => {
  const selfParam = route.query.self as string | undefined
  if (selfParam && ['lion', 'bear', 'wolf', 'dolphin'].includes(selfParam)) {
    selfType.value = selfParam
    selfKnown.value = true
    trackEvent({
      name: 'compatibility_chronotype_selected',
      data: { position: 'self', chronotype: selfParam },
    })
  }

  trackEvent({
    name: 'compatibility_tool_opened',
    data: { source: selfParam ? 'prefilled' : 'direct' },
  })
})

// Show Step 2 when self is chosen
const showStep2 = computed(() => selfType.value !== null)

// Show Step 3 (result) when both are chosen
const showResult = computed(() => selfType.value !== null && partnerType.value !== null)

// Pairing key for analytics
const pairingKey = computed(() =>
  selfType.value && partnerType.value ? `${selfType.value}_${partnerType.value}` : ''
)

// Handlers
function handleSelfKnown() {
  selfKnown.value = true
}

function handlePartnerKnown() {
  partnerKnown.value = true
}

function handleSelfSelect(value: string) {
  selfType.value = value
  trackEvent({
    name: 'compatibility_chronotype_selected',
    data: { position: 'self', chronotype: value },
  })
}

function handlePartnerSelect(value: string) {
  partnerType.value = value
  trackEvent({
    name: 'compatibility_chronotype_selected',
    data: { position: 'partner', chronotype: value },
  })
}

// Track card generation
watch(showResult, (visible) => {
  if (visible) {
    trackEvent({
      name: 'compatibility_card_generated',
      data: { pairing: pairingKey.value },
    })
  }
})

function handleShared() {
  // Additional tracking if needed
}

function handleInviteSent() {
  // Additional tracking if needed
}

function handlePartnerModeInterest() {
  // Additional tracking if needed
}

// Partner invite link for "they can take the quiz" option
const partnerQuizLink = computed(() => {
  if (!selfType.value) return '/quiz?entry=compatibility'
  const params = new URLSearchParams({
    entry: 'compatibility',
    referrer_type: selfType.value,
  })
  if (referralCode.value) {
    params.set('partner_ref', referralCode.value)
  }
  return `/quiz?${params.toString()}`
})

const partnerQuizFullLink = computed(() => `https://sleeppath.app${partnerQuizLink.value}`)
const partnerLinkCopied = ref(false)

async function copyPartnerQuizLink() {
  try {
    await navigator.clipboard.writeText(partnerQuizFullLink.value)
    partnerLinkCopied.value = true
    trackEvent({
      name: 'partner_invite_sent',
      data: { method: 'copy' },
    })
    setTimeout(() => { partnerLinkCopied.value = false }, 2500)
  } catch {
    // Fallback
  }
}
</script>

<template>
  <div class="min-h-screen bg-slate-950">
    <!-- Hero -->
    <section class="relative overflow-hidden pt-16 pb-12 sm:pt-24 sm:pb-16">
      <!-- Background glow -->
      <div class="absolute top-0 left-1/2 -translate-x-1/2 w-[600px] h-[400px] rounded-full bg-indigo-500/8 blur-3xl pointer-events-none" />

      <div class="relative z-10 max-w-2xl mx-auto px-6 text-center">
        <div class="inline-flex items-center gap-2 rounded-full border border-white/10 bg-white/5 px-4 py-1.5 mb-6">
          <svg class="w-4 h-4 text-indigo-400" fill="currentColor" viewBox="0 0 24 24">
            <path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z" />
          </svg>
          <span class="text-xs font-medium text-slate-300 tracking-wide">Sleep Compatibility</span>
        </div>

        <h1 class="text-3xl sm:text-4xl md:text-5xl font-light text-white tracking-tight leading-tight mb-4">
          How do your sleep<br class="hidden sm:block" />
          rhythms <span class="text-indigo-400">align?</span>
        </h1>

        <p class="text-base sm:text-lg text-slate-400 font-light leading-relaxed max-w-lg mx-auto">
          Compare chronotypes with your partner, roommate, or anyone you share
          time with. See where your energy overlaps — and where it doesn't.
        </p>
      </div>
    </section>

    <!-- Steps container -->
    <section class="max-w-2xl mx-auto px-6 pb-16 sm:pb-24 space-y-12">

      <!-- STEP 1: Your chronotype -->
      <div class="relative">
        <!-- Step indicator -->
        <div class="flex items-center gap-3 mb-6">
          <div class="flex h-8 w-8 items-center justify-center rounded-full bg-indigo-500/20 text-sm font-semibold text-indigo-400">
            1
          </div>
          <h2 class="text-xl font-semibold text-white tracking-tight">
            What's your chronotype?
          </h2>
        </div>

        <!-- Options (before selection) -->
        <div
          v-if="!selfKnown && !selfType"
          class="space-y-3"
        >
          <NuxtLink
            to="/quiz?entry=compatibility"
            class="group flex items-center justify-between rounded-2xl border border-white/10 bg-white/[0.03] px-5 py-4 transition-all duration-300 hover:bg-white/[0.06] hover:border-white/20"
          >
            <div class="flex items-center gap-3">
              <div class="flex h-10 w-10 items-center justify-center rounded-xl bg-indigo-500/15">
                <svg class="w-5 h-5 text-indigo-400" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M12 6v6h4.5m4.5 0a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
              </div>
              <div>
                <p class="text-sm font-medium text-white">Take the 60-sec quiz</p>
                <p class="text-xs text-slate-500">Don't know your type yet? Start here.</p>
              </div>
            </div>
            <svg class="w-4 h-4 text-slate-600 transition-transform duration-300 group-hover:translate-x-1 group-hover:text-slate-400" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
              <path stroke-linecap="round" stroke-linejoin="round" d="M9 5l7 7-7 7" />
            </svg>
          </NuxtLink>

          <button
            class="group flex w-full items-center justify-between rounded-2xl border border-white/10 bg-white/[0.03] px-5 py-4 transition-all duration-300 hover:bg-white/[0.06] hover:border-white/20 text-left"
            @click="handleSelfKnown"
          >
            <div class="flex items-center gap-3">
              <div class="flex h-10 w-10 items-center justify-center rounded-xl bg-violet-500/15">
                <svg class="w-5 h-5 text-violet-400" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M9 12.75L11.25 15 15 9.75M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
              </div>
              <div>
                <p class="text-sm font-medium text-white">I already know mine</p>
                <p class="text-xs text-slate-500">Pick your chronotype directly.</p>
              </div>
            </div>
            <svg class="w-4 h-4 text-slate-600 transition-transform duration-300 group-hover:translate-x-1 group-hover:text-slate-400" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
              <path stroke-linecap="round" stroke-linejoin="round" d="M9 5l7 7-7 7" />
            </svg>
          </button>
        </div>

        <!-- Chronotype picker (revealed) -->
        <Transition name="fade-slide">
          <div v-if="selfKnown || selfType">
            <CompatibilityChronotypePicker
              label="Your chronotype"
              :model-value="selfType"
              @update:model-value="handleSelfSelect"
            />
          </div>
        </Transition>
      </div>

      <!-- STEP 2: Their chronotype -->
      <Transition name="fade-slide">
        <div v-if="showStep2" class="relative">
          <!-- Step indicator -->
          <div class="flex items-center gap-3 mb-6">
            <div class="flex h-8 w-8 items-center justify-center rounded-full bg-indigo-500/20 text-sm font-semibold text-indigo-400">
              2
            </div>
            <h2 class="text-xl font-semibold text-white tracking-tight">
              What's their chronotype?
            </h2>
          </div>

          <!-- Options (before selection) -->
          <div
            v-if="!partnerKnown && !partnerType"
            class="space-y-3"
          >
            <!-- They can take the quiz -->
            <div class="group rounded-2xl border border-white/10 bg-white/[0.03] px-5 py-4 transition-all duration-300 hover:bg-white/[0.06] hover:border-white/20">
              <div class="flex items-center justify-between">
                <div class="flex items-center gap-3">
                  <div class="flex h-10 w-10 items-center justify-center rounded-xl bg-emerald-500/15">
                    <svg class="w-5 h-5 text-emerald-400" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                      <path stroke-linecap="round" stroke-linejoin="round" d="M7.217 10.907a2.25 2.25 0 100 2.186m0-2.186c.18.324.283.696.283 1.093s-.103.77-.283 1.093m0-2.186l9.566-5.314m-9.566 7.5l9.566 5.314m0 0a2.25 2.25 0 103.935 2.186 2.25 2.25 0 00-3.935-2.186zm0-12.814a2.25 2.25 0 103.933-2.185 2.25 2.25 0 00-3.933 2.185z" />
                    </svg>
                  </div>
                  <div>
                    <p class="text-sm font-medium text-white">They can take the quiz too</p>
                    <p class="text-xs text-slate-500">Send them a link to find their type.</p>
                  </div>
                </div>
                <button
                  class="inline-flex items-center gap-1.5 h-8 px-3.5 rounded-full border border-white/10 bg-white/5 text-xs font-medium text-slate-300 transition-all duration-200 hover:bg-white/10 active:scale-[0.97]"
                  @click="copyPartnerQuizLink"
                >
                  <svg v-if="!partnerLinkCopied" class="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z" />
                  </svg>
                  <svg v-else class="w-3.5 h-3.5 text-emerald-400" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7" />
                  </svg>
                  {{ partnerLinkCopied ? 'Copied!' : 'Copy Link' }}
                </button>
              </div>
            </div>

            <button
              class="group flex w-full items-center justify-between rounded-2xl border border-white/10 bg-white/[0.03] px-5 py-4 transition-all duration-300 hover:bg-white/[0.06] hover:border-white/20 text-left"
              @click="handlePartnerKnown"
            >
              <div class="flex items-center gap-3">
                <div class="flex h-10 w-10 items-center justify-center rounded-xl bg-violet-500/15">
                  <svg class="w-5 h-5 text-violet-400" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M9 12.75L11.25 15 15 9.75M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                  </svg>
                </div>
                <div>
                  <p class="text-sm font-medium text-white">I know theirs too</p>
                  <p class="text-xs text-slate-500">Pick their chronotype directly.</p>
                </div>
              </div>
              <svg class="w-4 h-4 text-slate-600 transition-transform duration-300 group-hover:translate-x-1 group-hover:text-slate-400" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                <path stroke-linecap="round" stroke-linejoin="round" d="M9 5l7 7-7 7" />
              </svg>
            </button>
          </div>

          <!-- Chronotype picker (revealed) -->
          <Transition name="fade-slide">
            <div v-if="partnerKnown || partnerType">
              <CompatibilityChronotypePicker
                label="Their chronotype"
                :model-value="partnerType"
                @update:model-value="handlePartnerSelect"
              />
            </div>
          </Transition>
        </div>
      </Transition>

      <!-- STEP 3: Result -->
      <Transition name="fade-slide">
        <div v-if="showResult" class="space-y-10 pt-4">
          <!-- Divider -->
          <div class="flex items-center gap-4">
            <div class="flex-1 h-px bg-gradient-to-r from-transparent to-white/10" />
            <span class="text-xs font-medium text-slate-500 uppercase tracking-wider">Your Result</span>
            <div class="flex-1 h-px bg-gradient-to-l from-transparent to-white/10" />
          </div>

          <!-- Compatibility Card -->
          <CompatibilityCompatibilityCard
            :self-type="selfType!"
            :partner-type="partnerType!"
          />

          <!-- Share section -->
          <CompatibilityCompatibilityShare
            :self-type="selfType!"
            :partner-type="partnerType!"
            :referral-code="referralCode"
            @shared="handleShared"
            @invite-sent="handleInviteSent"
            @partner-mode-interest="handlePartnerModeInterest"
          />
        </div>
      </Transition>
    </section>

    <!-- Below the fold: Don't know their chronotype? -->
    <section v-if="!showResult" class="border-t border-white/5 bg-white/[0.02] py-16 sm:py-20">
      <div class="max-w-2xl mx-auto px-6 text-center">
        <!-- Decorative -->
        <div class="flex items-center justify-center gap-3 mb-6">
          <span class="text-3xl">🦁</span>
          <svg class="w-5 h-5 text-slate-600" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
            <path stroke-linecap="round" stroke-linejoin="round" d="M7.5 21L3 16.5m0 0L7.5 12M3 16.5h13.5m0-13.5L21 7.5m0 0L16.5 12M21 7.5H7.5" />
          </svg>
          <span class="text-3xl">🐺</span>
        </div>

        <h2 class="text-2xl sm:text-3xl font-light text-white tracking-tight mb-3">
          Don't know their chronotype yet?
        </h2>
        <p class="text-slate-400 font-light text-base leading-relaxed max-w-md mx-auto mb-8">
          Send them the 60-second quiz. Once they finish, come back here
          and compare your results side by side.
        </p>

        <div class="flex flex-col sm:flex-row items-center justify-center gap-3">
          <NuxtLink
            to="/quiz?entry=compatibility"
            class="inline-flex items-center justify-center h-11 px-6 text-sm font-medium text-white bg-indigo-600 rounded-full transition-all duration-200 hover:bg-indigo-700 hover:shadow-lg hover:shadow-indigo-500/20 active:scale-[0.98]"
          >
            Take the quiz yourself
          </NuxtLink>

          <button
            class="inline-flex items-center justify-center h-11 px-6 text-sm font-medium text-slate-300 border border-white/10 rounded-full transition-all duration-200 hover:bg-white/5 hover:border-white/20 active:scale-[0.98]"
            @click="copyPartnerQuizLink"
          >
            {{ partnerLinkCopied ? 'Link copied!' : 'Copy quiz link for them' }}
          </button>
        </div>
      </div>
    </section>

    <!-- Footer -->
    <LandingSiteFooter />
  </div>
</template>

<style scoped>
.fade-slide-enter-active {
  transition: all 0.4s ease-out;
}
.fade-slide-leave-active {
  transition: all 0.25s ease-in;
}
.fade-slide-enter-from {
  opacity: 0;
  transform: translateY(16px);
}
.fade-slide-leave-to {
  opacity: 0;
  transform: translateY(-8px);
}
</style>
