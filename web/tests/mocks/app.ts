// Mock #app imports for vitest
export { ref, computed, watch, onMounted, onUnmounted, reactive, nextTick } from 'vue'

export function navigateTo(path: string) {
  return path
}

export function useRoute() {
  return {
    path: '/',
    query: {},
    params: {},
  }
}

export function useRouter() {
  return {
    push: (path: string) => path,
    replace: (path: string) => path,
  }
}

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

export function useHead(_opts: any) {}
export function useSeoMeta(_opts: any) {}
export function definePageMeta(_opts: any) {}
