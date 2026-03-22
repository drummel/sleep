import puppeteer from 'puppeteer-core'
import { mkdirSync } from 'fs'

const CHROME_PATH = '/root/.cache/ms-playwright/chromium-1194/chrome-linux/chrome'
const BASE_URL = process.argv[2] || 'http://localhost:3000'
const OUTPUT_DIR = './screenshots'

mkdirSync(OUTPUT_DIR, { recursive: true })

const viewports = [
  { name: 'desktop', width: 1440, height: 900 },
  { name: 'mobile', width: 390, height: 844 },
]

const pages = [
  { path: '/', name: 'landing' },
  { path: '/quiz', name: 'quiz' },
  { path: '/compatibility', name: 'compatibility' },
]

async function main() {
  const browser = await puppeteer.launch({
    executablePath: CHROME_PATH,
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
  })

  for (const viewport of viewports) {
    for (const pageInfo of pages) {
      const page = await browser.newPage()
      await page.setViewport({ width: viewport.width, height: viewport.height })

      try {
        await page.goto(`${BASE_URL}${pageInfo.path}`, { waitUntil: 'domcontentloaded', timeout: 30000 })
        await new Promise(r => setTimeout(r, 1500))

        await page.screenshot({
          path: `${OUTPUT_DIR}/${pageInfo.name}-${viewport.name}.png`,
          fullPage: true,
        })
        console.log(`✓ ${pageInfo.name}-${viewport.name}.png`)
      } catch (err) {
        console.error(`✗ ${pageInfo.name}-${viewport.name}: ${err.message}`)
      }

      await page.close()
    }
  }

  await browser.close()
  console.log('\nScreenshots saved to', OUTPUT_DIR)
}

main().catch(console.error)
