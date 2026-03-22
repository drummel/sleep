import tailwindcss from '@tailwindcss/vite'

export default defineNuxtConfig({
  future: { compatibilityVersion: 4 },
  app: {
    head: {
      title: 'SleepPath — Discover Your Chronotype',
      meta: [
        { charset: 'utf-8' },
        { name: 'viewport', content: 'width=device-width, initial-scale=1' },
        { name: 'description', content: 'Take the free 60-second chronotype quiz. Discover if you\'re a Lion, Bear, Wolf, or Dolphin — and unlock the daily schedule your biology actually wants.' },
        { property: 'og:title', content: 'SleepPath — What\'s Your Chronotype?' },
        { property: 'og:description', content: 'Take the free 60-second quiz and discover your biological schedule.' },
        { property: 'og:type', content: 'website' },
      ],
      link: [
        { rel: 'icon', type: 'image/svg+xml', href: '/favicon.svg' },
      ],
    },
  },
  modules: [
    'shadcn-nuxt',
    ...(process.env.NODE_ENV === 'test' ? ['@nuxt/test-utils/module'] : []),
  ],
  shadcn: {
    prefix: '',
    componentDir: './app/components/ui',
  },
  compatibilityDate: '2025-01-01',
  css: ['~/assets/css/main.css'],
  vite: {
    plugins: [tailwindcss()],
  },
  runtimeConfig: {
    public: {
      apiUrl: process.env.NUXT_PUBLIC_API_URL || 'http://localhost:8000',
      siteUrl: process.env.NUXT_PUBLIC_SITE_URL || 'http://localhost:3000',
    },
  },
  devtools: { enabled: false },
  typescript: { strict: true },
  ssr: true,
})
