<script setup lang="ts">
import { getChronotype } from '@/lib/chronotypes'
import { getPairing } from '@/lib/compatibility'
import { trackEvent, getShareLinks } from '@/lib/analytics'
import { useEmail } from '@/composables/useEmail'
import type { ChronotypeId } from '@/lib/chronotypes'

const props = defineProps<{
  selfType: string
  partnerType: string
  referralCode: string | null
}>()

const emit = defineEmits<{
  shared: []
  'invite-sent': []
  'partner-mode-interest': []
}>()

const self = computed(() => getChronotype(props.selfType as ChronotypeId))
const partner = computed(() => getChronotype(props.partnerType as ChronotypeId))
const pairing = computed(() => getPairing(props.selfType as ChronotypeId, props.partnerType as ChronotypeId))
const pairingKey = computed(() => `${props.selfType}_${props.partnerType}`)

const copied = ref(false)
const inviteCopied = ref(false)

const { email, isSubmitted, isLoading, error, submitPartnerModeEmail } = useEmail()

// Share links
const shareText = computed(() =>
  `We're "${pairing.value.name}" ${self.value.emoji}+${partner.value.emoji} — our best overlap is ${pairing.value.bestWindow}. Find your sleep compatibility!`
)

const shareUrl = computed(() => {
  const base = 'https://sleeppath.app/compatibility'
  return props.referralCode ? `${base}?ref=${props.referralCode}` : base
})

const links = computed(() =>
  getShareLinks(props.referralCode ?? '', { text: shareText.value, url: shareUrl.value })
)

// Partner invite link
const inviteLink = computed(() => {
  const base = 'https://sleeppath.app/quiz'
  const params = new URLSearchParams({
    entry: 'compatibility',
    partner_ref: props.referralCode ?? 'direct',
    referrer_type: props.selfType,
  })
  return `${base}?${params.toString()}`
})

const whatsappInviteMessage = computed(() => {
  const text = `Hey! I just found out I'm a ${self.value.emoji} ${self.value.name} (${self.value.tagline.toLowerCase()}). Take this 60-second quiz so we can see our sleep compatibility!`
  return `https://wa.me/?text=${encodeURIComponent(text + ' ' + inviteLink.value)}`
})

// Share actions
function shareInstagram() {
  trackEvent({
    name: 'compatibility_card_shared',
    data: { platform: 'instagram', pairing: pairingKey.value },
  })
  // Instagram doesn't support direct URL sharing; prompt screenshot
  alert('Screenshot the compatibility card above and share it to your Instagram Story!')
  emit('shared')
}

function shareWhatsApp() {
  trackEvent({
    name: 'compatibility_card_shared',
    data: { platform: 'whatsapp', pairing: pairingKey.value },
  })
  window.open(links.value.whatsapp, '_blank', 'noopener')
  emit('shared')
}

async function copyShareLink() {
  try {
    await navigator.clipboard.writeText(links.value.copy)
    copied.value = true
    trackEvent({
      name: 'compatibility_card_shared',
      data: { platform: 'copy', pairing: pairingKey.value },
    })
    emit('shared')
    setTimeout(() => { copied.value = false }, 2500)
  } catch {
    // Fallback
  }
}

// Partner invite actions
function sendWhatsAppInvite() {
  trackEvent({
    name: 'partner_invite_sent',
    data: { method: 'whatsapp' },
  })
  window.open(whatsappInviteMessage.value, '_blank', 'noopener')
  emit('invite-sent')
}

async function copyInviteLink() {
  try {
    await navigator.clipboard.writeText(inviteLink.value)
    inviteCopied.value = true
    trackEvent({
      name: 'partner_invite_sent',
      data: { method: 'copy' },
    })
    emit('invite-sent')
    setTimeout(() => { inviteCopied.value = false }, 2500)
  } catch {
    // Fallback
  }
}

// Partner mode email
async function handlePartnerModeSubmit() {
  const success = await submitPartnerModeEmail(pairingKey.value)
  if (success) {
    emit('partner-mode-interest')
  }
}
</script>

