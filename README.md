# openscad-models

Parametric OpenSCAD models and the libraries I wrote to support them.

## My Modules

| Library | What it is |
|---|---|
| [ikea-skadis](./libraries/ikea-skadis.md) | IKEA SKÅDIS pegboard primitives — surface-agnostic peg + staggered-grid placer matching the real two-grid 40 × 20 mm layout, 5 × 15 mm slots, 5.5 mm panel. Every mechanical dimension is overridable per call. MIT. |
| [container](./libraries/container.md) | Generic box with per-face layered styles (solid / hex / grid) and arbitrary cuts. Drop-in `insert()` reads the container's outer dimensions so the two stay in sync. MIT. |
| [modular-clip](./libraries/modular-clip.md) | Parametric spring edge-clip + standardised dovetail connector. Any clip mates with any holder — vary the clip body and holder geometry independently, the dovetail interface stays fixed. MIT. |

## Models

| Model | What it is |
|---|---|
| [skadis-container](./models/skadis-container/) | Wall-mountable parametric pegboard container with per-face styles (solid / hex / grid), parametric peg layout, tapered standoff bracket, and three drop-in inserts (pens, USB-A/C, rectangular compartments). |
| [skadis-mug-holder](./models/skadis-mug-holder/) | Open-front pegboard mug holder — back pegs, front handle slot, configurable per-side panel style. |
| [modular-clip-remote-holder](./models/modular-clip-remote-holder/) | Spring clip onto any thin edge + a slim cradle that holds a remote (default 34 × 7.5 mm). Cradle slides onto the clip via the [modular-clip](./libraries/modular-clip.md) dovetail. |
| [modular-clip-hook](./models/modular-clip-hook/) | L-hook accessory on the same modular-clip dovetail — cables, keys, headphones. Any modular-clip mates with any modular-clip accessory. |
| [usb-a-to-c-storage-adapter](./models/usb-a-to-c-storage-adapter/) | Parametric solid USB-A shell hollowed to a USB-C pocket — friction-fits into a USB-A storage slot to convert it. |

`test-prints/` — minimum-material fit-check pieces for the same designs.

Each model / test-print directory follows the same layout:

```
<name>/
  <name>.scad     parametric source
  preview/        previews + renders (.png)
  exports/        sliceable outputs (.stl / .3mf)
```

## Third-party libraries

Git submodules under `libraries/` — see `libraries/*.md` for upstream links
and licenses. The ones I lean on most: **BOSL2** (shapes, attachments,
threading), **NopSCADlib** (vitamins), **Round-Anything** (2D rounding),
**gridfinity-rebuilt-openscad** (Gridfinity).

A wider curated index lives in [AWESOME-OPENSCAD.md](./AWESOME-OPENSCAD.md);
miscellaneous references are in [RESOURCES.md](./RESOURCES.md).

## License

My modules under `libraries/ikea-skadis/`, `libraries/container/`, and
`libraries/modular-clip/` are MIT. Submodules retain their upstream licenses.
