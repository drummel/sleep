// Provide Vue auto-imports that Nuxt normally handles
import { ref, computed, watch, onMounted, onUnmounted, reactive, nextTick, toRef, toRefs } from 'vue'

// Make these available globally like Nuxt does
Object.assign(globalThis, {
  ref,
  computed,
  watch,
  onMounted,
  onUnmounted,
  reactive,
  nextTick,
  toRef,
  toRefs,
  defineProps: () => ({}),
  defineEmits: () => () => {},
  definePageMeta: () => {},
  useHead: () => {},
  useSeoMeta: () => {},
  navigateTo: (path: string) => path,
  useRoute: () => ({ path: '/', query: {}, params: {} }),
  useRouter: () => ({ push: () => {}, replace: () => {} }),
  useRuntimeConfig: () => ({
    public: { apiUrl: 'http://localhost:8000', siteUrl: 'http://localhost:3000' },
  }),
})
