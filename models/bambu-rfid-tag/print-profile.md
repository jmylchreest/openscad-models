# Print profile — bambu-rfid-tag

A tuned slicer profile lives next to the model in [`print-profile-orca.json`](./print-profile-orca.json). It's a process profile compatible with **OrcaSlicer** and **Bambu Studio**.

## What it changes vs the stock X1C 0.10 mm profile

| Setting | Value | Why |
|---|---|---|
| Wall loops | 3 | Posts and post halves get full perimeter coverage; no infill-dependent strength |
| Bottom shell layers | 5 | Disc bed surface stays clean and rigid; first 0.5 mm well-bonded |
| Top shell layers | 5 | Smooth sticker recess top |
| Sparse infill density | 100% | The model is almost all walls anyway |
| Sparse infill pattern | concentric | Fills the small disc area cleanly |
| Outer wall speed | 30 mm/s | Slow enough that the clip details land crisply |
| Inner wall speed | 50 mm/s | Slows the post halves to give clean perimeter bonds |
| Top surface speed | 30 mm/s | Clean sticker recess floor |
| Initial layer speed | 20 mm/s | First layer adhesion and disc→post layer bonding |
| Initial layer infill speed | 50 mm/s | First-layer fill at moderate speed |
| Wall generator | arachne | Variable line width fits the 0.4 mm slit cleanly |
| Wall transition length | 0.4 mm | Smoother arachne transitions on the small clip features |
| Elephant foot compensation | 0.1 mm | The disc has a flat bed contact, small compensation keeps the edge clean |
| Detect thin wall | on | Picks up the slit-side perimeters |
| Skirt loops | 2 | Priming line for the small part |

## How to import

**OrcaSlicer / Bambu Studio**:

1. Open the slicer with your target printer selected
2. Process / Print Settings panel → click the dropdown next to the profile name
3. "Import preset…" (or the ⋯ menu → "Import preset")
4. Pick `print-profile-orca.json`
5. Select the new profile (`0.10mm RFID Tag Holder`) when slicing this model

## Adapting to other printers

The `inherits` field points at the **X1C 0.2 nozzle 0.10 mm** stock profile. If you're on a different setup, edit `inherits` before importing:

| Printer | `inherits` value |
|---|---|
| Bambu X1C (0.2 nozzle) | `0.10mm Standard @BBL X1C 0.2 nozzle` (default) |
| Bambu P1S (0.2 nozzle) | `0.10mm Standard @BBL P1P 0.2 nozzle` |
| Bambu A1 (0.2 nozzle) | `0.10mm Standard @BBL A1 0.2 nozzle` |
| Bambu A1 mini (0.2 nozzle) | `0.10mm Standard @BBL A1M 0.2 nozzle` |

If you're using a 0.4 nozzle instead (geometry isn't ideal for that — see the design notes in [`bambu-rfid-tag.scad`](./bambu-rfid-tag.scad)), use the matching 0.20 mm parent profile and bump the slit width back to 0.8 mm.

## Filament-side recommendations

Process profile can't override filament temperature or fan — set these on your filament profile (or use a per-object modifier in the slicer):

- **Hotend temperature**: +5 °C above your normal PLA target (e.g. 220 °C if you usually print at 215). Stronger inter-layer adhesion = less risk of the posts snapping off at the disc.
- **Fan**: drop to 50–60 % on the post layers (Z ≈ 1.2–3.0 mm in print orientation). Bambu Studio's "auxiliary fan" can be set to "Off for first N layers" — set N ≥ 30 to cover the disc + post layers at 0.1 mm height.
- **Anneal (optional)**: 60 °C oven for 30 min after printing. Significantly improves PLA inter-layer strength.
