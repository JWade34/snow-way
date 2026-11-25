// UX gate for Snow Way pages. Run through bin/ux-check, which installs Playwright and (with --serve) boots a local server.
// For each path it loads the page at phone and desktop sizes, runs automatic checks, and saves screenshots for a visual
// review against docs/ux-checklist.md. Exit code 1 if any page FAILs.
//
//   node script/ux_check.cjs <base-url> <out-dir> /path [/path ...]
const path = require("path");
const fs = require("fs");
const { chromium } = require(path.join(__dirname, "..", "tmp", "ux-tools", "node_modules", "playwright"));

const [base, outDir, ...paths] = process.argv.slice(2);
if (!base || !outDir || paths.length === 0) {
  console.error("usage: node script/ux_check.cjs <base-url> <out-dir> /path [/path ...]");
  process.exit(2);
}

const VIEWPORTS = [
  { name: "phone", width: 390, height: 844, isMobile: true, hasTouch: true },
  { name: "desktop", width: 1366, height: 900, isMobile: false, hasTouch: false },
];
const MAX_SHOT_HEIGHT = 7000; // full-page shots of long pages get cut here to keep files readable
const CLS_LIMIT = 0.1;        // Google's "good" threshold
const third = (url) => !url.startsWith(base);

// Runs inside the page. Returns failures, warnings and facts about the page's calls to action.
function inspect({ phone, clsLimit }) {
  const fails = [], warns = [];
  const vw = window.innerWidth, vh = window.innerHeight;
  const visible = (el) => { const r = el.getBoundingClientRect(); const s = getComputedStyle(el);
    return r.width > 0 && r.height > 0 && s.visibility !== "hidden" && s.display !== "none" && parseFloat(s.opacity) > 0; };
  const label = (el) => `${el.tagName.toLowerCase()}${el.id ? "#" + el.id : ""}${el.className && typeof el.className === "string" ? "." + el.className.trim().split(/\s+/).slice(0, 2).join(".") : ""}`;

  // 1. Nothing wider than the screen (sideways scrolling on phones is the most common break).
  if (document.documentElement.scrollWidth > vw + 1) {
    const wide = [...document.body.querySelectorAll("*")].filter((el) => visible(el) && el.getBoundingClientRect().right > vw + 1
      && !el.closest("[data-ux-scroll], .overflow-x-auto, .overflow-auto, table"))
      .slice(0, 5).map(label);
    fails.push(`page scrolls sideways (${document.documentElement.scrollWidth}px wide at ${vw}px)${wide.length ? ": " + wide.join(", ") : ""}`);
  }

  // 2. One visible h1, near the top on phones so the answer starts above the fold.
  const h1s = [...document.querySelectorAll("h1")].filter(visible);
  if (h1s.length !== 1) fails.push(`${h1s.length} visible h1 headings (need exactly 1)`);
  else if (phone && h1s[0].getBoundingClientRect().top > vh * 0.6) warns.push(`h1 starts ${Math.round(h1s[0].getBoundingClientRect().top)}px down on a ${vh}px phone screen`);

  // 3. Images: none broken, all with alt text.
  const imgs = [...document.images];
  const broken = imgs.filter((i) => i.complete && i.naturalWidth === 0 && i.loading !== "lazy" && !third(i.currentSrc || i.src));
  if (broken.length) fails.push(`${broken.length} broken image(s): ${broken.slice(0, 3).map((i) => i.getAttribute("src")).join(", ")}`);
  const noAlt = imgs.filter((i) => !i.hasAttribute("alt"));
  if (noAlt.length) warns.push(`${noAlt.length} image(s) without alt`);

  // 4. Layout shift while loading.
  const cls = window.__uxCls || 0;
  if (cls > clsLimit) fails.push(`layout shift ${cls.toFixed(3)} (limit ${clsLimit})`);

  // 5. Phone readability: tap targets and body text size.
  if (phone) {
    const small = [...document.querySelectorAll("button, input:not([type=hidden]), select, a.btn, a[class*='button'], nav a, [role=button]")]
      .filter((el) => visible(el) && !el.closest("p, li p, td")).filter((el) => { const r = el.getBoundingClientRect(); return r.height < 24 || r.width < 24; });
    if (small.length) warns.push(`${small.length} tap target(s) under 24px: ${small.slice(0, 4).map(label).join(", ")}`);
    const tiny = [...document.querySelectorAll("main p, main li, main td")].filter((el) => visible(el) && el.textContent.trim().length > 40
      && parseFloat(getComputedStyle(el).fontSize) < 14);
    if (tiny.length) warns.push(`${tiny.length} text block(s) under 14px`);
  }

  // 6. Calls to action: where the email box and affiliate links sit (facts for the conversion review, not pass/fail).
  const forms = [...document.querySelectorAll("form")].filter((f) => f.querySelector("input[type=email]") && visible(f));
  const aff = [...document.querySelectorAll("a[rel~=sponsored]")].filter(visible);
  const y = (el) => Math.round(el.getBoundingClientRect().top + window.scrollY);
  const height = document.documentElement.scrollHeight;
  return {
    fails, warns, cls: Number(cls.toFixed(3)), height,
    cta: {
      email_forms: forms.length, first_email_form_y: forms.length ? y(forms[0]) : null,
      affiliate_links: aff.length, first_affiliate_y: aff.length ? y(aff[0]) : null,
      screens_tall: Number((height / vh).toFixed(1)),
    },
  };
}

