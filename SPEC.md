# Kollesis — Build Specification

> Portfolio app 108, batch pending. This document is the complete brief for
> building this application. Read all of it before writing any code. Anything
> not specified here is your decision, but must stay consistent with section 3.

**One-line positioning:** Tap where a saved painting's maker name ends and the title begins.

| Field | Value |
| --- | --- |
| Product name | Kollesis |
| Bundle identifier | `com.kollesis.roll` |
| Domain | https://kollesis-roll.pro |
| Contact URL | https://kollesis-roll.pro/contact-us |
| Deployment target | iOS 17.0 |
| Swift version | 6.2, strict concurrency `complete` |
| Devices | iPhone and iPad, portrait |
| Interface style | Light |
| Asset prefix | `kol_` |
| User-Agent | `Kollesis/1.0 (iOS; +https://kollesis-roll.pro)` |

---

## 1. Non-negotiable constraints

1. **No CocoaPods.** Dependencies come from Swift Package Manager, a local
   in-repo package, a vendored source folder, or nothing at all — per section 3.
2. **No shared code with other portfolio apps.** Business rules are re-implemented
   here under this app's own type names.
3. **All code, identifiers, comments, UI copy and the README are in English.**
4. **No launch gate, no WebView shell, no remote configuration, no analytics.**
   Guideline 4.2 (Minimum Functionality): this is a native SwiftUI product, not
   a web browsing experience. WKWebView / SFSafariViewController as UI is a
   reject. Push notifications, Core Location, and sharing do not make a
   browser or a thin catalog into an App Store app.
5. **Guideline 5.1.1 (Privacy):** never direct the user to grant camera access.
   A pre-permission screen may exist; the proceed button is **Continue** or
   **Next**, never "Allow camera", "Enable camera", "Grant camera", or a bare
   Allow/Enable that triggers `requestAccess`. The system alert is the only Allow.
6. **No CI files.** No `bitrise.yml`, no `Scripts/`, no `metadata/` folder.
7. **Assets are AI-generated.** No stock photography. SF Symbols may support
   small affordances but must never be the primary iconography.
8. **The app must build clean** with
   `xcodegen generate && xcodebuild -scheme Kollesis -destination 'generic/platform=iOS' build`.
9. **Nothing may echo another app in this batch** in naming, layout or visuals.
10. **This is not a calorie meal-slot tracker** unless family is `food_tracker`.
   Do not invent food logging to fill the brief.

---

## 2. Product core

The product is offline-first. No account, no sign-in, no ads, no in-app purchase,
no analytics SDK, no remote config. All user data stays on the device.

A cataloguer taps the glued seam between the maker's name and the title so that roll files as parted.

### 2.1 User flow

1. Tap the seam on the glued caption that separates the maker's name from the title.
2. A wrong joint cools that seam and keeps the same volumen.
3. Explore saves another Loose painting; a repeated object id only focuses that row.
4. Parted works move to Saved and leave the glue pool; Saved lists SeamMarks and TearMarks.
5. Undo peels the newest seam or tear; Settings names the Gardner collection with no shop and no grade.

### 2.2 Essential behaviour

- Quiz is a glued volumen: artist tokens then title tokens, or the reverse, with a tappable seam at every token joint
- Split files the painting Parted when the tapped seam is the true field boundary
- A miss writes a TearMark and keeps the Volumen
- Explore crates a Loose work; the same object id only focuses it
- Saved reviews SeamMarks and TearMarks; local only; one collection voice; no shop

---

## 3. Uniqueness assignment for Kollesis

| Axis | Assigned value |
| --- | --- |
| Architecture | **Kollesis ADT fold (Idle | Glued | Parted); the roll is a fold over Works; Glue writes a Volumen that is artist then title XOR title then artist as one token run and hangs Seams at every token joint; Split writes a SeamMark when the tapped Seam is the true field boundary and folds Glued to Parted; a miss writes a TearMark and keeps the Volumen; Split on Idle is refused; a second Glue while Glued is refused; Glue samples a Work that is not Parted whose artist and title together have at least three tokens; empty roll writes Smooth** |
| UI approach | **SwiftUI pure · take roll** |
| Naming convention | **Kollesis / papyrus-seam lexicon** |
| File organization | **By roll role (Roll, Work, Volumen, Seam, SeamMark, TearMark)** |
| Dependency strategy | **None** |
| Design direction | **Soft card daylight · take roll** |
| Typography | **SF Pro** |
| Navigation pattern | **Roll-locked chrome (the glued volumen never leaves; Explore, Saved and Settings arrive as sheets; glue and split fuse on Quiz)** |
| AI art style | **3D glass render glassmorphism · take roll** |
| Functional twist | **Glue-then-split (Glue samples a Work that is not Parted whose artist and title together have at least three tokens; a Volumen is artist then title XOR title then artist as one run; Seams hang at every token joint; Split writes a SeamMark when the tapped Seam is the true field boundary and folds Glued to Parted; a miss writes a TearMark and keeps the Volumen; Split on Idle is refused; Glue on a crate that cannot form a three-token run writes Smooth)** |
| Persistence | **UserDefaults+Codable** |
| Screen composition | see 3.6 |

### 3.0 Product concept

This is the product the contracts below are assigned to. Do not substitute another.

**Family** — art_quiz

**Core** — A cataloguer taps the glued seam between the maker's name and the title so that roll files as parted.

**Audience** — People who already saved museum paintings and want to split a run-on tombstone into maker and title on this device, not restore hidden word spaces, not cross an artist-title grid, and not walk a museum site.

**User flow**

1. Tap the seam on the glued caption that separates the maker's name from the title.
2. A wrong joint cools that seam and keeps the same volumen.
3. Explore saves another Loose painting; a repeated object id only focuses that row.
4. Parted works move to Saved and leave the glue pool; Saved lists SeamMarks and TearMarks.
5. Undo peels the newest seam or tear; Settings names the Gardner collection with no shop and no grade.

**Essential features**

- Quiz is a glued volumen: artist tokens then title tokens, or the reverse, with a tappable seam at every token joint
- Split files the painting Parted when the tapped seam is the true field boundary
- A miss writes a TearMark and keeps the Volumen
- Explore crates a Loose work; the same object id only focuses it
- Saved reviews SeamMarks and TearMarks; local only; one collection voice; no shop