<template>
  <div class="space-y-10">
    <!-- Share buttons -->
    <div class="text-center">
      <h3 class="text-lg font-semibold text-foreground mb-1">
        Share your result
      </h3>
      <p class="text-sm text-muted-foreground mb-5">
        Screenshot-worthy and ready to send.
      </p>

      <div class="flex items-center justify-center gap-3 flex-wrap">
        <!-- Instagram -->
        <button
          class="inline-flex items-center gap-2 h-10 px-5 rounded-full border border-border bg-card text-sm font-medium text-foreground transition-all duration-200 hover:bg-secondary hover:shadow-sm active:scale-[0.98]"
          @click="shareInstagram"
        >
          <svg class="w-4 h-4" viewBox="0 0 24 24" fill="currentColor">
            <path d="M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069zM12 0C8.741 0 8.333.014 7.053.072 2.695.272.273 2.69.073 7.052.014 8.333 0 8.741 0 12c0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98C8.333 23.986 8.741 24 12 24c3.259 0 3.668-.014 4.948-.072 4.354-.2 6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98C15.668.014 15.259 0 12 0zm0 5.838a6.162 6.162 0 100 12.324 6.162 6.162 0 000-12.324zM12 16a4 4 0 110-8 4 4 0 010 8zm6.406-11.845a1.44 1.44 0 100 2.881 1.44 1.44 0 000-2.881z" />
          </svg>
          Instagram
        </button>

        <!-- WhatsApp -->
        <button
          class="inline-flex items-center gap-2 h-10 px-5 rounded-full border border-border bg-card text-sm font-medium text-foreground transition-all duration-200 hover:bg-secondary hover:shadow-sm active:scale-[0.98]"
          @click="shareWhatsApp"
        >
          <svg class="w-4 h-4" viewBox="0 0 24 24" fill="currentColor">
            <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z" />
          </svg>
          WhatsApp
        </button>

        <!-- Copy Link -->
        <button
          class="inline-flex items-center gap-2 h-10 px-5 rounded-full border border-border bg-card text-sm font-medium text-foreground transition-all duration-200 hover:bg-secondary hover:shadow-sm active:scale-[0.98]"
          @click="copyShareLink"
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

    <!-- Divider -->
    <div class="h-px bg-gradient-to-r from-transparent via-border to-transparent" />

    <!-- Send them the quiz -->
    <div class="text-center">
      <h3 class="text-lg font-semibold text-foreground mb-1">
        Send them the quiz
      </h3>
      <p class="text-sm text-muted-foreground mb-5">
        Get their real result and unlock a more accurate compatibility card.
      </p>

      <div class="flex items-center justify-center gap-3 flex-wrap">
        <!-- WhatsApp invite -->
        <button
          class="inline-flex items-center gap-2 h-10 px-5 rounded-full bg-emerald-600 text-sm font-medium text-white transition-all duration-200 hover:bg-emerald-700 hover:shadow-md active:scale-[0.98]"
          @click="sendWhatsAppInvite"
        >
          <svg class="w-4 h-4" viewBox="0 0 24 24" fill="currentColor">
            <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z" />
          </svg>
          Send via WhatsApp
        </button>

        <!-- Copy invite link -->
        <button
          class="inline-flex items-center gap-2 h-10 px-5 rounded-full border border-border bg-card text-sm font-medium text-foreground transition-all duration-200 hover:bg-secondary hover:shadow-sm active:scale-[0.98]"
          @click="copyInviteLink"
        >
          <svg v-if="!inviteCopied" class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round" d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z" />
          </svg>
          <svg v-else class="w-4 h-4 text-emerald-500" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7" />
          </svg>
          {{ inviteCopied ? 'Copied!' : 'Copy Quiz Link' }}
        </button>
      </div>
    </div>

    <!-- Divider -->
    <div class="h-px bg-gradient-to-r from-transparent via-border to-transparent" />

    <!-- Partner Mode interest -->
    <div class="text-center">
      <div class="inline-flex items-center gap-2 rounded-full bg-violet-500/10 px-4 py-1.5 mb-4">
        <div class="h-1.5 w-1.5 rounded-full bg-violet-400 animate-pulse" />
        <span class="text-xs font-medium text-violet-400 tracking-wide">Coming Soon</span>
      </div>

      <h3 class="text-lg font-semibold text-foreground mb-1">
        Partner Mode
      </h3>
      <p class="text-sm text-muted-foreground mb-6 max-w-sm mx-auto">
        Shared schedules, wind-down nudges, and overlap alerts built for two. Get notified when it launches.
      </p>

      <!-- Success state -->
      <div
        v-if="isSubmitted"
        class="animate-fade-in-up"
      >
        <div class="inline-flex items-center justify-center w-12 h-12 rounded-full bg-emerald-50 mb-3">
          <svg class="w-6 h-6 text-emerald-500" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
            <path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7" />
          </svg>
        </div>
        <p class="text-sm font-medium text-foreground">
          You're on the list! We'll let you know.
        </p>
      </div>

      <!-- Email form -->
      <form
        v-else
        class="flex flex-col sm:flex-row gap-3 max-w-md mx-auto"
        @submit.prevent="handlePartnerModeSubmit"
      >
        <div class="relative flex-1">
          <input
            v-model="email"
            type="email"
            required
            placeholder="you@example.com"
            autocomplete="email"
            class="w-full h-11 px-4 rounded-xl border border-border bg-card text-foreground text-sm placeholder:text-muted-foreground/60 focus:outline-none focus:ring-2 focus:ring-violet-500/30 focus:border-violet-500 transition-all duration-200"
            :class="{ 'border-destructive focus:ring-destructive/30': error }"
          />
        </div>

        <button
          type="submit"
          :disabled="isLoading"
          class="h-11 px-5 rounded-xl bg-violet-600 text-white text-sm font-medium transition-all duration-200 hover:bg-violet-700 hover:shadow-md hover:shadow-violet-500/20 active:scale-[0.98] disabled:opacity-50 disabled:cursor-not-allowed whitespace-nowrap"
        >
          <span v-if="isLoading" class="inline-flex items-center gap-2">
            <svg class="w-4 h-4 animate-spin" viewBox="0 0 24 24" fill="none">
              <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" />
              <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
            </svg>
            Saving...
          </span>
          <span v-else>Notify Me</span>
        </button>
      </form>

      <p
        v-if="error && !isSubmitted"
        class="mt-3 text-sm text-destructive animate-fade-in"
      >
        {{ error }}
      </p>
    </div>
  </div>
</template>
