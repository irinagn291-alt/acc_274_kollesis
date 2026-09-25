# Kollesis

Kollesis is for people who already saved museum paintings and want to split a run-on tombstone into maker and title on this device. Home is the glued caption. You tap the seam between the two fields. There is no account, no shop, and no grade.

## Architecture

The roll is a closed fold: Idle, Glued, or Parted, plus Smooth when Glue cannot form a three-token run. One `RollStore` pattern-matches that fold. Views call `glueRoll()`, `splitSeam()`, and `peelNewestMark()`. They never keep a second status enum and never touch UserDefaults.

That suits a cataloguing job with one live caption. The painting either waits, sits glued, or has already parted. A boolean for parted-ness would drift from the fold.

Persistence is a Codable `RollDocument` written atomically to Application Support and projected into UserDefaults under `kol.roll.v1`. Decoding failure falls back to the backup, then an empty roll.

## Glue-then-split

Glue samples a saved work that is not Parted whose artist and title together hold at least three tokens. It writes a Volumen as artist then title, or title then artist, as one run, and hangs a Seam at every token joint. Split writes a SeamMark when the tapped Seam is the true field boundary and folds Glued to Parted. A miss writes a TearMark, cools that Seam, and keeps the Volumen. Split on Idle is refused. A second Glue while Glued is refused.

That is why someone would pick this app: the spaces stay, and the job is the cataloguing break, not restored word gaps and not a grid cell.

## Art

Style: 3D glass render, glassmorphism, studio-lit papyrus roll. Generated assets use the prompts in SPEC.md section 13. Base prompt:

```
3D glass render, glassmorphism, studio-lit papyrus roll, frosted glued kollesis seam, volumen of joined sheets, refraction and soft bloom, isolated subjects, quiet uncluttered ground, hospitable daylight not a gym, no text, no letters, no logo, no photoreal stock, no specified colours, one glued roll not a chip easel, not a vitrine grid, not an unspaced slab
```

Exact per-asset prompts match SPEC.md (`kol_AppIcon` through `kol_VolumenRod`).

## How this differs

This is not Stoichedon: spaces stay, and the tap is the field break. This is not Laterculus: there is no artist-by-title grid. This is not Anathyrosis: words are not shuffled. This is not Cartellino: you do not seat a whole artist chip then a whole title chip.

## Build

```bash
cd Kollesis
xcodegen generate
xcodebuild -scheme Kollesis -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build
```

Tests:

```bash
xcodebuild -scheme Kollesis -destination 'platform=iOS Simulator,name=iPhone 16' test
```

Contact: https://kollesis-roll.pro/contact-us