**Twist** — Glue-then-split. Quiz keeps the roll. Glue pulls a Loose painting that still needs parting and whose maker name plus title hold at least three words, then writes a Volumen: maker tokens then title tokens, or the reverse, as one run. Seams hang at every token joint. Split writes a SeamMark when the tapped Seam is the join between those two fields and folds Glued to Parted. A wrong joint writes a TearMark, cools that Seam, and keeps the Volumen. Split before Glue does nothing. A second Glue while Glued is refused. Explore adds a Loose painting; the same object id only brings that row forward. Parted rows move onto Saved and drop out of Glue. Retract strips the latest SeamMark or TearMark. Glue on a crate that cannot make a three-word run writes Smooth. Launch already shows a glued volumen, so the opening seam can file. Home verb: split-the-kollesis, not prick-the-gap and not cross-the-cell. Saved lists SeamMarks plus TearMarks. Settings names the Isabella Stewart Gardner Museum. Grades and a shop stay out.

**Why this is not a repeat** — This is not Stoichedon: the caption keeps its spaces and the job is the cataloguing break between two fields, which you cannot solve by reading English. This is not Laterculus: there is no artist-by-title grid and the home tap is a seam on one line, not a cell. This is not Anathyrosis: words are not shuffled onto a spoil heap and you do not rebuild reading order. This is not Cartellino: you do not sit a whole artist chip and then a whole title chip. Companion-hang apps (Pendilia, Modello, Parergon) stay out because both canvases are never the puzzle. Home verb is split-the-kollesis. Quiz stays the lock surface with Explore, Saved and Settings as sheets.

### 3.0a Craft from the shipped portfolio

Full craft is in KNOWLEDGE.md. Follow it. Do not copy type names or layouts.
- Home: Explore → saved → quiz artist or title.
- Invariant: Quiz draws from saved works. Misses are reviewable. Collecting without a test is the crate clone.
- Never: One collection voice. No shop.
- Taste DNA is section 7.6. Do not invent a second look.
- A TabView with exactly three tabs is the factory stamp — use two or four-to-five destinations, or a different chrome. `-ReviewScreen today|log|goals` are launch keys, not tabs.

### 3.1 Architecture contract

Kollesis is a closed algebraic fold with cases Idle, Glued, and Parted; a fourth case is a defect. The roll is a fold over Works: Glue samples one saved Work that is not Parted whose artist tokens plus title tokens total at least three, writes a Volumen that is artist then title XOR title then artist as one run, hangs a Seam at every token joint, and folds Idle or Parted to Glued; Glue on an empty crate or a crate that cannot form a three-token run writes Smooth; a second Glue while Glued is refused; Parted works leave the glue pool for Saved. Split writes a SeamMark when the tapped Seam is the true join between those two fields and folds Glued to Parted; a miss writes a TearMark, cools that Seam, and keeps the Volumen; Split on Idle is refused. Retract strips the newest SeamMark or TearMark so a SeamMark returns Parted to Glued and the glue pool, and a TearMark warms that Seam; Explore writes a Work as Loose with daykey Int YYYYMMDD from Calendar.current.startOfDay; a repeated object id focuses the existing Work and does not reset Kollesis. One observable RollStore pattern-matches the fold; views call glueRoll, splitSeam, tearSeam, and peelNewestMark and never keep a second kollesis enum; unit tests prove not-Parted three-token sampling, artist-then-title XOR title-then-artist Volumen, Split-on-Idle refuse, second-Glue refuse, miss keep, Retract fold-back, Parted leaving the pool, duplicate focus, Smooth, and that Quiz draws only from saved works with TearMarks reviewable on Saved.

Put a short comment block at the top of each principal type stating the role it
plays in this architecture. The README must justify the pattern for this product.

### 3.2 UI contract

100 percent SwiftUI, Light. No UIViewRepresentable, no WKWebView, no Safari sheet, no camera preview, no TabView. The ui axis restates SwiftUI pure with take-token roll: compose an original papyrus roll with one glued volumen, not a chip easel, not a wall of many canvases, not an unspaced inscription, and not an artist-title grid. Do not copy holder file trees, type names, or layouts. Do not ship a title screen named Kollesis. Home is the mechanic and follows hero-rail: Quiz fills remaining height and the iPad width with one large painting photo-tile, the volumen caption under that tile not on it, a recent rail of parted works, and one secondary SeamMark versus TearMark stat, uneven 2+1. Glue and Split fuse on that roll; Glue does not auto-advance after Parted. Confine custom drawing to that one Quiz hero (Shape, Path, one Material on the photo-tile); Explore, Saved, and Settings are stock sheets (List, Form). Kit is Soft card daylight take roll: radius 20, radius_small 12, shadow, soft card. Soft shadow only on the hero tile; every other surface is flat fill. Primary Glue is a full-width pill ButtonStyle with default, pressed, disabled, and loading. Each Seam is a native Button on the caption, min 44pt, contentShape on the fill, states default, pressed, focused, disabled, selected, and error. Retract is not the destructive variant; resetAllData is. Empty Quiz (Smooth), empty Explore, and empty Saved are full pages (frame maxHeight infinity) with generated cutout art, one headline, one line, and a bottom full-width CTA. Snap motion: press scale 0.97 in 140 to 180ms ease-out; sheets scale 0.96 to 1 plus fade; Reduce Motion is opacity only. Colour is never the only miss signal; a miss also cools and strikes that Seam. One haptic on a successful SeamMark, none on TearMark, none on presenting a sheet. VoiceOver labels on every icon-only sheet control. The ui axis string is never a section title.

### 3.3 Naming contract

Convention: Kollesis / papyrus-seam lexicon.

Examples to follow: `Volumen`, `SeamMark`, `glueRoll()`, `splitSeam()`

### 3.4 Dependency contract

