<script setup lang="ts">
import { trackEvent } from '@/lib/analytics'

const router = useRouter()

function handleStartQuiz() {
  trackEvent({ name: 'quiz_start', data: { source: 'landing' } })
  router.push('/quiz')
}

function handleCompatibilityClick() {
  trackEvent({ name: 'compatibility_tool_opened', data: { source: 'landing_teaser' } })
}
</script>

<template>
  <div class="min-h-screen bg-slate-950">
    <LandingHeroSection @start-quiz="handleStartQuiz" />
    <LandingSocialProof />
    <LandingHowItWorks />
    <LandingChronotypePreview />
    <LandingFaqSection />
    <LandingCompatibilityTeaser @compatibility-click="handleCompatibilityClick" />
    <LandingFooterCta @start-quiz="handleStartQuiz" />
    <LandingSiteFooter />
  </div>
</template>
