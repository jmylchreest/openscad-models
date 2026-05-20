# modular-clip

- **Local path:** [./modular-clip/](./modular-clip/)
- **Author:** John Mylchreest <jmylchreest@gmail.com>
- **License:** [MIT](./modular-clip/LICENSE)

Two-part edge-clip system: a parametric spring clip and a standardised
dovetail connector. Any clip mates with any holder — vary the clip body
and the holder geometry independently; the dovetail interface stays
fixed so the parts always fit.

## What it provides

- `clip(grip_d, grip_h, width, wall_t, top_r, arm_extend, with_rail)` —
  parametric hairpin clip. Back arm at X=0, front arm at X=2·wall_t+grip_d,
  180° top fold connecting them. The front arm extends below the grip
  region by `arm_extend` mm; that extension carries a dovetail rail on
  its outer (+X) face.
- `dovetail_rail(length)` — positive trapezoid rail in the standard
  cross-section, standoff in +X, slide axis +Z.
- `dovetail_slot(length, open_ends, overcut)` — matching negative for
  `difference()`. `open_ends = "high"` (default) leaves the +Z end open
  so a holder slides DOWN onto the rail; the closed -Z end seats on the
  rail's bottom face and carries the holder under gravity.
- `modular_holder_back(width, height, wall_t, corner_r, slot_z_offset_from_top)`
  — reusable back-plate for accessories. A solid flat plate with the
  standard dovetail slot already cut. Sits in the +Y half-space (back
  face at Y=0, front face at Y=wall_t); accessories union their body in
  front of it. Use this exactly the way `skadis_peg` is used in
  ikea-skadis: drop it in, then add your accessory geometry off the +Y
  face. Width / height / thickness / corner radius are parametric; the
  slot dimensions are fixed by the dovetail interface.
- Accessor functions (`clip_dovetail_w_base()`, etc.) so `use<>`
  consumers can read the interface constants without copying values.

## Standard dovetail interface

These are fixed across every clip and every holder. Don't change them
per-model — that would break the mix-and-match guarantee.

| Constant | Value | Meaning |
|---|---|---|
| `CLIP_DOVETAIL_W_BASE`    | 12.0 mm | Rail base width (against mount surface) |
| `CLIP_DOVETAIL_W_TOP`     |  8.0 mm | Rail top width (narrower → locking taper) |
| `CLIP_DOVETAIL_D`         |  3.0 mm | Rail standoff (how proud it stands) |
| `CLIP_DOVETAIL_L`         | 20.0 mm | Rail length along the slide axis |
| `CLIP_DOVETAIL_CLEARANCE` |  0.25 mm | Slot is this much larger than rail per side |

## Frame

The clip is rendered with the top fold curving up into +Z and the arms
hanging in -Z; the gripped edge passes through in ±Y (so the clip's
width is along Y). The back arm sits at X=0, the front arm at
X = 2·wall_t + grip_d, and the dovetail rail stands on the front arm's
+X face, slide axis vertical.

A holder cuts its matching slot into the back face of its own body with
`dovetail_slot()` rotated `[0, 0, 90]` so the rail's standoff (library
+X) lines up with the holder's back-into-body direction (world +Y).

## Usage

```openscad
use <libraries/modular-clip/modular-clip.scad>

// Just the clip (with the rail).
clip(grip_d = 5, grip_h = 25, width = 30, arm_extend = 24);

// An accessory: take the back plate, union your geometry off its +Y face.
union() {
    modular_holder_back(width = 40, height = 60);
    // ...your hook / cradle / tray geometry, sitting in +Y past wall_t...
}
```

## Accessories in this repo

- [`models/modular-clip-remote-holder/`](../models/modular-clip-remote-holder/)
  — back plate + cradle for a 34 × 7.5 mm remote (or any similarly sized
  remote — all dimensions parametric).
- [`models/modular-clip-hook/`](../models/modular-clip-hook/)
  — back plate + L-hook for cables, keys, headphones, small bags.
