<script setup lang="ts">
import { getShareLinks, trackEvent } from '@/lib/analytics'

const props = defineProps<{
  referralCode: string | null
}>()

const copied = ref(false)

const referralUrl = computed(() => {
  if (!props.referralCode) return 'https://sleeppath.app'
  return `https://sleeppath.app?ref=${props.referralCode}`
})

const shareLinks = computed(() => {
  const code = props.referralCode ?? ''
  const shareText = 'I just discovered my sleep chronotype with SleepPath. Take the free quiz and find yours!'
  return getShareLinks(code, { text: shareText, url: referralUrl.value })
})

async function copyReferralLink() {
  try {
    await navigator.clipboard.writeText(referralUrl.value)
    copied.value = true
    trackEvent({
      name: 'referral_share',
      data: { method: 'copy' },
    })
    setTimeout(() => { copied.value = false }, 2500)
  } catch {
    // Fallback: silent fail
  }
}

function shareTwitter() {
  trackEvent({
    name: 'referral_share',
    data: { method: 'twitter' },
  })
  window.open(shareLinks.value.twitter, '_blank', 'noopener')
}
</script>

<template>
  <section class="py-12 sm:py-16">
    <div class="max-w-lg mx-auto px-6">
      <div class="rounded-2xl border border-border bg-card p-8 sm:p-10 text-center">
        <div class="inline-flex items-center justify-center w-12 h-12 rounded-full bg-primary/10 mb-5">
          <svg class="w-6 h-6 text-primary" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
            <path stroke-linecap="round" stroke-linejoin="round" d="M7.217 10.907a2.25 2.25 0 100 2.186m0-2.186c.18.324.283.696.283 1.093s-.103.77-.283 1.093m0-2.186l9.566-5.314m-9.566 7.5l9.566 5.314m0 0a2.25 2.25 0 103.935 2.186 2.25 2.25 0 00-3.935-2.186zm0-12.814a2.25 2.25 0 103.933-2.185 2.25 2.25 0 00-3.933 2.185z" />
          </svg>
        </div>

        <h3 class="text-xl sm:text-2xl font-semibold text-foreground mb-2">
          Share SleepPath with friends
        </h3>
        <p class="text-sm text-muted-foreground mb-8 leading-relaxed">
          Know someone who could use a better sleep schedule? Send them the quiz.
        </p>

        <!-- Referral link display -->
        <div
          v-if="referralCode"
          class="flex items-center gap-2 rounded-xl border border-border bg-secondary/50 p-3 mb-6"
        >
          <span class="flex-1 truncate text-sm text-muted-foreground font-mono text-left pl-1">
            {{ referralUrl }}
          </span>
          <button
            class="flex-shrink-0 inline-flex items-center gap-1.5 h-8 px-3.5 rounded-lg bg-card border border-border text-xs font-medium text-foreground transition-all duration-200 hover:bg-secondary active:scale-[0.97]"
            @click="copyReferralLink"
          >
            <svg v-if="!copied" class="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
              <path stroke-linecap="round" stroke-linejoin="round" d="M15.666 3.888A2.25 2.25 0 0013.5 2.25h-3c-1.03 0-1.9.693-2.166 1.638m7.332 0c.055.194.084.4.084.612v0a.75.75 0 01-.75.75H9.75a.75.75 0 01-.75-.75v0c0-.212.03-.418.084-.612m7.332 0c.646.049 1.288.11 1.927.184 1.1.128 1.907 1.077 1.907 2.185V19.5a2.25 2.25 0 01-2.25 2.25H6.75A2.25 2.25 0 014.5 19.5V6.257c0-1.108.806-2.057 1.907-2.185a48.208 48.208 0 011.927-.184" />
            </svg>
            <svg v-else class="w-3.5 h-3.5 text-emerald-500" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
              <path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7" />
            </svg>
            {{ copied ? 'Copied!' : 'Copy' }}
          </button>
        </div>

        <!-- Share buttons -->
        <div class="flex items-center justify-center gap-3">
          <button
            class="inline-flex items-center gap-2 h-10 px-5 rounded-full border border-border bg-card text-sm font-medium text-foreground transition-all duration-200 hover:bg-secondary hover:shadow-sm active:scale-[0.98]"
            @click="shareTwitter"
          >
            <svg class="w-4 h-4" viewBox="0 0 24 24" fill="currentColor">
              <path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z" />
            </svg>
            Share on X
          </button>

          <button
            v-if="!referralCode"
            class="inline-flex items-center gap-2 h-10 px-5 rounded-full border border-border bg-card text-sm font-medium text-foreground transition-all duration-200 hover:bg-secondary hover:shadow-sm active:scale-[0.98]"
            @click="copyReferralLink"
          >
            <svg v-if="!copied" class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
              <path stroke-linecap="round" stroke-linejoin="round" d="M13.19 8.688a4.5 4.5 0 011.242 7.244l-4.5 4.5a4.5 4.5 0 01-6.364-6.364l1.757-1.757m9.86-2.54a4.5 4.5 0 00-1.242-7.244l-4.5-4.5a4.5 4.5 0 00-6.364 6.364L4.34 8.374" />
            </svg>
            <svg v-else class="w-4 h-4 text-emerald-500" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
              <path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7" />
            </svg>
            {{ copied ? 'Copied!' : 'Copy Link' }}
          </button>
        </div>

        <!-- Referral stats placeholder -->
        <div
          v-if="referralCode"
          class="mt-8 pt-6 border-t border-border"
        >
          <div class="grid grid-cols-2 gap-4">
            <div>
              <div class="text-2xl font-bold text-foreground">0</div>
              <div class="text-xs text-muted-foreground/70 mt-0.5">Friends joined</div>
            </div>
            <div>
              <div class="text-2xl font-bold text-foreground">0</div>
              <div class="text-xs text-muted-foreground/70 mt-0.5">Link clicks</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>
