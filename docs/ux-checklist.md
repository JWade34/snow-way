# UX checklist: every page change, every time

Justin's rule: every change must look solid on a phone and a desktop. Most visitors are on phones.

## 1. Run the automatic gate
```
bin/ux-check --serve /changed/path /other/changed/path
```
- **FAIL blocks the push.** It fails on: sideways scrolling, not exactly one h1, broken images, layout shift over 0.1, our own JavaScript errors, non-200.
- **WARN:** fix it if your change caused it. Leave old warnings alone unless fixing them is the change.
- If the change touches a shared partial or layout, add 3 kinds of pages: a resort page (`/resorts/vail`), a guide (`/guides/best-ski-brands`) and the home page.

## 2. Look at the screenshots
`tmp/ux/<timestamp>/`. Open `*-phone-top.png` and `*-desktop-top.png` first, then `*-full.png`. Check each one:

- [ ] **First screen answers the question.** The h1 and the short answer (or the key number or table) show without scrolling on a phone.
- [ ] **Nothing looks broken.** No overlapping text, no text running off the edge, no empty boxes or placeholder text, no giant gaps.
- [ ] **One clear next step per section.** An email box or affiliate button sits where the reader finishes an answer, not stacked three in a row. Buttons look like buttons.
- [ ] **Tables fit.** A wide table scrolls inside its own box on a phone instead of pushing the page sideways. Headers are readable.
- [ ] **Matches the site.** Same dark slate background, cyan accents, Tailwind spacing and type sizes as the pages around it. No new colors, fonts or one-off styles.
- [ ] **Readable.** Body text is at least 14px on a phone, lines aren't wall-to-wall, and contrast is good (no slate-500 text on slate-800).
- [ ] **Images earn their place.** Each image has alt text and an honest caption or credit. No stock photos that pretend to be something they're not.
- [ ] **Affiliate links are disclosed.** A page with affiliate links shows the disclosure line near the top, and those links carry `rel="sponsored"`.

## 3. Calls to action (conversion changes)
The gate prints where the first email box and the first affiliate link sit, and how many screens tall the page is.
- An email box only at the very bottom of a page more than 6 screens tall on a phone is a missed signup. Add one after the short answer or after the first big table, using an existing partial (`shared/_alert_form`, `shared/_checklist_cta`, `shared/_calendar_cta`, `shared/_planner_cta`).
- An affiliate link should sit next to the sentence that recommends the thing, not in a separate block.
- Never more than one email box per 3 screens. Never a pop-up.

## 4. Before and after
For any change to a page with signups or affiliate clicks, run the gate on the live page first (`bin/ux-check --base https://snowway.app /path`), then on your local change, and compare the screenshots side by side. If it isn't clearly better, don't ship it.
