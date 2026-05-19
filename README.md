# openscad-models

Parametric OpenSCAD models and the libraries I wrote to support them.

## My Modules

| Library | What it is |
|---|---|
| [ikea-skadis](./libraries/ikea-skadis.md) | IKEA SKÅDIS pegboard primitives — surface-agnostic peg + staggered-grid placer matching the real two-grid 40 × 20 mm layout, 5 × 15 mm slots, 5.5 mm panel. Every mechanical dimension is overridable per call. MIT. |
| [container](./libraries/container.md) | Generic box with per-face layered styles (solid / hex / grid) and arbitrary cuts. Drop-in `insert()` reads the container's outer dimensions so the two stay in sync. MIT. |

## Models

`models/` — finished parametric models that compose the libraries above
(Skadis containers, mug holders, USB adapters, …). `test-prints/` —
minimum-material fit-check pieces for the same designs.

Each directory follows the same layout:

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

My modules under `libraries/ikea-skadis/` and `libraries/container/` are MIT.
Submodules retain their upstream licenses.
