# Screenshot Skill

Take screenshots of the SleepPath web app at various viewport sizes.

## Usage

When the user asks to take screenshots of the web app, run the screenshot script:

```bash
cd /home/user/sleep/web && node scripts/screenshot.js [options]
```

### Options

| Flag | Description | Default |
|---|---|---|
| `--viewport <preset>` | `desktop`, `laptop`, `tablet`, `mobile`, or `all` | `all` |
| `--sections` | Also capture each section (hero, how-it-works, chronotypes, features, testimonial, final-cta) as individual screenshots | off |
| `--output <dir>` | Output directory | `./screenshots` |
| `--url <url>` | URL to capture (auto-starts a local server if omitted) | auto |
| `--wait <ms>` | Delay after load for animations | `1500` |
| `--no-full-page` | Only capture the viewport, not the full scrollable page | off |

### Examples

```bash
# All viewports, full-page + viewport shots
node scripts/screenshot.js

# Mobile only, with section screenshots
node scripts/screenshot.js --viewport mobile --sections

# Desktop only
node scripts/screenshot.js --viewport desktop
```

### Output

Screenshots are saved to `web/screenshots/` with names like:
- `fullpage-desktop-1440.png` — full scrollable page at 1440px wide
- `viewport-mobile-375.png` — above-the-fold on mobile
- `section-hero-desktop-1440.png` — just the hero section at desktop size

After taking screenshots, use the Read tool to view the PNG files and provide feedback or pass them to the design review skill.

### Prerequisites

- Node.js installed
- Run `cd /home/user/sleep/web && npm install` if `node_modules` is missing (puppeteer-core is the only dependency)
- Chromium is available at `/root/.cache/ms-playwright/chromium-1194/chrome-linux/chrome`
