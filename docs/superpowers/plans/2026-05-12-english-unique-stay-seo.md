# English Unique Stay SEO Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Bring `/unique-stay-martinique/` to parity with the French SEO page while keeping its existing URL.

**Architecture:** `unique-stay-martinique.html` owns English landing-page copy and includes the shared Domaine tour. `_includes/faq.html` provides homepage internal linking. `_includes/schema-faq-landing.html` provides language-specific FAQPage JSON-LD.

**Tech Stack:** Jekyll, Liquid, static HTML, JSON-LD.

---

## Task 1: Update English Page Metadata And Hero

**Files:**
- Modify: `unique-stay-martinique.html`

- [ ] Update title, SEO title, and description around `unique stay in Martinique`.
- [ ] Keep canonical and permalink unchanged.
- [ ] Update hero copy to mention unusual accommodation, A-frame cabin, private tropical garden, pets, no AC, no TV.

## Task 2: Add Intent Section And Domaine Tour

**Files:**
- Modify: `unique-stay-martinique.html`

- [ ] Add a `Why choose this unique stay in Martinique?` section after the credentials.
- [ ] Include `{% include gallery.html %}` after that section.

## Task 3: Refresh English Visible FAQ

**Files:**
- Modify: `unique-stay-martinique.html`

- [ ] Replace the first FAQ block with search-intent questions.
- [ ] Replace the second FAQ block with exclusions, locks, staff, and booking questions.

## Task 4: Update Homepage Link And Schema

**Files:**
- Modify: `_includes/faq.html`
- Modify: `_includes/schema-faq-landing.html`

- [ ] Rewrite the homepage FAQ first item to link with `unique stay in Martinique`.
- [ ] Replace English FAQPage schema questions and answers to match the refreshed English page.
- [ ] Do not change the French schema block.

## Task 5: Verify, Commit, Push

**Files:**
- Verify generated output in `_site/unique-stay-martinique/index.html`

- [ ] Run `bundle exec jekyll build`.
- [ ] Run `rg -n "unique stay|unusual accommodation|Domaine|The Domain|FAQPage|LodgingBusiness|canonical|jacuzzi|wifi" _site/unique-stay-martinique/index.html`.
- [ ] Commit scoped files with `seo: strengthen english unique stay page`.
- [ ] Push `main`.