(async () => {
  fs.mkdirSync(outDir, { recursive: true });
  const browser = await chromium.launch();
  const report = [];
  let failed = false;

  for (const p of paths) {
    for (const vp of VIEWPORTS) {
      const context = await browser.newContext({ viewport: { width: vp.width, height: vp.height }, isMobile: vp.isMobile,
        hasTouch: vp.hasTouch, deviceScaleFactor: 1 });
      const page = await context.newPage();
      const errors = [];
      page.on("pageerror", (e) => errors.push(e.message));
      page.on("console", (m) => { if (m.type() === "error" && !third(m.location().url || "")) errors.push(m.text()); });
      await page.addInitScript(() => {
        window.__uxCls = 0;
        new PerformanceObserver((list) => { for (const e of list.getEntries()) if (!e.hadRecentInput) window.__uxCls += e.value; })
          .observe({ type: "layout-shift", buffered: true });
      });

      const url = base.replace(/\/$/, "") + p;
      const slug = (p.replace(/^\//, "").replace(/[^a-z0-9]+/gi, "-") || "home") + "-" + vp.name;
      let result;
      try {
        const res = await page.goto(url, { waitUntil: "load", timeout: 45000 });
        await page.waitForTimeout(1500); // late fonts, lazy widgets
        result = await page.evaluate(inspect, { phone: vp.isMobile, clsLimit: CLS_LIMIT });
        if (!res || res.status() !== 200) result.fails.unshift(`HTTP ${res ? res.status() : "no response"}`);
        const own = errors.filter((e) => !/stay22|posthog|impact|googletag/i.test(e));
        if (own.length) result.fails.push(`JavaScript errors: ${own.slice(0, 3).join(" | ")}`);
        await page.screenshot({ path: path.join(outDir, `${slug}-top.png`) });
        await page.screenshot({ path: path.join(outDir, `${slug}-full.png`),
          clip: { x: 0, y: 0, width: vp.width, height: Math.min(result.height, MAX_SHOT_HEIGHT) } , fullPage: true });
      } catch (e) {
        result = { fails: [`could not load: ${e.message.split("\n")[0]}`], warns: [], cta: {} };
      }
      await context.close();

      const status = result.fails.length ? "FAIL" : result.warns.length ? "WARN" : "PASS";
      if (status === "FAIL") failed = true;
      report.push({ path: p, viewport: vp.name, status, ...result, screenshots: [`${slug}-top.png`, `${slug}-full.png`] });
      console.log(`${status.padEnd(4)} ${vp.name.padEnd(7)} ${p}`);
      for (const f of result.fails) console.log(`       fail: ${f}`);
      for (const w of result.warns) console.log(`       warn: ${w}`);
      if (result.cta && result.cta.screens_tall) {
        const c = result.cta;
        console.log(`       cta: ${c.email_forms} email form(s)${c.first_email_form_y != null ? " first at " + c.first_email_form_y + "px" : ""}, `
          + `${c.affiliate_links} affiliate link(s)${c.first_affiliate_y != null ? " first at " + c.first_affiliate_y + "px" : ""}, page is ${c.screens_tall} screens tall`);
      }
    }
  }

  await browser.close();
  fs.writeFileSync(path.join(outDir, "report.json"), JSON.stringify(report, null, 2));
  console.log(`\nScreenshots and report.json in ${outDir}. Review them against docs/ux-checklist.md.`);
  process.exit(failed ? 1 : 0);
})();
