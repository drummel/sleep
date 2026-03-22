<script setup lang="ts">
import { getChronotype, type ChronotypeId } from '@/lib/chronotypes'
import { getShareLinks, trackEvent } from '@/lib/analytics'

const props = defineProps<{
  chronotype: string
  referralCode: string | null
}>()

const info = computed(() => getChronotype(props.chronotype as ChronotypeId))
const copied = ref(false)

const shareLinks = computed(() => {
  const code = props.referralCode ?? ''
  const shareText = `I'm a ${info.value.emoji} ${info.value.name} — ${info.value.tagline.toLowerCase()}. Discover your sleep chronotype!`
  const shareUrl = code
    ? `https://sleeppath.app?ref=${code}`
    : 'https://sleeppath.app'
  return getShareLinks(code, { text: shareText, url: shareUrl })
})

function shareTwitter() {
  trackEvent({
    name: 'share_card_click',
    data: { platform: 'twitter', chronotype: props.chronotype, card_type: 'result' },
  })
  window.open(shareLinks.value.twitter, '_blank', 'noopener')
}

async function copyLink() {
  try {
    await navigator.clipboard.writeText(shareLinks.value.copy)
    copied.value = true
    trackEvent({
      name: 'share_card_click',
      data: { platform: 'copy', chronotype: props.chronotype, card_type: 'result' },
    })
    setTimeout(() => { copied.value = false }, 2500)
  } catch {
    // Fallback: select text for manual copy
  }
}
</script>

<template>
  <section class="py-12 sm:py-16">
    <div class="max-w-lg mx-auto px-6">
      <!-- Share card (screenshot-worthy) -->
      <div
        class="relative overflow-hidden rounded-2xl border bg-white shadow-lg"
        :class="info.borderColor"
      >
        <!-- Color accent bar at top -->
        <div
          class="h-1.5"
          :class="[
            chronotype === 'lion' ? 'bg-amber-500' : '',
            chronotype === 'bear' ? 'bg-orange-500' : '',
            chronotype === 'wolf' ? 'bg-violet-500' : '',
            chronotype === 'dolphin' ? 'bg-sky-500' : '',
          ]"
        />

        <div class="p-8 sm:p-10 text-center">
          <!-- Emoji -->
          <span class="text-5xl sm:text-6xl block mb-4">{{ info.emoji }}</span>

          <!-- Name & tagline -->
          <h3 class="text-2xl sm:text-3xl font-bold text-slate-900 mb-1">
            {{ info.name }}
          </h3>
          <p class="text-sm font-medium text-slate-500 mb-6">
            {{ info.tagline }}
          </p>

          <!-- Sleep window highlight -->
          <div
            class="inline-flex items-center gap-2 rounded-full px-4 py-2 text-sm font-medium"
            :class="[info.bgColor, info.color]"
          >
            <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
              <path stroke-linecap="round" stroke-linejoin="round" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            {{ info.sleepWindow }}
          </div>

          <!-- Branding footer -->
          <div class="mt-8 pt-5 border-t border-slate-100">
            <p class="text-xs font-medium tracking-wider text-slate-400 uppercase">
              sleeppath.app
            </p>
          </div>
        </div>
      </div>

      <!-- Share buttons -->
      <div class="flex items-center justify-center gap-3 mt-6">
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
          class="inline-flex items-center gap-2 h-10 px-5 rounded-full border border-border bg-card text-sm font-medium text-foreground transition-all duration-200 hover:bg-secondary hover:shadow-sm active:scale-[0.98]"
          @click="copyLink"
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
    </div>
  </section>
</template>
