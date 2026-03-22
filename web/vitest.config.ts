import { defineConfig } from 'vitest/config'
import vue from '@vitejs/plugin-vue'
import { resolve } from 'path'

export default defineConfig({
  plugins: [vue()],
  resolve: {
    alias: {
      '@': resolve(__dirname, './app'),
      '~': resolve(__dirname, './app'),
      '#imports': resolve(__dirname, './tests/mocks/imports.ts'),
      '#app': resolve(__dirname, './tests/mocks/app.ts'),
    },
  },
  test: {
    globals: true,
    environment: 'happy-dom',
    setupFiles: ['./tests/setup.ts'],
    include: ['tests/**/*.test.ts'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'text-summary', 'html'],
      include: ['app/**/*.{ts,vue}'],
      exclude: [
        'app/components/ui/**',
        'app/assets/**',
        'app/plugins/**',
        'app/app.vue',
        'app/layouts/**',
        'app/pages/**',
      ],
      thresholds: {
        statements: 95,
        branches: 85,
        functions: 95,
        lines: 95,
      },
    },
  },
})
