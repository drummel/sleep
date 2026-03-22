import { ref } from 'vue'
import { joinWaitlist, trackEvent } from '@/lib/analytics'

const email = ref('')
const isSubmitted = ref(false)
const isLoading = ref(false)
const referralCode = ref<string | null>(null)
const error = ref<string | null>(null)

export function useEmail() {
  async function submitEmail(chronotype: string, track: string = 'solo') {
    if (!email.value || !email.value.includes('@')) {
      error.value = 'Please enter a valid email address'
      return false
    }

    isLoading.value = true
    error.value = null

    try {
      const result = await joinWaitlist({
        email: email.value,
        waitlist_id: 'wl_solo',
        metadata: { chronotype, track },
      })

      referralCode.value = result.referral_code
      isSubmitted.value = true

      trackEvent({
        name: 'email_signup',
        data: { chronotype, track },
      })

      return true
    } catch {
      error.value = 'Something went wrong. Please try again.'
      return false
    } finally {
      isLoading.value = false
    }
  }

  async function submitPartnerModeEmail(pairing: string) {
    if (!email.value || !email.value.includes('@')) {
      error.value = 'Please enter a valid email address'
      return false
    }

    isLoading.value = true
    error.value = null

    try {
      await joinWaitlist({
        email: email.value,
        waitlist_id: 'wl_partner_mode',
        metadata: { pairing, source: 'compatibility_tool' },
      })

      isSubmitted.value = true

      trackEvent({
        name: 'partner_mode_interest',
        data: { pairing },
      })

      return true
    } catch {
      error.value = 'Something went wrong. Please try again.'
      return false
    } finally {
      isLoading.value = false
    }
  }

  function resetEmail() {
    email.value = ''
    isSubmitted.value = false
    isLoading.value = false
    referralCode.value = null
    error.value = null
  }

  return {
    email,
    isSubmitted,
    isLoading,
    referralCode,
    error,
    submitEmail,
    submitPartnerModeEmail,
    resetEmail,
  }
}
