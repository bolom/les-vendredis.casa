# Homepage Narrative Redesign

**Date:** 2026-05-13  
**Scope:** Homepage structure, content hierarchy, mobile presentation, booking emphasis

---

## Context

Les Vendredis already contains the right material for a story-first homepage: a family-built place, a visible construction history, a living journal, and photography that shows the place as evidence of a way of life. The current homepage still repeats the same practical facts across hero, credentials, booking, and FAQ-like blocks, which creates a split identity. It feels both poetic and transactional.

This redesign does not invent a new brand or a luxury layer. It exposes what is already there and removes repetition that interrupts the atmosphere.

---

## Design Goal

Make the homepage feel like a continuous narrative field rather than a stack of content modules.

The homepage should:

- read as a living family world that is discovered gradually
- use the journal as the authority layer
- keep practical facts present, but quiet and late in the flow
- keep booking available without letting it dominate the page
- preserve documentary honesty and roughness rather than over-polishing the experience

---

## Core Principles

### 1. Narrative over module structure

The homepage should not feel like:

- hero
- features
- FAQ
- booking

It should feel more like a sequence of images, observations, and fragments that accumulate into understanding. The page should move by rhythm and pacing, not by explaining every transition.

### 2. Journal as authority

The build logs and journal entries are the proof of authorship. They are the strongest signal on the site and should remain central. The homepage should support that authority, not compete with it.

### 3. Practical facts introduced once, then echoed only through context

Facts are not the problem. Repetition is. The homepage still needs grounding, but details like capacity, pets, and location should be introduced once, in the most useful place, then echoed only through context rather than restated.

### 4. Quiet reassurance near the end

The homepage should include a small `Good to know` block late in the flow. This block is not a FAQ and not customer-service content. It is a minimal set of factual anchors that reduces uncertainty without breaking the tone.

### 5. Invitation, not transaction

The final booking moment should feel invitational and calm. Booking remains available, but the page should not read like a sales funnel.

---

## Proposed Homepage Flow

### Opening

Lead with a single emotional opening that introduces the place as a family world. Keep the first message restrained. The hero should not try to say everything.

### Narrative body

Continue with the journal as the main authority layer. The page can use images and short fragments as interruptions or evidence, but not as formal portfolio sections.

### Visual fragments

Images should behave like:

- evidence
- memory
- weather
- interruption

They should not feel like a formal gallery with a sales objective.

### Late grounding

Add a small, quiet `Before you come` block near the end of the homepage. It should contain 4 to 6 short factual anchors, each one or two lines at most. No accordion. No FAQ title. No support tone.

Suggested anchors:

- sleeps
- where it is
- pets
- family-friendly or not
- seasonality / weather sensitivity
- booking note

### Final invitation

Close with a quiet invitation to stay. Booking should be visible, but secondary to the tone of welcome.

---

## What Changes

- Remove repeated location and practical facts from the top of the page.
- Remove the visible FAQ architecture from the homepage.
- Replace it with a small `Good to know` block near the end.
- Reduce repeated explanatory text between sections.
- Keep booking present, but make it quieter than the narrative.
- Keep layout roughness and asymmetry where it supports the lived-in feeling.
- Do not add new poetic copy to compensate for removed modules. Remove first, then only write where the sequence needs orientation.

---

## What Stays

- The journal remains central.
- The construction story remains visible.
- The family voice remains restrained and observational.
- The photography remains documentary rather than art-directed.
- The booking path remains available.

---

## Mobile Direction

Mobile should feel even more continuous than desktop:

- less section-like
- less fact repetition
- more breathing room
- fewer explanatory blocks
- more direct sequencing between story, evidence, grounding, and invitation

The mobile homepage should not feel like a compressed rental listing. It should feel like a narrow path through the same world.

---

## Implementation Scope

Likely files:

- `_includes/hero.html`
- `_includes/hero-fr.html`
- `_includes/journal-preview.html`
- `_includes/journal-preview-fr.html`
- `_includes/gallery.html`
- `_includes/faq.html`
- `_includes/faq-fr.html`
- `_includes/booking.html`
- `_includes/booking-fr.html`
- `assets/css/main.css`

The implementation should focus on rearranging hierarchy, compressing repeated facts, and changing the feel of the FAQ into a small grounding block.

---

## Success Criteria

- The homepage reads as one narrative, not a pile of modules.
- Repeated facts are reduced materially.
- The journal feels like the site’s authority layer.
- The FAQ no longer punctures the atmosphere.
- Practical grounding remains, but quietly and late.
- The booking path is present but not dominant.
- The site still feels lived-in, documentary, and unfinished in the right way.