None. project.yml has no packages key. No SPM, no CocoaPods, no bundled font. SF Pro is the system face. Foundation, SwiftUI, and URLSession only. The leftover AVCaptureMetadataOutput scanner stays unused: do not import AVFoundation or Vision for capture, do not request camera access, and do not ship NSCameraUsageDescription. Honor the cgi search pl assignment as paginated JSON search: query, json, page, page_size mapped onto POST https://query.wikidata.org/sparql with a SPARQL body that keeps wdt:P195 wd:Q49135 (Isabella Stewart Gardner Museum), prefers wdt:P18 image and wdt:P170 creator, matches rdfs:label or skos:altLabel to the query, and pages with LIMIT page_size OFFSET (page-1)*page_size. Never call world.openfoodfacts.org or /cgi/search.pl. Never Open Food Facts, calories, meal slots, or a food catalog. Never api.artic.edu. Never collectionapi.metmuseum.org. Dedicated JSONDecoder with useDefaultKeys. DTO fields map Wikidata bindings (item Q-id as object id, itemLabel as title, creatorLabel as artist, image as P18, accession P217 when present) then map to domain Work. Prefer a non-empty image and a creator label. Set User-Agent Kollesis/1.0 (iOS; +https://kollesis-roll.pro) on every request. Debounce search about 500 ms, cancel the previous Task, empty query does not hit the network. Cache resolved works locally so empty or failed search still hangs from the bundled Gardner shelf. Settings credits the Isabella Stewart Gardner Museum as tappable source links (https://www.gardnermuseum.org and https://www.gardnermuseum.org/experience/collection) and Wikidata Q49135 as the machine catalog (https://www.wikidata.org/wiki/Q49135).

### 3.5 Navigation contract

Roll-locked chrome: Quiz is the root roll and the glued volumen never leaves. There is no TabView and no pushed museum detail. Glue, seam Split, and Retract fuse on Quiz. Explore, Saved, and Settings arrive as sheets over the roll. Four destinations, never exactly three tabs. App Intents open Quiz, Explore, Saved, or Settings, or fire glueRoll or splitSeam in place. Custom URL scheme kollesis routes kollesis://quiz, kollesis://explore, kollesis://saved, kollesis://settings, and the matching https://kollesis-roll.pro paths into those same jobs. One haptic on a successful SeamMark, none on presenting a sheet. Contact URL https://kollesis-roll.pro/contact-us lives on Settings. Retract is also reachable from Settings. After onboarding, read ProcessInfo.processInfo.arguments once: -ReviewScreen today stays on Quiz, log presents Saved, goals presents Settings. Extra key explore presents Explore. Skip onboarding on Simulator after the kol.demo.v1 seed so the hook can fire.

### 3.6 Screen composition contract

Roll-root fused quiz (Quiz holds the glued volumen and the token seams; Explore, Saved and Settings are sheets). Physical screens: Quiz, Explore, Saved, Settings. Quiz is the locked roll (ReviewScreen today): Glue writes a Volumen that is artist then title XOR title then artist; Seams hang at every token joint; Split files a SeamMark or a TearMark; Retract peels the newest mark; Smooth is the empty roll. Explore is a sheet that searches the Isabella Stewart Gardner Museum via the remapped catalog and inserts a Loose Work, with a local Gardner shelf when search is empty or fails (deep link explore). Saved is a sheet of Parted works plus reviewable SeamMarks and TearMarks (ReviewScreen log). Settings is a Form for Gardner credit, Retract, contact URL at https://kollesis-roll.pro/contact-us, re-run onboarding, and resetAllData (ReviewScreen goals). Onboarding is a one-shot cover of three pages with Continue or Next at the bottom full width. Empty Quiz with no three-token Loose work is Smooth as a full page: generated cutout art, headline The roll is smooth., one line Save a work, then split., full-width bottom Explore. Empty Explore and empty Saved are full pages of their own. Seeded Quiz already shows a glued volumen so the opening seam can file; Smooth is a test fixture, not the first frame. No Today, Scan, Search, or Goals screens. ReviewScreen today, log, and goals must open three different screens.

Section 5 lists the logical functions that must exist. This section decides how
they are grouped into actual screens. Where the two disagree, this section wins.

A TabView with exactly three tabs is the factory stamp — use two or four-to-five destinations, or a different chrome. `-ReviewScreen today|log|goals` are launch keys, not tabs.

---

## 4. Target file organization

Scheme: **By roll role (Roll, Work, Volumen, Seam, SeamMark, TearMark)**

```
Kollesis/
  Roll/
  Roll.swift
  RollStore.swift
  QuizView.swift
  RollLinks.swift
  SettingsView.swift
  OnboardingFlow.swift
Work/
  Work.swift
  ExploreView.swift
  SavedView.swift
  CatalogClient.swift
  GardnerShelf.swift
Volumen/
  Volumen.swift
Seam/
  Seam.swift
SeamMark/
  SeamMark.swift
TearMark/
  TearMark.swift
  Assets.xcassets/
```

Adapt the leaf files to the architecture, but the top-level shape is fixed. Do
not create a `Utils/` or `Helpers/` dumping ground.

---

## 5. Screens

Build the screens named in section 3.6. The labels below are logical;
actual type names follow this app's naming convention.

### 5.1 Onboarding
Three to four pages. Explains the product, writes initial settings, sets a
completion flag. Skip still writes sensible defaults. Re-runnable from Settings.

### 5.2 Explore
A first-class screen for **Explore**. Must render empty, populated and error states.

### 5.3 Saved
A first-class screen for **Saved**. Must render empty, populated and error states.

### 5.4 Quiz
A first-class screen for **Quiz**. Must render empty, populated and error states.

### 5.5 Settings
A first-class screen for **Settings**. Must render empty, populated and error states.

### 5.6 Settings
Holds: re-run onboarding, reset all data (confirmed), and the contact link to
the domain contact-us URL.

### 5.7 Twist screen
See section 12. The twist needs at least one screen of its own plus a surface on the home screen.


---

## 6. Domain model

Minimum entities, named per this app's convention:

- **Work** — named per this app's convention.
- **QuizCard** — named per this app's convention.
- Plus whatever the twist in section 12 requires.


---

## 7. Design system

Direction: **Soft card daylight · take roll**

### 7.1 Palette

| Token | Hex | Use |
| --- | --- | --- |
| `background` | `#FAF7F5` | Screen background |
| `surface` | `#FEFEFD` | Cards, rows, sheets |
| `ink` | `#392818` | Primary text and icons |
| `accent` | `#CC6D19` | Primary action, key figure, progress fill |
| `muted` | `#816C5A` | Secondary text, dividers, disabled |

Define these as named colours in `Assets.xcassets` and reach them through one
typed accessor. Never hard-code a hex string anywhere else.

### 7.2 Typography

Family: **SF Pro**

