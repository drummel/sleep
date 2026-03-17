#!/usr/bin/env node
/**
 * screenshot.js — Takes full-page and viewport screenshots of the SleepPath web app.
 *
 * Usage:
 *   node scripts/screenshot.js [options]
 *
 * Options:
 *   --url <url>           URL to screenshot (default: starts local server on index.html)
 *   --output <dir>        Output directory (default: ./screenshots)
 *   --viewport <preset>   Viewport preset: desktop, mobile, tablet, or WxH (default: all)
 *   --full-page           Capture full scrollable page (default: true)
 *   --sections            Capture individual sections as separate screenshots
 *   --wait <ms>           Wait time after load for animations (default: 1500)
 */

const puppeteer = require("puppeteer-core");
const path = require("path");
const fs = require("fs");
const http = require("http");

// --- Config ---

const CHROME_PATH =
  "/root/.cache/ms-playwright/chromium-1194/chrome-linux/chrome";

const VIEWPORTS = {
  desktop: { width: 1440, height: 900, label: "desktop-1440" },
  laptop: { width: 1280, height: 800, label: "laptop-1280" },
  tablet: { width: 768, height: 1024, label: "tablet-768" },
  mobile: { width: 375, height: 812, label: "mobile-375" },
};

const SECTIONS = [
  { id: "hero", name: "hero" },
  { id: "how-it-works", name: "how-it-works" },
  { id: "chronotypes", name: "chronotypes" },
  { id: "features", name: "features" },
  { id: "testimonial", name: "testimonial" },
  { id: "final-cta", name: "final-cta" },
];

// --- Arg parsing ---

function parseArgs() {
  const args = process.argv.slice(2);
  const opts = {
    url: null,
    output: path.join(__dirname, "..", "screenshots"),
    viewport: "all",
    fullPage: true,
    sections: false,
    wait: 1500,
  };

  for (let i = 0; i < args.length; i++) {
    switch (args[i]) {
      case "--url":
        opts.url = args[++i];
        break;
      case "--output":
        opts.output = args[++i];
        break;
      case "--viewport":
        opts.viewport = args[++i];
        break;
      case "--full-page":
        opts.fullPage = true;
        break;
      case "--no-full-page":
        opts.fullPage = false;
        break;
      case "--sections":
        opts.sections = true;
        break;
      case "--wait":
        opts.wait = parseInt(args[++i], 10);
        break;
    }
  }
  return opts;
}

// --- Local server ---

function startLocalServer(dir) {
  return new Promise((resolve) => {
    const server = http.createServer((req, res) => {
      let filePath = path.join(dir, req.url === "/" ? "index.html" : req.url);
      const ext = path.extname(filePath);
      const mimeTypes = {
        ".html": "text/html",
        ".css": "text/css",
        ".js": "text/javascript",
        ".png": "image/png",
        ".jpg": "image/jpeg",
        ".svg": "image/svg+xml",
      };

      fs.readFile(filePath, (err, data) => {
        if (err) {
          res.writeHead(404);
          res.end("Not found");
          return;
        }
        res.writeHead(200, {
          "Content-Type": mimeTypes[ext] || "application/octet-stream",
        });
        res.end(data);
      });
    });

    server.listen(0, "127.0.0.1", () => {
      const port = server.address().port;
      resolve({ server, url: `http://127.0.0.1:${port}` });
    });
  });
}

// --- Screenshot logic ---

async function takeScreenshots(opts) {
  // Determine viewports to capture
  let viewports;
  if (opts.viewport === "all") {
    viewports = Object.values(VIEWPORTS);
  } else if (VIEWPORTS[opts.viewport]) {
    viewports = [VIEWPORTS[opts.viewport]];
  } else {
    // Parse WxH format
    const [w, h] = opts.viewport.split("x").map(Number);
    viewports = [{ width: w, height: h, label: `custom-${w}x${h}` }];
  }

  // Start local server if no URL provided
  let localServer = null;
  let url = opts.url;
  if (!url) {
    const webDir = path.join(__dirname, "..");
    const result = await startLocalServer(webDir);
    localServer = result.server;
    url = result.url;
    console.log(`Local server started at ${url}`);
  }

  // Ensure output directory
  fs.mkdirSync(opts.output, { recursive: true });

  // Launch browser
  const browser = await puppeteer.launch({
    executablePath: CHROME_PATH,
    headless: "new",
    args: [
      "--no-sandbox",
      "--disable-setuid-sandbox",
      "--disable-dev-shm-usage",
      "--disable-gpu",
    ],
  });

  const screenshots = [];

  try {
    for (const vp of viewports) {
      console.log(`\nCapturing ${vp.label} (${vp.width}x${vp.height})...`);

      const page = await browser.newPage();
      await page.setViewport({ width: vp.width, height: vp.height });
      await page.goto(url, { waitUntil: "networkidle0", timeout: 30000 });

      // Trigger all reveal animations by scrolling through the page
      await page.evaluate(async () => {
        document
          .querySelectorAll(".reveal")
          .forEach((el) => el.classList.add("visible"));
      });

      // Wait for animations to settle
      await new Promise((r) => setTimeout(r, opts.wait));

      // Full-page screenshot
      if (opts.fullPage) {
        const filename = `fullpage-${vp.label}.png`;
        const filepath = path.join(opts.output, filename);
        await page.screenshot({ path: filepath, fullPage: true });
        console.log(`  Saved: ${filename}`);
        screenshots.push(filepath);
      }

      // Viewport-only screenshot (above the fold)
      const viewportFile = `viewport-${vp.label}.png`;
      const viewportPath = path.join(opts.output, viewportFile);
      await page.screenshot({ path: viewportPath, fullPage: false });
      console.log(`  Saved: ${viewportFile}`);
      screenshots.push(viewportPath);

      // Section screenshots
      if (opts.sections) {
        for (const section of SECTIONS) {
          const el = await page.$(`#${section.id}`);
          if (el) {
            const sectionFile = `section-${section.name}-${vp.label}.png`;
            const sectionPath = path.join(opts.output, sectionFile);
            await el.screenshot({ path: sectionPath });
            console.log(`  Saved: ${sectionFile}`);
            screenshots.push(sectionPath);
          }
        }
      }

      await page.close();
    }
  } finally {
    await browser.close();
    if (localServer) localServer.close();
  }

  console.log(`\nDone! ${screenshots.length} screenshots saved to ${opts.output}`);
  return screenshots;
}

// --- Main ---

(async () => {
  try {
    const opts = parseArgs();
    await takeScreenshots(opts);
  } catch (err) {
    console.error("Screenshot failed:", err.message);
    process.exit(1);
  }
})();
