<script setup lang="ts">
interface FaqItem {
  question: string
  answer: string
}

const faqs: FaqItem[] = [
  {
    question: 'What is a chronotype?',
    answer: 'A chronotype is your body\'s natural inclination for when to sleep and when to be active. It\'s determined by your genetics and influences everything from when you feel most alert to when your body temperature peaks. Unlike being a "morning person" or "night owl," chronotypes describe four distinct biological patterns: Lion, Bear, Wolf, and Dolphin.',
  },
  {
    question: 'Is the quiz accurate?',
    answer: 'Our quiz is based on the research of Dr. Michael Breus and established chronobiology science. While a clinical assessment considers additional biomarkers, our 8-question quiz reliably identifies your dominant chronotype pattern. Most people find their result immediately resonates with their lived experience.',
  },
  {
    question: 'Is it really free?',
    answer: 'Yes, completely free. No credit card, no hidden fees, no catch. You\'ll get your full chronotype result and personalized schedule at no cost. We believe everyone deserves to understand their biology.',
  },
  {
    question: 'How long does it take?',
    answer: 'About 60 seconds. The quiz has 8 straightforward questions about your natural tendencies — when you\'d wake up without an alarm, when you feel sharpest, that sort of thing. No overthinking required.',
  },
  {
    question: 'Will you sell my data?',
    answer: 'No. We don\'t collect personal information during the quiz — no email required, no account needed. Your quiz answers are processed in your browser and are not stored on our servers.',
  },
]

const openIndex = ref<number | null>(null)

function toggle(index: number) {
  openIndex.value = openIndex.value === index ? null : index
}
</script>

<template>
  <section class="bg-slate-950 py-24 sm:py-32">
    <div class="max-w-2xl mx-auto px-6">
      <!-- Section headline -->
      <div class="text-center mb-16">
        <h2 class="text-3xl sm:text-4xl font-light text-white tracking-tight">
          Questions & Answers
        </h2>
      </div>

      <!-- FAQ items -->
      <div class="space-y-2">
        <div
          v-for="(faq, index) in faqs"
          :key="index"
          class="border border-white/5 rounded-xl overflow-hidden transition-colors duration-200"
          :class="openIndex === index ? 'bg-white/[0.03]' : 'bg-transparent'"
        >
          <button
            class="w-full flex items-center justify-between px-6 py-5 text-left transition-colors duration-200 hover:bg-white/[0.02]"
            @click="toggle(index)"
          >
            <span class="text-white font-medium pr-4">{{ faq.question }}</span>
            <svg
              class="w-5 h-5 text-slate-500 shrink-0 transition-transform duration-300"
              :class="openIndex === index ? 'rotate-180' : ''"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
              stroke-width="1.5"
            >
              <path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7" />
            </svg>
          </button>

          <div
            class="overflow-hidden transition-all duration-300"
            :class="openIndex === index ? 'max-h-64 opacity-100' : 'max-h-0 opacity-0'"
          >
            <p class="px-6 pb-5 text-slate-400 font-light leading-relaxed">
              {{ faq.answer }}
            </p>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>