SF Pro via Font.system as the hospitable hero-rail type move: short display, max four words, tight leading, and a small body line under it. Display is the photo-tile title under the painting, one line, about 1.4x body, never above 34pt, never painted on the tile. Body is SF Pro about 17pt for volumen tokens on the caption. Caption and micro name IDLE, GLUED, PARTED, SMOOTH, SEAM, TEAR. At most six named steps behind one accessor: display, title, headline, body, caption, micro. Weights and step carry hierarchy. No Font.custom, no fixedSize, never below 12pt, no serif, no second family. SeamMark counts, TearMark counts, and day keys go through NumberFormatter with tabular figures. Dynamic Type; at AX5 display may drop a step so it never clips; names truncate, numbers win. Day edges use Calendar.current.startOfDay then fold to Int YYYYMMDD.

Define a type scale of at most six steps behind one accessor and use only those
steps. Text stays legible at the largest Dynamic Type size.

### 7.3 Layout

- One base spacing unit (4 or 8 pt); only multiples of it.
- Corner radius and elevation are fixed by section 7.4, not chosen per screen.
- Every interactive element is at least 44x44 pt.

### 7.4 Component contract

Corner radius: **20pt** for cards, sheets and primary surfaces; **12pt** for chips, badges and small controls. Reach both through one accessor. Never a bare literal number, and never zero — a hard edge is not this app's design direction.

Elevation: **shadow** — a single soft drop-shadow token, reused everywhere a surface sits above another.

Primary control: **soft card** — primary actions live inside a rounded card using the radius below, not a flat row with no fill.

This is arithmetic, not a suggestion: every card, sheet, chip and button in this app uses these two radii and this elevation style. Do not introduce a second radius or a second elevation style.

This assignment restates a catalog technique another app already holds. Write a new composition: new types, new layout, new motion. Do not copy source, file trees, or type names from the holder.

### 7.5 Custom rendering scope

This app's `ui` axis is **SwiftUI pure · take roll**.

