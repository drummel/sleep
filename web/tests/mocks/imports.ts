// Mock Nuxt auto-imports for vitest
export { ref, computed, watch, onMounted, onUnmounted, reactive, toRef, toRefs, nextTick } from 'vue'
export { useRoute, useRouter } from 'vue-router'

// Mock Nuxt-specific composables
export function useState<T>(key: string, init: () => T) {
  const { ref } = require('vue')
  return ref(init())
}

export function useRuntimeConfig() {
  return {
    public: {
      apiUrl: 'http://localhost:8000',
      siteUrl: 'http://localhost:3000',
    },
  }
}

export function navigateTo(path: string) {
  return path
}

export function useHead(_opts: any) {}

export function useSeoMeta(_opts: any) {}

export function definePageMeta(_opts: any) {}
