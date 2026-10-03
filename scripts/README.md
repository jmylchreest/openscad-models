# Exporting models with print settings

`export-3mf.py` turns an OpenSCAD source or STL into a **Bambu Studio / OrcaSlicer
project 3MF**, including the model, printer, filament and process settings. Requires
Python 3.10+, OpenSCAD (for `.scad` inputs), and OrcaSlicer with CLI support. Tested
locally with OpenSCAD 2021.01 and OrcaSlicer 2.4.2.

From the repository root:

```sh
python scripts/export-3mf.py models/washing-line-prop/washing-line-prop.scad \
  -D 'part="fit_test"' \
  -o models/washing-line-prop/exports/washing-line-prop-fit-test.3mf

python scripts/export-3mf.py models/washing-line-prop/washing-line-prop.scad \
  -D 'part="complete"'
```

The default output is `<model directory>/exports/<source name>.3mf`. An STL already
inside `exports/` writes the 3MF alongside it. Use `-o` for a different name or path.
Repeat `-D` to override OpenSCAD parameters; string values need the quotes shown
above. The source's other parameters are used as saved. Orientation is preserved;
objects are automatically arranged on the selected printer's bed.

## Small per-model settings file

Put **`3mf-settings.json` beside the `.scad` file**. For an STL inside `exports/`,
the script also reads it from the model directory. Only that directory is checked;
settings do not silently inherit from higher directories. `--settings path.json`
selects another file explicitly.

For example, the key overrides in the washing-line prop are:

```json
{
  "settings": {
    "wall_loops": 4,
    "sparse_infill_density": "30%",
    "enable_support": true,
    "support_type": "tree(auto)",
    "support_style": "tree_hybrid",
    "top_shell_layers": 6,
    "bottom_shell_layers": 6
  }
}
```

**With no file**, the script uses these defaults:

| Setting | Default |
|---|---|
| Walls | 2 loops |
| Sparse infill | 15% gyroid |
| Supports | Enabled, tree (auto) |
| Printer | Bambu Lab A1 mini, 0.4 mm nozzle |
| Process | 0.20 mm Standard @BBL A1M |
| Filament | Generic PETG @BBL A1M |
| Plate | Textured PEI Plate |

Unspecified process values come from the selected stock process. Auto support
means supports are generated where the slicer determines they are needed; a flat
model may generate none. The pole selects **Hybrid** tree supports for its supported
geometry. If you export it with `flat_print_face=true`, you can disable supports
in its settings file.

The `settings` object uses native Bambu/Orca configuration keys. Numbers and
booleans are accepted; keep percentages as strings such as `"30%"`. Settings are
checked after export and again after reopening; a discarded or changed setting
causes the export to fail instead of silently reverting to defaults.

To change printer, choose matching stock profile names, for example:

```json
{
  "printer": "Bambu Lab A1 0.4 nozzle",
  "process": "0.20mm Standard @BBL A1",
  "filament": "Generic PETG @BBL A1",
  "plate": "Textured PEI Plate",
  "settings": { "wall_loops": 3 }
}
```

These names are filenames without `.json` under Orca's `profiles/BBL/machine`,
`process` and `filament` directories. The script resolves profile inheritance and
checks declared compatibility. It does not modify installed or user presets.
For a nonstandard installation:

```sh
python scripts/export-3mf.py path/to/model.scad \
  --slicer /path/to/orca-slicer \
  --profiles-dir /path/to/resources/profiles/BBL
```

`--openscad` selects another OpenSCAD executable. `--timeout 1200` allows up to
1200 seconds per render/export/slice invocation (default 600).

## Verification and opening

Every export renders the source if needed, builds the project, checks that it
contains objects and mesh triangles, verifies requested settings, then **reopens
and slices the project** to check it can actually be processed. The generated
G-code is temporary verification output; the delivered file is an editable,
unsliced project, not a print-ready machine job. Review its preview before printing.

Only after verification succeeds does the script atomically replace the target
file. Missing explicitly requested settings, invalid JSON, missing profiles,
failed renders, incompatible slicing or changed settings leave the previous
export intact. CLI scratch files and logs stay in a temporary directory.

Open the result **as a project** in Bambu Studio to retain its settings. Importing
only geometry discards them. OpenSCAD's desktop 3MF export does not include these
settings; rerun this script after model changes instead.

Tests:

```sh
python -m unittest discover -s scripts -p 'test_*.py'
```