If that approach uses anything beyond stock SwiftUI/UIKit controls — `Canvas`, `CALayer`, Metal, SceneKit, SpriteKit, RealityKit, a hand-drawn `UIViewRepresentable`, or any other pixel-level custom rendering — confine it to exactly one hero surface on one screen (the mechanic's home view, or the one screen this axis exists to showcase). Every other screen — every list, every settings screen, every sheet, every secondary surface — is built from stock components: `List`, `Form`, `NavigationStack`, `TabView`, `Button`, `.sheet`, native `Text`/`Image`. A second custom-rendered surface elsewhere in the app is a defect, not a stylistic choice.

If **SwiftUI pure · take roll** is already fully native (no custom drawing layer), this section is satisfied automatically — there is nothing to confine.

The `ui` axis value is an implementation choice. It must never appear as a user-visible section title or label.

This assignment restates a catalog technique another app already holds. Write a new composition: new types, new layout, new motion. Do not copy source, file trees, or type names from the holder.

### 7.6 Taste DNA

Aesthetic: **warm** (Warm soft: friendly radii, comfortable pad, one playful moment.)

Reference system: **airbnb** — steal rhythm and restraint, not their colours or logos.

Mood: **hospitable**.

Home rhythm (`hero-rail`, comfortable): One large photo-tile mechanic, a recent rail, one secondary stat. Uneven 2+1.

Photography-first home. Caption sits under the tile, not on it. Pill CTA. Soft shadow only on the hero; every other surface is flat fill.

Type move: Short display (max four words), tight leading, small body under it.

Motion (`snap`): Press scale 0.97, 140-180ms ease-out. Sheets scale 0.96 to 1 plus fade. Reduce Motion: opacity only.

Voice (`warm`): Human and brief. Empty states invite. Errors stay calm and useful.

Anti-slop from KNOWLEDGE.md applies. Taste never overrides contrast, 44pt hits, VoiceOver labels, or Reduce Motion.

This assignment restates a catalog technique another app already holds. Write a new composition: new types, new layout, new motion. Do not copy source, file trees, or type names from the holder.

---

## 8. UI and UX quality bar

Every item here is a defect if it is missing. Do not treat this as advice.

**Layout**

- Respect safe areas on every screen. Nothing sits under the notch, the Dynamic
  Island or the home indicator.
- The app is portrait-only on iPhone. Lock it in the Info settings and do not
  write rotation-dependent layout.
- No layout shift when asynchronous data arrives. Reserve the final size up
  front, or use a redacted placeholder of the same dimensions.
- Long product names must truncate gracefully, never push a number off screen.
  Numbers win; names truncate.
- Minimum tap target 44x44 pt for every interactive element, including small
  icon buttons and list accessories.
- Pick one base spacing unit and use only multiples of it. No arbitrary values.

**Keyboard**

- The grams field uses `.decimalPad`, and the decimal separator matches the
  user's locale.
- Content scrolls out from under the keyboard. The focused field is always
  visible.
- Tapping outside the field, or scrolling, dismisses the keyboard.
- Validate on the fly: reject negative and non-numeric input rather than
  crashing the parser later.

**Loading and state**

- Every asynchronous operation has a visible loading state.
- Guard against the spinner flash: if the work finishes in under 150 ms, do not
  show a spinner at all.
- Every list has a designed empty state containing a primary action, not just a
  sentence of text.
- Every error state offers a retry, and states plainly what failed.
- Disable the primary button while its action is in flight so it cannot be
  double-tapped into a double push or a duplicate entry.

**Typography and accessibility**

- All text scales with Dynamic Type. Verify at the largest accessibility size:
  nothing may clip or overlap.
- Every icon-only control has an `accessibilityLabel`. Decorative images are
  marked as decorative so VoiceOver skips them.
- Colour is never the only signal. Pair it with a label, a shape or an icon.
- Honour Reduce Motion: replace movement-heavy transitions with a fade.
- Meet contrast requirements against the palette in section 7. Check the muted
  colour against the background specifically; that is where these palettes fail.

**Formatting**

- Format every number with `NumberFormatter`, never string interpolation. Group
  separators and decimal separators must follow the locale.
- Energy is shown as a whole number of kcal. Macros are shown with at most one
  decimal place.
- Round only at the point of display. Stored values keep full precision.
- Day boundaries use `Calendar.current.startOfDay(for:)` in the user's current
  time zone. Handle the day changing while the app is open, and handle the
  short and long days that daylight saving produces.
- Unknown macro values render as a dash or the word "unknown", never as 0.

**Motion and feedback**

- One haptic on a successful commit (a food logged, a target saved). No haptic
  on navigation.
- Animations are short (0.2 to 0.35 s) and use a single shared easing curve.
- Nothing animates on first appearance of a screen except an intentional entry
  transition.

**Navigation**

- Back always works and never loses entered data without asking.
- A destructive action (delete a log row, reset all data) is confirmed.
- Modal sheets can always be dismissed; there is no dead end.
- Deep state is restorable: relaunching returns the user to a sane screen.


Every item here is a defect if it is missing. Section 7.4 fixed the numbers —
this is where they have to show up on screen.

**Hierarchy and density**

- Every screen has exactly one dominant element (a hero number, a canvas, a
  primary card) that the eye lands on first. A screen where every element has
  equal weight reads as a spreadsheet, not a product.
- Related content is grouped into a card or a section with the elevation
  style from 7.4, not left floating on the bare background.
- Unused flat background is not "minimal" — see the density rule in
  `KNOWLEDGE.md`. If a screen has room left after the mechanic and the
  content, add a secondary surface (a stat strip, a recent-activity card, a
  related-item row), not a `Spacer`.

**Components**

- Every card, sheet, chip, row and button in the app uses the corner radius
  and elevation from section 7.4. No screen introduces its own radius or its
  own shadow value "just for this one card".
- Buttons have a pressed state (`ButtonStyle` with a scale or opacity change
  on `isPressed`) and a disabled state that is visibly different, not just
  non-interactive.
- Chips and badges are pill or rounded-rect shaped per 7.4, never a bare
  `Text` with no background sitting where a control is expected.
- A functional control (add, filter, sort, close, more, share, delete) is an
  SF Symbol inside a properly hit-targeted `Button`. SF Symbols are fine and
  expected here — section 16 only bans them as the app's primary brand
  iconography (app icon, empty-state hero, onboarding art), which is what the
  generated assets in section 13 are for.

**Depth and material**

- At least one surface in the app (a sheet, a modal, a floating toolbar) uses
  the elevation style from 7.4 to visibly sit above the content behind it.
  A flat app with no depth anywhere reads as a wireframe.
- Icons and generated art sit on the surface colour from 7.1, never directly
  on a colour that makes their edges disappear.

**Motion as feedback, not decoration**

- The one dominant element in a screen (7.4's primary control, the mechanic's
  hero) responds visibly to touch: a scale, a colour shift, a haptic — pick
  at least one. A control that looks identical pressed and unpressed reads as
  broken, not calm.

**Taste DNA (section 7.6)**

- Home uses the assigned layout family and density. Three identical equal-weight
  cards, a leftover bento hole, or a second column structure copied down the
  page is a defect.
- Copy follows the assigned voice. No em-dash, no elevate/unlock/seamless, no
  emoji, no SECTION 01 labels.
- Motion follows the assigned personality and honours Reduce Motion with a fade.
  One signature motion per view. No glow stacked on glass stacked on spring.
- Tokens by intent: the live verb wears accent; delete does not wear primary.


---

## 9. Concurrency

The target builds with Swift 6.2 and `SWIFT_STRICT_CONCURRENCY = complete`. It
must compile with **zero concurrency warnings**. Warnings here become crashes
later, so they are not negotiable.

- All UI types are `@MainActor`. Annotate the type, not individual methods.
- Any value crossing an actor boundary is `Sendable`. Prefer immutable structs
  of primitives.
- Do not use `@unchecked Sendable`. If it is genuinely unavoidable, it needs a
  comment explaining what guarantees the safety.
- No mutable global state. No `static var` that is written after launch.
- Networking and storage APIs are `async` and honour cancellation. When the
  search query changes, cancel the in-flight task; do not let a stale response
  overwrite fresh results.
- Use structured concurrency. Avoid `Task.detached` unless there is a stated
  reason. Never fire a `Task` that outlives the view without owning it.
- Never use `DispatchQueue.main.asyncAfter` to paper over an ordering problem.
  Fix the ordering.
- `Timer` and notification observers are invalidated in `deinit` or on
  disappear.


---

## 10. Persistence engineering

Chosen technology: **UserDefaults+Codable**

One Codable RollDocument (schemaVersion from 1, Works with Loose or Parted, the live Kollesis case Idle Glued or Parted, Volumen token run and field-boundary index, Seams, SeamMarks, TearMarks, cached catalog rows, daykeys as Int YYYYMMDD) encoded to JSON Data in UserDefaults under kol.roll.v1. Kollesis case is stored; parted-ness is not a parallel bool. In-memory RollStore is the source of truth; UserDefaults is the projection. Views never touch UserDefaults. Debounce writes. Flush when scenePhase becomes inactive or background, and after Glue, Split, TearMark, Retract, Explore save, or reset. Decoding failure falls back to kol.roll.v1.backup, then an empty roll, never a crash. resetAllData() is reachable from Settings. Tests use a private UserDefaults suite. Simulator seed only once behind kol.demo.v1 writes several Loose Works from the local Gardner shelf whose artist plus title hold at least three tokens, a mix of Loose and Parted, several SeamMarks and TearMarks so Saved is a used product, hangs a Glued volumen so the opening seam can file, marks onboarding complete, and never seeds Smooth as the first frame. Never seed on a device. Cached works catch empty or failed Gardner search.

This app persists to **files on disk**. The following are mandatory.

- Write atomically. Either `Data.write(to:options: .atomic)` or write to a
  temporary file and `FileManager.replaceItemAt`. A non-atomic write that is
  interrupted leaves a truncated file and the app will not launch.
- Create the containing directory with
  `withIntermediateDirectories: true` before the first write.
- Every document carries a `schemaVersion` field from version 1, and the decoder
  switches on it.
- Decoding failure must be recoverable: keep the previous good file as a
  `.backup`, fall back to it, and if that also fails start from empty state and
  tell the user. Never crash on a corrupt file.
- All file IO happens off the main thread. The main thread never blocks on disk.
- Debounce writes during rapid edits, but force a flush when `scenePhase`
  becomes `.inactive` or `.background`, and after any destructive action.
- Exclude caches from backup with `URLResourceValues.isExcludedFromBackup` where
  appropriate; user data belongs in Application Support and should be backed up.
- Keep an explicit in-memory source of truth and treat the file as a projection
  of it, so a failed write never leaves the UI showing data that does not exist.


Regardless of technology:

- One seam between domain logic and storage; the UI never touches storage types.
- Writes survive a force-quit. Do not rely on `applicationWillTerminate`.
- Provide `resetAllData()`, used by tests and reachable from Settings.

---

## 11. Networking

- One client type owns both Open Food Facts endpoints.
- Set `User-Agent` on every request. Open Food Facts throttles clients that do
  not identify themselves.
- 15 second timeout. One retry on a transient transport failure, then a typed
  error. Do not retry a 404.
- Cancel the in-flight search when the query changes. Debounce input by roughly
  300 ms.
- Decode into DTO types that mirror the JSON exactly, then map to domain types.
  Never decode straight into your domain model.
- Dedicated `JSONDecoder` with `.useDefaultKeys`. Never `convertFromSnakeCase` —
  Open Food Facts keys like `energy-kcal_100g` break snake_case conversion.
- Resolve a scanned code with `GET /api/v2/product/<barcode>.json`, not a search.
- Open Food Facts data is user-contributed and frequently incomplete. Every
  numeric field is optional. A product with no energy value is a normal case
  that the UI must present, not an error.
- Some numeric fields arrive as strings. The decoder must accept both a number
  and a numeric string for every nutriment.
- `status` of `0` in the product response means not found. Map it to a distinct
  error case so the UI can offer manual entry.
- Never crash on malformed JSON. A decoding failure is a handled error.
- Cache every resolved product locally on success, so the app degrades to a
  working offline catalogue.


Set `User-Agent: Kollesis/1.0 (iOS; +https://kollesis-roll.pro)` on every request. Never reuse another app's string.
Use the **cgi search pl** search endpoint for this app.

---

## 11b. App Store readiness

The app must be submittable without further work.

- `PrivacyInfo.xcprivacy` in the target, declaring the UserDefaults access API
  reason `CA92.1` and the file timestamp reason `C617.1`, with
  `NSPrivacyTracking` false and no collected data types.
- `INFOPLIST_KEY_ITSAppUsesNonExemptEncryption = NO` in the pbxproj so TestFlight
  does not sit on Missing Compliance.
- `NSCameraUsageDescription` written specifically for this app. Generic strings
  get rejected.
- `LSApplicationCategoryType` of `public.app-category.healthcare-fitness`.
- Portrait only, iPhone and iPad (`TARGETED_DEVICE_FAMILY = "1,2"`).
- No account, no sign-in, no delete-account flow, no in-app purchase, no ads, no
  user-generated content, and therefore no report or block UI.
- App Tracking Transparency is never invoked.
- The camera is the only sensitive permission requested.
- Guideline 5.1.1 (Privacy): do not encourage or direct the user to grant camera
  access. A pre-permission screen may exist, but the proceed button must be
  **Continue** or **Next** — never "Allow camera", "Enable camera",
  "Grant camera", or a bare Allow/Enable that calls `requestAccess`. The
  system dialog is the only Allow. Denied/restricted offers Open Settings.
- The app must not present itself as a clinician or as medical advice.
- Guideline 4.2 (Design — Minimum Functionality): the binary must be a native
  product, not a web browsing experience. No WKWebView / SFSafariViewController
  / UIWebView as home, a tab, or the primary UX. A content catalog, article
  reader, or site wrapper that could be a website is a reject. Push
  notifications, Core Location, and sharing do not make that acceptable.
- Guideline 1.4.1 (Safety — Physical Harm): if the binary shows health or
  medical recommendations, body-based targets, dosages, "you should" guidance,
  or product health claims (food, drink, supplement, remedy), put citations
  in the app. Tappable links to the sources, easy to find: same screen as the
  claim, or a Sources row one tap from Settings. Name the source (Open Food
  Facts, USDA FoodData Central, WHO, NIH MedlinePlus, …) and link it. A
  "not medical advice" footer without sources is a reject. A personal log
  that never advises does not invent claims to cite.
- Nutrition catalog data is credited to the database this app actually uses
  (Open Food Facts unless the spec names another). Credit is a tappable link,
  not a dead "OpenFoodFacts" label.


Ignore the food-log and Open Food Facts lines above when they conflict with this
family. Category for this app is `public.app-category.education`. Camera permission only if the
product actually captures.

Project settings that follow from the above:

```yaml
INFOPLIST_KEY_UIUserInterfaceStyle: Light
INFOPLIST_KEY_UISupportedInterfaceOrientations: UIInterfaceOrientationPortrait
INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad: UIInterfaceOrientationPortrait
INFOPLIST_KEY_UIRequiresFullScreen: YES
INFOPLIST_KEY_ITSAppUsesNonExemptEncryption: NO
INFOPLIST_KEY_LSApplicationCategoryType: public.app-category.education
TARGETED_DEVICE_FAMILY: "1,2"
SWIFT_STRICT_CONCURRENCY: complete
```

---

## 12. Functional twist: Glue-then-split (Glue samples a Work that is not Parted whose artist and title together have at least three tokens; a Volumen is artist then title XOR title then artist as one run; Seams hang at every token joint; Split writes a SeamMark when the tapped Seam is the true field boundary and folds Glued to Parted; a miss writes a TearMark and keeps the Volumen; Split on Idle is refused; Glue on a crate that cannot form a three-token run writes Smooth)

Home is split-the-kollesis: Quiz keeps a glued volumen and the home tap files the cataloguing break between maker and title, not a restored word space and not a cell on a grid. Glue pulls a Loose painting that still needs parting and whose maker name plus title hold at least three tokens, then writes a Volumen as maker tokens then title tokens or the reverse as one run, with a Seam at every token joint. Split writes a SeamMark when the tapped Seam is the join between those two fields and folds Glued to Parted; a wrong joint writes a TearMark, cools that Seam, and keeps the Volumen; Split before Glue does nothing; a second Glue while Glued is refused. Explore crates a Loose work from the Gardner catalog or the local Gardner shelf; a repeated object id only focuses that row; Parted rows move onto Saved and drop out of Glue; Retract strips the latest SeamMark or TearMark; Glue on a crate that cannot make a three-token run writes Smooth. Simulator seed already shows a glued volumen so the opening seam can file; Smooth is a test fixture, not the first frame; Saved lists SeamMarks plus TearMarks; Settings names the Isabella Stewart Gardner Museum; grades and a shop stay out.

This is the app's marketed differentiator. It must be:

- visible on the home screen, not buried in settings;
- backed by real persisted data, not a cosmetic flourish;
- covered by at least one unit test;
- described in the README as the reason a user would pick this app.

---

## 13. AI-generated assets

Art style: **3D glass render glassmorphism · take roll**


This assignment restates a catalog technique another app already holds. Write a new composition: new types, new layout, new motion. Do not copy source, file trees, or type names from the holder.

Base prompt, reused and extended for every asset:

```
3D glass render, glassmorphism, studio-lit papyrus roll, frosted glued kollesis seam, volumen of joined sheets, refraction and soft bloom, isolated subjects, quiet uncluttered ground, hospitable daylight not a gym, no text, no letters, no logo, no photoreal stock, no specified colours, one glued roll not a chip easel, not a vitrine grid, not an unspaced slab
```

All 15 images below are required. Generate each one, export
as PNG, and add it to `Assets.xcassets` as its own image set named exactly as
given. Every name carries the `kol_` prefix.

### 13.1 App icon rules (strict)

The icon is rejected by App Store Connect if any of these are wrong:

- Exactly **1024 x 1024 px**.
- **No alpha channel.**
- sRGB colour profile, 8 bits per channel, PNG.
- **No text and no words** in the artwork.
- **No rounded corners and no built-in mask.**
- The subject stays inside the middle 80%.

### 13.2 Full asset list

| # | Image set | Size (px) | Alpha | Purpose |
| --- | --- | --- | --- | --- |
| 1 | `kol_AppIcon` | 1024x1024 | **NO** | App Store icon. NO alpha channel, NO transparency, NO text, NO rounded corners, NO drop shadow outside the canvas. |
| 2 | `kol_Splash` | 1290x2796 | fill | Launch background. The middle third must stay quiet so the wordmark reads on top. |
| 3 | `kol_Onboarding1` | 1024x1536 | **required cutout** | Onboarding page 1 illustration: what the app is for. |
| 4 | `kol_Onboarding2` | 1024x1536 | **required cutout** | Onboarding page 2 illustration: the main verb. |
| 5 | `kol_Onboarding3` | 1024x1536 | **required cutout** | Onboarding page 3 illustration: why they stay. |
| 6 | `kol_EmptyHome` | 1024x1024 | **required cutout** | Empty state: the home screen has nothing yet. Calm and inviting, never sad. |
| 7 | `kol_EmptyList` | 1024x1024 | **required cutout** | Empty state: a secondary list has no rows. |
| 8 | `kol_CardBackdrop` | 1200x800 | fill | Backdrop art for a primary card. Low contrast so text stays readable. |
| 9 | `kol_ControlFace` | 512x512 | **required cutout** | Custom control artwork used for the primary interactive element. |
| 10 | `kol_TwistHero` | 1024x1024 | **required cutout** | Hero art for the 'Glue-then-split (Glue samples a Work that is not Parted whose artist and title together have at least three tokens; a Volumen is artist then title XOR title then artist as one run; Seams hang at every token joint; Split writes a SeamMark when the tapped Seam is the true field boundary and folds Glued to Parted; a miss writes a TearMark and keeps the Volumen; Split on Idle is refused; Glue on a crate that cannot form a three-token run writes Smooth)' feature screen. |
| 11 | `kol_SuccessMark` | 512x512 | **required cutout** | Shown briefly when the primary action succeeds. |
| 12 | `kol_HeaderDecor` | 1200x600 | **required cutout** | Decorative header accent on the main screen. |
| 13 | `kol_PapyrusRoll` | 1024x1024 | **required cutout** | Isolated solid closed papyrus roll on a wooden rod, cutout, transparent corners, opaque paper and wood filling the center, no plate, no hollow frame, no text |
| 14 | `kol_GluedSeam` | 1024x1024 | **required cutout** | Isolated solid overlapping papyrus join, cutout, opaque layered paper, transparent corners, no plate, no text |
| 15 | `kol_VolumenRod` | 1024x1024 | **required cutout** | Isolated solid wooden volumen rod, cutout, opaque wood, transparent corners, no plate, no text |

### Prompt per asset

**`kol_AppIcon`** — 1024x1024

```
A single 3D glass papyrus roll with one frosted glued seam, glassmorphism, subject centred filling the canvas edge to edge, no text, no letters, no words, no alpha, no transparency, no rounded corners, no drop shadow outside the canvas
```

**`kol_Splash`** — 1290x2796

```
A tall vertical 3D glass volumen receding, quiet uncluttered centre band for a wordmark, glassmorphism, no readable text
```

**`kol_Onboarding1`** — 1024x1536

```
Solid closed papyrus volumen on a wooden rod, the product in one glance, isolated cutout, opaque paper and wood in the center, transparent corners, no glass box, no text

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`kol_Onboarding2`** — 1024x1536

```
A hand tapping the glued overlap between two solid papyrus sheets, split the seam, isolated cutout, opaque subject in the center, no hollow frame, no text

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`kol_Onboarding3`** — 1024x1536

```
A small stack of parted papyrus sheets beside a bone folder, meaning accumulated, isolated cutout, opaque subjects, no text

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`kol_EmptyHome`** — 1024x1024

```
A solid unused papyrus roll still tied, waiting, calm and inviting, never sad, isolated cutout, opaque paper and cord in the center, no hollow glass, no text

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`kol_EmptyList`** — 1024x1024

```
A solid empty wooden scroll shelf with no rolls, calm, isolated cutout, opaque wood, no text

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`kol_CardBackdrop`** — 1200x800

```
Abstract low-contrast 3D frosted glass roll bloom, quiet enough for text on top, filling the canvas, no letters
```

**`kol_ControlFace`** — 512x512

```
The face of a small solid bone folder used to burnish a papyrus seam, isolated cutout, opaque bone, no text

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`kol_TwistHero`** — 1024x1024

```
Solid papyrus volumen with one glued overlap ready to part, glue-then-split emblem, isolated cutout, opaque paper, no hollow glass, no text

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`kol_SuccessMark`** — 512x512

```
A small solid papyrus sheet parted cleanly at the glued join, confirmation not fireworks, isolated cutout, no letters

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`kol_HeaderDecor`** — 1200x600

```
A wide low solid papyrus band with one overlapping glued edge, isolated cutout, opaque paper in the center, transparent corners, no glass pane, no readable text

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`kol_PapyrusRoll`** — 1024x1024

```
Isolated solid closed papyrus roll on a wooden rod, cutout, transparent corners, opaque paper and wood filling the center, no plate, no hollow frame, no text

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`kol_GluedSeam`** — 1024x1024

```
Isolated solid overlapping papyrus join, cutout, opaque layered paper, transparent corners, no plate, no text

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`kol_VolumenRod`** — 1024x1024

```
Isolated solid wooden volumen rod, cutout, opaque wood, transparent corners, no plate, no text

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```


### 13.3 Asset rules

- Cut-outs (everything except AppIcon, Splash, CardBackdrop): isolated subject,
  real PNG alpha, all four corners transparent. No square plate.
- Assets must be semantically different from each other.
- Record the exact prompt used for every asset in the README.
- SF Symbols are permitted only for close, chevron, share and similar system
  affordances.

Scanner frames, reticles, and seamless tiles are drawn in SwiftUI via `Path` or `Shape`. GenerateImage is not used for those. Every other in-app graphic (except AppIcon, Splash, CardBackdrop) is a **cutout**: isolated SOLID opaque subject in the center, real PNG alpha, all four corners transparent. An opaque square plate inside a circle or pentagon is a fail. A hollow glass box or wire frame with a transparent center is a fail.

---

## 14. Demo data

Seed a small local demo dataset for this family's entities so Simulator
screenshots are not empty. The same seed must mark onboarding complete and
fill the primary surface — otherwise `-ReviewScreen` never fires. Never seed
on a physical device. Guard with `#if targetEnvironment(simulator)` and
`kol.demo.v1`.

Seed the happy path: the home primary verb is enabled. The blocked / gated /
error state is a unit-test fixture, not Simulator home. Home chrome names the
job and the next tap in words a stranger knows. Axis values (`ui`, `naming`,
`architecture`) never become user-visible titles. A card that looks tappable
is a `Button`. A readout does not use button chrome.

---

## 16. Anti-patterns

The following will fail review:

- `try!`, `as!`, or force-unwrapping anything derived from the network, the
  database or a file.
- `fatalError` anywhere reachable at runtime. It is acceptable only for a
  programmer error in an initialiser that cannot fail in practice, and needs a
  comment.
- Swallowing an error with an empty `catch`.
- `print` used as production logging.
- A hard-coded hex colour outside the single colour accessor.
- A hard-coded font name outside the single typography accessor.
- An SF Symbol used as the app's brand iconography — the app icon, the
  empty-state hero, or onboarding art. Those come from section 13. SF Symbols
  are the right choice for every functional control (add, filter, sort,
  close, share, delete) — leaving those as bare text instead of a symbol is
  also a defect.
- Storing a value that can be computed (day totals, remaining budget, macro
  percentages).
- Blocking the main thread on disk or network work.
- `UIScreen.main` for sizing. Use the geometry the layout system gives you.
- Index positions used as list identity. Identity is a stable identifier.
- A view that reaches into the persistence layer directly, bypassing the
  architecture's designated seam.
- Business logic inside a `View` body or a `UIViewController` method, when the
  assigned architecture places it elsewhere.
- Copying a source file from another app in this batch.
- A `TabView` with exactly three tabs. That is the factory stamp — two or
  four-to-five destinations, or a different chrome. ReviewScreen keys are
  not tabs.


---

## 17. Tests

Add a unit test target `KollesisTests` covering at minimum:

1. The core domain invariant of this family (the thing that would be wrong if
   the calculator, decay, crate, or log lied).
2. Empty, populated and invalid input paths for the primary verb.
3. The section 12 twist logic.
4. One architecture-specific test proving the pattern holds.
5. A persistence round-trip: write, relaunch-equivalent reload, verify.
6. Parse `ProcessInfo.processInfo.arguments` once after onboarding. 
   `-ReviewScreen today|log|goals` switches the running app's live navigation. Extra cover slugs open those screens.
   Cover that parser with a unit test. Do not host a `View` in the test.

---

## 18. README.md

Write `README.md` at the app folder root covering:

1. What the app does and who it is for.
2. The architecture used and **why** it suits this product.
3. The unique feature added and how it works.
4. The AI art style and the exact prompt used for every asset.
5. How this app differs from others in the batch.
6. Build instructions.

---

## 19. Definition of done

**Build**
- [ ] `xcodegen generate` succeeds.
- [ ] `xcodebuild -scheme Kollesis -destination 'generic/platform=iOS' build` succeeds.
- [ ] Zero new compiler warnings.
- [ ] Strict concurrency `complete` compiles clean.
- [ ] Test target passes.

**Function**
- [ ] Onboarding to first successful primary action works on a clean install.
- [ ] Every screen in section 3.6 exists and handles empty / filled / error.
- [ ] Reset and contact link live in Settings.
- [ ] Force-quitting immediately after a write loses nothing.
- [ ] Seeded home names the job and next tap; primary verb enabled.
- [ ] App reads `-ReviewScreen today|log|goals` after onboarding.

**Uniqueness**
- [ ] Architecture matches **Kollesis ADT fold (Idle | Glued | Parted); the roll is a fold over Works; Glue writes a Volumen that is artist then title XOR title then artist as one token run and hangs Seams at every token joint; Split writes a SeamMark when the tapped Seam is the true field boundary and folds Glued to Parted; a miss writes a TearMark and keeps the Volumen; Split on Idle is refused; a second Glue while Glued is refused; Glue samples a Work that is not Parted whose artist and title together have at least three tokens; empty roll writes Smooth** with no leakage across layers.
- [ ] UI approach matches **SwiftUI pure · take roll**.
- [ ] Custom rendering, if any, is confined to one hero surface (section 7.5).
- [ ] Navigation matches **Roll-locked chrome (the glued volumen never leaves; Explore, Saved and Settings arrive as sheets; glue and split fuse on Quiz)**.
- [ ] Screen composition follows section 3.6.
- [ ] Typography uses **SF Pro** and nothing else.
- [ ] Palette matches section 7.1 exactly.
- [ ] Home rhythm and motion match section 7.6. No second look.

**Quality**
- [ ] Section 8 UI/UX bar satisfied end to end.
- [ ] Contact link present.
- [ ] `PrivacyInfo.xcprivacy` present and correct.
- [ ] README complete.

---

## 20. Build commands

```bash
cd Kollesis
xcodegen generate
xcodebuild -scheme Kollesis -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build
xcrun simctl list devices available
xcodebuild -scheme Kollesis -destination 'platform=iOS Simulator,id=<UDID>' test
```

Signing is off only on that command line. Do not put CODE_SIGNING_ALLOWED, CODE_SIGNING_REQUIRED, CODE_SIGN_IDENTITY or DEVELOPMENT_TEAM in project.yml — CI signs the archive. Leave CODE_SIGN_STYLE: Automatic as the scaffold set it. The exact simulator does not matter — use any available UDID from the list.
