<!-- gf-brief source=51c7eccfddf754ad3789e4bf7aab2c82b65e4ce337104caa951298e2b2ae42bf written=2026-09-26T02:14:05+03:00 -->
# Kollesis

## What it is
Kollesis is a portrait, light-mode education app for people who want to keep Isabella Stewart Gardner Museum paintings on their device and practice finding where the maker’s name meets the title. You file a painting onto “the roll,” glue maker and title into one caption, then tap **Split** on the true join; correct joins become parted works, wrong ones become torn joins.

## Launch and onboarding
On a cold launch, if the welcome has not been finished, a full-screen welcome covers the app with three pages and page dots:

1. Title **“Save a painting”**, body **“Keep a Gardner painting on this device.”**, button **“Next”**.
2. Title **“Split the glue”**, body **“Tap the join between maker and title.”**, button **“Next”**.
3. Title **“File the roll”**, body **“Parted paintings move to Saved with their marks.”**, button **“Continue”**.

**“Continue”** dismisses the welcome and opens the main roll. If the welcome was already finished, cold launch goes straight to the roll titled **“Split the caption”**.

## Screens

### Split the caption (main roll)
Navigation title **“Split the caption”**. Toolbar: **“Explore”** (leading), **“Saved”** and **“Settings”** (trailing). There are no tab bar labels; Explore, Saved, and Support open as sheets.

**When the roll is empty (“smooth”):**
- **“The roll is smooth.”**
- **“Save a painting, then split.”**
- Button **“Explore”** → opens **Keep a painting**.

**When there is work on the roll:**
- Instruction **“Tap Split between the maker and the title.”**
- Hero painting tile (image of the live work, or a placeholder; accessibility label is the painting title or **“Painting”**).
- Caption card:
  - Title is the painting title when a caption is glued, otherwise **“Glue a caption”**.
  - Line depends on state: **“Tap the join between maker and title.”** (glued), **“That join is filed. Glue the next caption.”** (parted), **“Glue a loose painting, then tap the true join.”** (idle), or **“Save a painting, then split.”** (smooth).
  - Words of the glued caption with **“Split”** between them. After a wrong join that button becomes **“Torn”** and no longer responds.
- **“Recently parted”** list (up to six titles). Empty copy: **“Parted paintings sit here after a filed join.”** Tapping a row opens **Saved**.
- Counters **“Filed joins”** and **“Wrong joins”**; tapping either opens **Saved**.
- **“Glue a caption”** (or **“Glue another”** after a filed join) when a loose painting is ready to glue.
- **“Retract newest mark”** when there is a newest filed or wrong mark.
- If saving failed: **“The roll did not save.”**, **“Your last change is still on screen.”**, button **“Retry save”**.

### Keep a painting (Explore sheet)
Navigation title **“Keep a painting”**. Close control labeled **“Close”**.

**Empty shelf:**
- **“The shelf is waiting.”**
- **“Load a painting, then file it for the split.”**
- **“Show local shelf”** fills the list from the built-in local shelf.

**Filing desk:**
- **“Keep this painting.”**
- **“The next tap files the painting on this device.”**
- Search field placeholder **“Painting or maker”**.
- **“File this painting”** files the selected work and closes the sheet (or keeps the sheet open and focuses an already-filed work).
- While searching: **“Looking up the shelf”**.
- On search failure: **“Search could not finish.”**, detail **“The catalog did not answer. The local shelf is still here.”**, button **“Retry”**.
- **“Pick another painting”** list: each row shows title, maker, and **“Ready to file”** or **“Already on the roll”**.

### Saved
Navigation title **“Saved”**. Close labeled **“Close”**.

**Empty:**
- **“Nothing parted yet.”**
- **“Split a caption on the roll.”**
- **“Back to the roll”** closes the sheet.

**Save failure with nothing listed:**
- **“Marks did not save.”**
- **“Retry keeps this list on the device.”**
- **“Retry save”**.

**With content:**
- Optional banner **“The roll did not save.”** with **“Retry save”**.
- **“Parted works”** (title, maker, day number).
- **“Filed joins”** rows labeled **“Filed”** plus painting title and day.
- **“Wrong joins”** rows labeled **“Wrong”** plus painting title and day. Missing title shows **“Work”**.

### Support (Settings sheet)
Navigation title **“Support”**. Close labeled **“Close”**.

