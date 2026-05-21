# Awesome OpenSCAD

A curated list of OpenSCAD libraries, tools, resources, and communities.

> Star counts shown via [shields.io](https://shields.io) badges — they fetch live from GitHub on each render, so they stay current without editing this file.

---

## General Purpose Libraries

Libraries that extend OpenSCAD with broad sets of utilities, shapes, and tools.

| Library | Stars | FOSS? | Description |
|---------|-------|-------|-------------|
| [BOSL2](https://github.com/BelfrySCAD/BOSL2) | ![](https://img.shields.io/github/stars/BelfrySCAD/BOSL2?style=flat-square&label=&color=gray) | Yes (BSD) | **The standard library.** Shapes, masks, attachments, beziers, gears, threading, distributors, and more. If you install one library, make it this one. [Docs](https://github.com/BelfrySCAD/BOSL2/wiki) |
| [NopSCADlib](https://github.com/nophead/NopSCADlib) | ![](https://img.shields.io/github/stars/nophead/NopSCADlib?style=flat-square&label=&color=gray) | Yes (GPL) | Real-world parts (vitamins): screws, motors, PCBs, bearings, displays, fans, etc. Includes BOM generation and assembly framework. |
| [BOSL](https://github.com/revarbat/BOSL) | ![](https://img.shields.io/github/stars/revarbat/BOSL?style=flat-square&label=&color=gray) | Yes (BSD) | Predecessor to BOSL2. Still works, but BOSL2 is recommended for new projects. |
| [scad-utils](https://github.com/OskarLinde/scad-utils) | ![](https://img.shields.io/github/stars/OskarLinde/scad-utils?style=flat-square&label=&color=gray) | Yes | Foundational utilities — morphing, list comprehension, transformations. Many other libraries depend on this. |
| [MCAD](https://github.com/openscad/MCAD) | (official) | Yes (LGPL) | Ships with OpenSCAD. Basic shapes, math, hardware. Limited compared to BOSL2 but always available. |
| [relativity.scad](https://github.com/davidson16807/relativity.scad) | ![](https://img.shields.io/github/stars/davidson16807/relativity.scad?style=flat-square&label=&color=gray) | Yes | General library for relative positioning and attachment. |
| [OpenSCADutil](https://github.com/franpoli/OpenSCADutil) | ![](https://img.shields.io/github/stars/franpoli/OpenSCADutil?style=flat-square&label=&color=gray) | Yes | Shared libraries, modules, and scripts. |
| [omdl](https://github.com/royasutton/omdl) | ![](https://img.shields.io/github/stars/royasutton/omdl?style=flat-square&label=&color=gray) | Yes | Mechanical design library — shapes, tools, data tables. |
| [jl_scad](https://github.com/lijon/jl_scad) | ![](https://img.shields.io/github/stars/lijon/jl_scad?style=flat-square&label=&color=gray) | Yes | Utility library with various helpers. |
| [StoneAgeLib](https://github.com/Stone-Age-Sculptor/StoneAgeLib) | ![](https://img.shields.io/github/stars/Stone-Age-Sculptor/StoneAgeLib?style=flat-square&label=&color=gray) | Yes (PD) | Assorted useful OpenSCAD scripts. |

---

## Geometry & Shapes

Libraries for fillets, rounding, smooth surfaces, and complex geometry.

| Library | Stars | Description |
|---------|-------|-------------|
| [Round-Anything](https://github.com/Irev-Dev/Round-Anything) | ![](https://img.shields.io/github/stars/Irev-Dev/Round-Anything?style=flat-square&label=&color=gray) | Fillets and radii made easy. Robust approach to rounded edges and smooth transitions. |
| [pathbuilder](https://github.com/dinther/pathbuilder) | ![](https://img.shields.io/github/stars/dinther/pathbuilder?style=flat-square&label=&color=gray) | Visual tool for creating complex 2D shapes, exportable to OpenSCAD. |
| [smooth-prim](https://github.com/rcolyer/smooth-prim) | ![](https://img.shields.io/github/stars/rcolyer/smooth-prim?style=flat-square&label=&color=gray) | Smooth primitives — rounded cubes, cylinders, etc. |
| [closepoints](https://github.com/rcolyer/closepoints) | ![](https://img.shields.io/github/stars/rcolyer/closepoints?style=flat-square&label=&color=gray) | Create closed surfaces from point sets. |
| [plot-function](https://github.com/rcolyer/plot-function) | ![](https://img.shields.io/github/stars/rcolyer/plot-function?style=flat-square&label=&color=gray) | Plot mathematical functions as 3D geometry. |

---

## Mechanical / Hardware

Threads, fasteners, gears, and mechanical components.

| Library | Stars | Description |
|---------|-------|-------------|
| [threadlib](https://github.com/adrianschlatter/threadlib) | ![](https://img.shields.io/github/stars/adrianschlatter/threadlib?style=flat-square&label=&color=gray) | Standards-compliant threads: metric, BSP, UNC, UNF, UNEF, PCO (bottle caps), RMS. |
| [nutsnbolts](https://github.com/JohK/nutsnbolts) | ![](https://img.shields.io/github/stars/JohK/nutsnbolts?style=flat-square&label=&color=gray) | Parametric nuts, bolts, screw holes, and nut catches. |
| [threads-scad](https://github.com/rcolyer/threads-scad) | ![](https://img.shields.io/github/stars/rcolyer/threads-scad?style=flat-square&label=&color=gray) | Another popular threading library. Used by gridfinity-rebuilt. |
| [PolyGear](https://github.com/dpellegr/PolyGear) | ![](https://img.shields.io/github/stars/dpellegr/PolyGear?style=flat-square&label=&color=gray) | Involute gear library with accurate tooth profiles. |
| [lego_gears](https://github.com/miklasiu/lego_gears) | ![](https://img.shields.io/github/stars/miklasiu/lego_gears?style=flat-square&label=&color=gray) | LEGO-compatible gear generator. |

---

## Storage & Organisation

Gridfinity, trays, and storage solutions.

| Library | Stars | Description |
|---------|-------|-------------|
| [gridfinity-rebuilt-openscad](https://github.com/kennetek/gridfinity-rebuilt-openscad) | ![](https://img.shields.io/github/stars/kennetek/gridfinity-rebuilt-openscad?style=flat-square&label=&color=gray) | **The most popular OpenSCAD project.** Fully parametric Gridfinity bins — any size, compartments, scoop, tabs, magnet holes, lip, vase mode. [Docs](https://kennetek.github.io/gridfinity-rebuilt-openscad/) |
| [gridfinity_extended_openscad](https://github.com/ostat/gridfinity_extended_openscad) | ![](https://img.shields.io/github/stars/ostat/gridfinity_extended_openscad?style=flat-square&label=&color=gray) | Extended Gridfinity with additional features and options. |
| [gridfinity_openscad](https://github.com/vector76/gridfinity_openscad) | ![](https://img.shields.io/github/stars/vector76/gridfinity_openscad?style=flat-square&label=&color=gray) | Another Gridfinity implementation. |
| [GridFlock](https://github.com/yawkat/GridFlock) | ![](https://img.shields.io/github/stars/yawkat/GridFlock?style=flat-square&label=&color=gray) | Gridfinity-compatible baseplate generator with puzzle connectors. |
| [openscad-tray](https://github.com/sofian/openscad-tray) | ![](https://img.shields.io/github/stars/sofian/openscad-tray?style=flat-square&label=&color=gray) | Rounded rectangular trays with optional subdividers. |

---

## LEGO & Building Blocks

| Library | Stars | Description |
|---------|-------|-------------|
| [LEGO.scad](https://github.com/cfinke/LEGO.scad) | ![](https://img.shields.io/github/stars/cfinke/LEGO.scad?style=flat-square&label=&color=gray) | LEGO-compatible brick generator — bricks, plates, tiles, and more. |
| [Technic.scad](https://github.com/cfinke/Technic.scad) | ![](https://img.shields.io/github/stars/cfinke/Technic.scad?style=flat-square&label=&color=gray) | LEGO Technic-compatible pieces — beams, pins, axles. |
| [openscad-ldraw](https://github.com/schiele/openscad-ldraw) | ![](https://img.shields.io/github/stars/schiele/openscad-ldraw?style=flat-square&label=&color=gray) | Entire LDraw.org parts library (35k+ files) converted to OpenSCAD. |
| [openBrick](https://github.com/cwesson/openBrick) | ![](https://img.shields.io/github/stars/cwesson/openBrick?style=flat-square&label=&color=gray) | Snap-together toy building blocks. |
| [Lego-compatible](https://github.com/brandonhill/Lego-compatible) | ![](https://img.shields.io/github/stars/brandonhill/Lego-compatible?style=flat-square&label=&color=gray) | Parametric LEGO-compatible brick for 3D printing. |
| [brickify](https://github.com/richfelker/brickify) | ![](https://img.shields.io/github/stars/richfelker/brickify?style=flat-square&label=&color=gray) | Simple module for LEGO/DUPLO compatible bricks. |
| [bitbeam-lib](https://github.com/ondratu/bitbeam-lib) | ![](https://img.shields.io/github/stars/ondratu/bitbeam-lib?style=flat-square&label=&color=gray) | Bitbeam (LEGO Technic-compatible) construction system. |

---

## Domain-Specific

| Library | Stars | Description |
|---------|-------|-------------|
| [The-Boardgame-Insert-Toolkit](https://github.com/dppdppd/The-Boardgame-Insert-Toolkit) | ![](https://img.shields.io/github/stars/dppdppd/The-Boardgame-Insert-Toolkit?style=flat-square&label=&color=gray) | Board game box inserts with lids. No programming required — just define dimensions. |
| [text_on_OpenSCAD](https://github.com/brodykenrick/text_on_OpenSCAD) | ![](https://img.shields.io/github/stars/brodykenrick/text_on_OpenSCAD?style=flat-square&label=&color=gray) | Text on curved and 3D surfaces with font/language/direction control. |
| [tryadactyl](https://github.com/wolfwood/tryadactyl) | ![](https://img.shields.io/github/stars/wolfwood/tryadactyl?style=flat-square&label=&color=gray) | Custom concave split keyboard (Dactyl) design system. |
| [OpenSCAD-Arduino-Mounting-Library](https://github.com/kellyegan/OpenSCAD-Arduino-Mounting-Library) | ![](https://img.shields.io/github/stars/kellyegan/OpenSCAD-Arduino-Mounting-Library?style=flat-square&label=&color=gray) | Arduino enclosures and mounting brackets. |
| [openscad-rpi-library](https://github.com/RigacciOrg/openscad-rpi-library) | ![](https://img.shields.io/github/stars/RigacciOrg/openscad-rpi-library?style=flat-square&label=&color=gray) | Raspberry Pi enclosures and mounts. |
| [puzzlecad](https://github.com/aaron-siegel/puzzlecad) | ![](https://img.shields.io/github/stars/aaron-siegel/puzzlecad?style=flat-square&label=&color=gray) | Mechanical puzzle design library. |
| [pegmixer](https://github.com/stockholmux/pegmixer) | ![](https://img.shields.io/github/stars/stockholmux/pegmixer?style=flat-square&label=&color=gray) | Pegboard accessories generator. |
| [celtic-knot-scad](https://github.com/beanz/celtic-knot-scad) | ![](https://img.shields.io/github/stars/beanz/celtic-knot-scad?style=flat-square&label=&color=gray) | Celtic knot pattern generator. |
| [OpenSCAD-Dovetails](https://github.com/cfinke/OpenSCAD-Dovetails) | ![](https://img.shields.io/github/stars/cfinke/OpenSCAD-Dovetails?style=flat-square&label=&color=gray) | Dovetail joint generator. |

---

## Alternative OpenSCAD Frontends & Forks

Write OpenSCAD models using other languages or enhanced tools.

| Tool | Stars | Language | Description |
|------|-------|----------|-------------|
| [SolidPython](https://github.com/SolidCode/SolidPython) | ![](https://img.shields.io/github/stars/SolidCode/SolidPython?style=flat-square&label=&color=gray) | Python | Write Python, output .scad. Pythonic syntax for OpenSCAD. |
| [CadQuery](https://github.com/CadQuery/cadquery) | ![](https://img.shields.io/github/stars/CadQuery/cadquery?style=flat-square&label=&color=gray) | Python | Python parametric CAD with BREP kernel. More powerful geometry than OpenSCAD. [Docs](https://cadquery.readthedocs.io/) |
| [ImplicitCAD](https://github.com/Haskell-Things/ImplicitCAD) | ![](https://img.shields.io/github/stars/Haskell-Things/ImplicitCAD?style=flat-square&label=&color=gray) | Haskell | Haskell-based CSG, partially compatible with OpenSCAD syntax. Implicit surfaces. [Site](https://implicitcad.org/) |
| [OpenSCAD2](https://github.com/openscad/openscad2) | ![](https://img.shields.io/github/stars/openscad/openscad2?style=flat-square&label=&color=gray) | — | Next-generation OpenSCAD (in development). |

---

## OpenSCAD Tools

| Tool | Description |
|------|-------------|
| [OpenSCAD Customizer](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Customizer) | Built-in GUI for parametric models — generates sliders, dropdowns, and checkboxes from special comments. |
| [Thingiverse Customizer](https://www.thingiverse.com/apps/customizer) | Online customizer for OpenSCAD files hosted on Thingiverse. |
| [BGSD](https://github.com/dppdppd/BGSD) | Visual editor for The Boardgame Insert Toolkit. |

---

## Learning Resources

| Resource | Description |
|----------|-------------|
| [OpenSCAD Cheatsheet](https://openscad.org/cheatsheet/) | Quick reference card for all functions and syntax. |
| [OpenSCAD User Manual](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual) | Comprehensive documentation on Wikibooks. |
| [BOSL2 Wiki](https://github.com/BelfrySCAD/BOSL2/wiki) | Extensive documentation and tutorials for BOSL2. |
| [OpenSCAD Forum](https://forum.openscad.org/) | Official community forum. |
| [r/openscad](https://www.reddit.com/r/openscad/) | Reddit community. |
| [OpenSCAD on YouTube](https://www.youtube.com/results?search_query=openscad+tutorial) | Video tutorials from the community. |

---

## Model Repositories

Where to find ready-made models (STL, 3MF, OBJ, and sometimes .scad).

| Site | FOSS? | Description |
|------|-------|-------------|
| [Printables](https://www.printables.com/) | Mostly CC | Prusa's repository. Modern, well-maintained, rewards creators. **Search for .scad files specifically.** |
| [Thingiverse](https://www.thingiverse.com/) | Mostly CC | The original. Huge library, aging infrastructure. Many OpenSCAD Customizer models. |
| [Thangs](https://thangs.com/) | Mixed | Aggregator with geometric search (find similar shapes). |
| [MyMiniFactory](https://www.myminifactory.com/) | Mixed | Strong miniatures/figurines community. |
| [Cults3D](https://cults3d.com/) | Mixed | Many paid designer models. |
| [GrabCAD](https://grabcad.com/) | Mixed | Engineering/mechanical focus. |
| [Yeggi](https://www.yeggi.com/) | Search engine | Meta-search across multiple model sites. |
| [STLFinder](https://www.stlfinder.com/) | Search engine | Another meta-search engine. |

---

## Other Awesome Lists

| List | Description |
|------|-------------|
| [dahoo/awesome-openscad](https://github.com/dahoo/awesome-openscad) | Another awesome-openscad list (smaller, less maintained). |
| [42sol/awesome_list_openscad](https://github.com/42sol/19o1_awesome_list_openscad) | Community-maintained list. |

---

## Included in This Repo

The following libraries are included as git submodules in `libraries/`:

| Library | Category |
|---------|----------|
| [BOSL2](libraries/BOSL2/) | General purpose |
| [NopSCADlib](libraries/NopSCADlib/) | General purpose / vitamins |
| [scad-utils](libraries/scad-utils/) | General purpose / utilities |
| [Round-Anything](libraries/Round-Anything/) | Geometry |
| [threadlib](libraries/threadlib/) | Mechanical |
| [gridfinity-rebuilt-openscad](libraries/gridfinity-rebuilt-openscad/) | Storage |
| [LEGO.scad](libraries/LEGO.scad/) | LEGO |
| [Technic.scad](libraries/Technic.scad/) | LEGO Technic |
| [openscad-ldraw](libraries/openscad-ldraw/) | LEGO (LDraw parts) |
| [The-Boardgame-Insert-Toolkit](libraries/The-Boardgame-Insert-Toolkit/) | Board games |

To clone with all libraries:
```bash
git clone --recurse-submodules <repo-url>
```

To update all libraries to latest:
```bash
./scripts/update-libraries.sh
```
