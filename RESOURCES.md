# 3D Modeling Resources

A reference guide to tools, model repositories, and communities for 3D modeling and printing — with a focus on OpenSCAD.

---

## CAD / Modeling Software

### Parametric / Code-Based

| Tool | FOSS? | Platform | Description |
|------|-------|----------|-------------|
| **[OpenSCAD](https://openscad.org/)** | Yes (GPL) | Win/Mac/Linux | Programmer's CAD — write code to describe 3D geometry using CSG. The core of this project. |
| **[CadQuery](https://cadquery.readthedocs.io/)** | Yes (Apache 2.0) | Python | Python-based parametric CAD, similar concept to OpenSCAD but with BREP kernel (more powerful geometry). |
| **[ImplicitCAD](https://implicitcad.org/)** | Yes (AGPL) | Haskell/CLI | Haskell-based CSG modeler, compatible with much of OpenSCAD syntax but with implicit surfaces. |
| **[SolidPython](https://github.com/SolidCode/SolidPython)** | Yes (LGPL) | Python | Python frontend that generates OpenSCAD code. Write Python, get .scad output. |

### GUI-Based Parametric CAD

| Tool | FOSS? | Platform | Description |
|------|-------|----------|-------------|
| **[FreeCAD](https://www.freecad.org/)** | Yes (LGPL) | Win/Mac/Linux | Full parametric CAD with part design, assembly, FEM analysis. The leading FOSS GUI CAD. |
| **[Fusion 360](https://www.autodesk.com/products/fusion-360)** | No (free for personal use) | Win/Mac/Web | Professional parametric CAD, CAM, and simulation. Cloud-based. |
| **[Onshape](https://www.onshape.com/)** | No (free tier available) | Web | Browser-based professional CAD. Great collaboration features. |
| **[SolveSpace](https://solvespace.com/)** | Yes (GPL) | Win/Mac/Linux | Lightweight parametric 2D/3D CAD with constraint solver. |

### Mesh / Sculpting

| Tool | FOSS? | Platform | Description |
|------|-------|----------|-------------|
| **[Blender](https://www.blender.org/)** | Yes (GPL) | Win/Mac/Linux | Full 3D suite — modeling, sculpting, animation, rendering. Industry-grade and free. Best for organic shapes. |
| **[Meshmixer](https://meshmixer.com/)** | No (free) | Win/Mac | Mesh editing, repair, sculpting, and supports. Great for fixing STLs. Discontinued but still works. |
| **[Meshlab](https://www.meshlab.net/)** | Yes (GPL) | Win/Mac/Linux | Mesh processing — cleaning, repairing, converting, measuring. |
| **[ZBrush](https://www.maxon.net/en/zbrush)** | No (paid) | Win/Mac | Industry-standard digital sculpting. Best for figurines and organic detail. |
| **[Nomad Sculpt](https://nomadsculpt.com/)** | No (paid, cheap) | iOS/Android/Web | Mobile sculpting app, surprisingly powerful for the price. |

---

## Model Repositories

Where to find ready-made 3D models (STL, 3MF, OBJ, and sometimes .scad).

| Site | FOSS Models? | Cost | Description |
|------|-------------|------|-------------|
| **[Thingiverse](https://www.thingiverse.com/)** | Mostly (CC licenses) | Free | The original 3D printing model site. Huge library, aging infrastructure. Run by MakerBot/Stratasys. |
| **[Printables](https://www.printables.com/)** | Mostly (CC licenses) | Free | Prusa's model repository. Modern, well-maintained, active community. Rewards creators. |
| **[Thangs](https://thangs.com/)** | Mixed | Free | Aggregates models from multiple sources. Has geometric search (find similar shapes). |
| **[MyMiniFactory](https://www.myminifactory.com/)** | Mixed | Free + paid | Curated models, strong miniatures/figurines community. Some paid-only models. |
| **[Cults3D](https://cults3d.com/)** | Mixed | Free + paid | Large library with many paid designer models. |
| **[GrabCAD](https://grabcad.com/)** | Mixed | Free | Engineering/mechanical parts focus. Good for real-world component models. |
| **[NIH 3D Print Exchange](https://3d.nih.gov/)** | Yes (public domain) | Free | Scientific and medical models. |
| **[Yeggi](https://www.yeggi.com/)** | N/A (search engine) | Free | Meta-search engine that indexes multiple model repositories. |
| **[STLFinder](https://www.stlfinder.com/)** | N/A (search engine) | Free | Another meta-search engine for 3D models. |

---

## Slicers

Software that converts 3D models into G-code for 3D printers.

| Tool | FOSS? | Platform | Description |
|------|-------|----------|-------------|
| **[PrusaSlicer](https://github.com/prusa3d/PrusaSlicer)** | Yes (AGPL) | Win/Mac/Linux | Feature-rich slicer by Prusa. Excellent defaults, wide printer support. |
| **[OrcaSlicer](https://github.com/SoftFever/OrcaSlicer)** | Yes (AGPL) | Win/Mac/Linux | Fork of PrusaSlicer/BambuStudio with extra features. Very actively developed. |
| **[Bambu Studio](https://github.com/bambulab/BambuStudio)** | Yes (AGPL) | Win/Mac/Linux | Bambu Lab's slicer. Fork of PrusaSlicer optimised for Bambu printers. |
| **[Cura](https://github.com/Ultimaker/Cura)** | Yes (LGPL) | Win/Mac/Linux | Ultimaker's slicer. Huge plugin ecosystem, very customisable. |
| **[SuperSlicer](https://github.com/supermerill/SuperSlicer)** | Yes (AGPL) | Win/Mac/Linux | Fork of PrusaSlicer with additional tuning options. Less actively maintained now. |

---

## Mesh Tools & Converters

| Tool | FOSS? | Description |
|------|-------|-------------|
| **[Blender](https://www.blender.org/)** | Yes (GPL) | Import/export almost any format. Good for format conversion. |
| **[Meshlab](https://www.meshlab.net/)** | Yes (GPL) | Batch mesh processing, repair, format conversion. |
| **[Meshmixer](https://meshmixer.com/)** | No (free) | Mesh repair, hollowing, supports, boolean operations on meshes. |
| **[3MF Converter](https://3mf.io/)** | Spec is open | The 3MF Consortium provides tools and specs for the 3MF format. |
| **[Trimesh](https://trimesh.org/)** | Yes (MIT) | Python library for mesh processing — scripted conversion, analysis, repair. |
| **[OpenMesh](https://www.graphics.rwth-aachen.de/software/openmesh/)** | Yes (BSD) | C++/Python mesh processing library. |
| **[ADMesh](https://github.com/admesh/admesh)** | Yes (GPL) | CLI tool for STL repair, conversion, and analysis. |

---

## OpenSCAD-Specific Resources

| Resource | Description |
|----------|-------------|
| **[OpenSCAD Cheatsheet](https://openscad.org/cheatsheet/)** | Quick reference for all OpenSCAD functions and syntax. |
| **[OpenSCAD User Manual](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual)** | Comprehensive documentation on Wikibooks. |
| **[OpenSCAD Forum](https://forum.openscad.org/)** | Official community forum. |
| **[r/openscad](https://www.reddit.com/r/openscad/)** | Reddit community for OpenSCAD users. |
| **[BOSL2 Wiki](https://github.com/BelfrySCAD/BOSL2/wiki)** | Extensive documentation for the BOSL2 library (included in this repo). |
| **[OpenSCAD Customizer](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Customizer)** | Built-in GUI for parametric models — sliders, dropdowns, etc. |

---

## File Formats Reference

| Format | Type | OpenSCAD Import? | OpenSCAD Export? | Notes |
|--------|------|-----------------|-----------------|-------|
| **.scad** | Source | N/A | N/A | OpenSCAD source code (parametric) |
| **.stl** | Mesh | Yes | Yes | Most common 3D printing format |
| **.3mf** | Mesh | Yes | Yes | Modern replacement for STL, supports colour/materials |
| **.obj** | Mesh | Yes | Yes | Wavefront format, widely supported |
| **.amf** | Mesh | No | Yes | XML-based, supports colour/materials |
| **.off** | Mesh | Yes | Yes | Simple mesh format |
| **.dxf** | 2D Vector | Yes | Yes | 2D profiles — great for `linear_extrude()` |
| **.svg** | 2D Vector | Yes | Yes | 2D profiles — design in Inkscape, extrude in OpenSCAD |
| **.step/.stp** | BREP | No | No | Parametric CAD exchange format (FreeCAD, Fusion 360) |
| **.3ds** | Mesh | No | No | Legacy Autodesk format |
| **.ply** | Mesh | No | No | Point cloud / mesh with vertex colours |
| **.gcode** | Instructions | No | No | Printer instructions (output from slicers) |