- Heading **“Support”**, body **“Questions about this app go to support.”**
- **“Contact support”** opens the support page.
- Optional **“The roll did not save.”** with **“Retry save”**.
- Optional restore notes: **“Restored from the last good roll.”** or **“Started a fresh roll after a read miss.”**
- **“Sources”**: **“Isabella Stewart Gardner Museum”**, links **“Museum home”**, **“Collection”**, **“Wikidata Q49135”**.
- **“The roll”**:
  - **“Retract newest mark”** (only if a newest mark exists).
  - **“Replay the welcome”** (shows the three welcome pages again).
  - **“Erase the roll”** → confirmation **“Erase the roll”** with message **“This removes every painting, mark, and glued caption on this device.”**; confirm **“Erase the roll”** or cancel **“Keep it”**.

## Features
- Keep Gardner paintings on this device from a local shelf or search.
- Search by painting or maker.
- File a painting onto the roll.
- Glue maker and title into one caption.
- Tap **Split** on joins; the true join between maker and title files; other joins tear.
- See **Filed joins** and **Wrong joins** counts.
- Browse **Recently parted** and full **Saved** lists (**Parted works**, **Filed joins**, **Wrong joins**).
- Retract the newest mark.
- Replay the welcome.
- Erase the entire roll on this device.
- Contact support and open museum source links.
- Retry when the roll did not save.

## Behaviours that can look like bugs
- **“The roll is smooth.”** / **“Save a painting, then split.”** until at least one painting is filed via **Explore** → **“File this painting”**.
- **“Glue a caption”** / **“Glue another”** only appears when there is a loose painting ready and no caption is currently glued; there is no glue button while a caption is live.
- **“Split”** on the wrong join becomes **“Torn”** and stays disabled; keep tapping other live **“Split”** joins, or use **“Retract newest mark”**, then try again.
- Filing a painting already on the roll does not close **Keep a painting**; the row shows **“Already on the roll”**—pick another or close.
- Empty **Saved** (**“Nothing parted yet.”**) until a correct join is filed; use **“Back to the roll”**.
- Empty Explore (**“The shelf is waiting.”**) until **“Show local shelf”** or search loads rows.
- Search can show **“Search could not finish.”** while still listing the local shelf; use **“Retry”** or pick from the list.
- **“Retract newest mark”** only appears after at least one filed or wrong mark exists.
- **“Erase the roll”** asks for confirmation; choose **“Keep it”** to cancel, or confirm to clear everything and see the welcome again.

## Starter content and resume
Built-in local shelf (also used when search is empty or fails): **“The Concert”** (Johannes Vermeer), **“El Jaleo”** (John Singer Sargent), **“The Rape of Europa”** (Titian), **“Isabella Stewart Gardner”** (John Singer Sargent), **“Self Portrait Aged 23”** (Rembrandt), **“The Story of Lucretia”** (Botticelli).

On a Simulator first run with an empty roll, the app may open already used: several shelf paintings filed, some parted, a glued caption with at least one **“Torn”** join, and sample filed/wrong marks (welcome already finished).

Unfinished work resumes: filed paintings, glued captions, seams, marks, and welcome-finished state stay on the device across launches. **“Retract newest mark”** undoes the latest mark. **“Replay the welcome”** shows onboarding again without erasing the roll.

## Permissions
None. The app does not request camera, microphone, photos, location, or tracking access, and ships no usage-description strings for those.

## Absent
Genuinely absent: login or accounts, in-app purchase, ads, analytics, user-generated content shared with others, account deletion flow, App Tracking Transparency prompt.

Local **“Erase the roll”** clears on-device data only; it is not an account deletion flow.

## Data and support
Paintings, marks, and glued captions are kept on this device (welcome and erase copy say so). On-screen support control: **“Contact support”** on the Support sheet (opens the support page).

## Scanning and health
None. No barcode or QR scanning. No health, medical, or product-health information. Museum attribution lives under **“Sources”** on Support (**“Isabella Stewart Gardner Museum”**, **“Museum home”**, **“Collection”**, **“Wikidata Q49135”**).

## Platform
Light appearance only. Portrait only on iPhone and iPad. Minimum iOS 17.0. Count labels use the device’s number formatting; day stamps are plain calendar day numbers. No separate region-locked feature set beyond that.

## Category
Education
