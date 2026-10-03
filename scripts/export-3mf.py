#!/usr/bin/env python3
"""Render an OpenSCAD/STL model into a verified Bambu-compatible Orca project."""

import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import xml.etree.ElementTree as ET
import zipfile


PROFILES = {
    "printer": "Bambu Lab A1 mini 0.4 nozzle",
    "process": "0.20mm Standard @BBL A1M",
    "filament": "Generic PETG @BBL A1M",
    "plate": "Textured PEI Plate",
}
DEFAULTS = {
    "wall_loops": "2",
    "sparse_infill_density": "15%",
    "sparse_infill_pattern": "gyroid",
    "enable_support": "1",
    "support_type": "tree(auto)",
}


def read_json(path):
    data = json.loads(path.read_text())
    if not isinstance(data, dict):
        raise ValueError(f"{path}: expected a JSON object")
    return data


def slicer_value(value):
    if isinstance(value, bool):
        return "1" if value else "0"
    if isinstance(value, (str, int, float)):
        return str(value)
    if isinstance(value, list):
        return [slicer_value(item) for item in value]
    raise ValueError(f"Unsupported setting value: {value!r}")


def configuration(source, explicit=None):
    folder = source.parent.parent if source.parent.name == "exports" else source.parent
    path = explicit if explicit is not None else folder / "3mf-settings.json"
    data = read_json(path) if explicit is not None or path.exists() else {}
    unknown = set(data) - set(PROFILES) - {"settings"}
    if unknown:
        raise ValueError(f"Unknown configuration fields: {sorted(unknown)}; put slicer keys inside 'settings'")
    names = {**PROFILES, **{k: v for k, v in data.items() if k in PROFILES}}
    if not all(isinstance(v, str) and v for v in names.values()):
        raise ValueError("Profile names and plate must be non-empty strings")
    overrides = data.get("settings", {})
    if not isinstance(overrides, dict):
        raise ValueError("'settings' must be an object")
    settings = {**DEFAULTS, **{k: slicer_value(v) for k, v in overrides.items()}}
    return names, settings, path if path.exists() else None


def find_profiles(explicit, slicer):
    if explicit:
        candidates = [explicit]
    else:
        executable = Path(slicer).resolve()
        candidates = [
            executable.parent / "resources/profiles/BBL",
            executable.parent.parent / "resources/profiles/BBL",
            Path("/opt/orca-slicer/resources/profiles/BBL"),
            Path("/usr/share/OrcaSlicer/profiles/BBL"),
            Path("/Applications/OrcaSlicer.app/Contents/Resources/profiles/BBL"),
        ]
    for candidate in candidates:
        if all((candidate / kind).is_dir() for kind in ("machine", "process", "filament")):
            return candidate
    raise ValueError("Cannot find Orca's BBL profiles; pass --profiles-dir /path/to/profiles/BBL")


def resolve_profile(root, kind, name, seen=()):
    if name in seen:
        raise ValueError(f"Profile inheritance cycle: {' -> '.join((*seen, name))}")
    path = root / kind / (name + ".json")
    if not path.is_file():
        raise ValueError(f"Missing {kind} profile: {path}")
    current = read_json(path)
    parent = current.get("inherits")
    resolved = resolve_profile(root, kind, parent, (*seen, name)) if parent else {}
    resolved.update(current)
    resolved.pop("inherits", None)
    return resolved


def run(command, work, timeout):
    result = subprocess.run(command, cwd=work, text=True, stdout=subprocess.PIPE,
                            stderr=subprocess.STDOUT, timeout=timeout)
    output = result.stdout
    # OpenSCAD can report assertion failures without a useful exit code.
    if result.returncode or "ERROR:" in output or "Ignoring unknown" in output:
        raise ValueError(f"{Path(command[0]).name} failed ({result.returncode}):\n{output[-6000:]}")
    return output


def check_settings(actual, expected):
    for key, value in expected.items():
        if key not in actual or slicer_value(actual[key]) != value:
            raise ValueError(f"Setting was lost or changed: {key}: expected {value!r}, got {actual.get(key)!r}")


def check_project(path, expected):
    with zipfile.ZipFile(path) as archive:
        check_settings(json.loads(archive.read("Metadata/project_settings.config")), expected)
        root = ET.fromstring(archive.read("3D/3dmodel.model"))
        if not root.findall("./{*}build/{*}item"):
            raise ValueError("Exported project has no printable objects")
        count = sum(len(ET.fromstring(archive.read(name)).findall(".//{*}triangle"))
                    for name in archive.namelist() if name.endswith(".model"))
        if count == 0:
            raise ValueError("Exported project has no mesh triangles")
        return count


def publish(source, destination):
    # Only replace a previous good export after all checks pass; same filesystem
    # rename is atomic, even if the temporary working directory is elsewhere.
    destination.parent.mkdir(parents=True, exist_ok=True)
    fd, temporary = tempfile.mkstemp(prefix=".export-", suffix=".3mf", dir=destination.parent)
    try:
        with os.fdopen(fd, "wb") as output, source.open("rb") as input_file:
            shutil.copyfileobj(input_file, output)
        os.replace(temporary, destination)
    finally:
        Path(temporary).unlink(missing_ok=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path, help=".scad or .stl file")
    parser.add_argument("-o", "--output", type=Path, help="default: model/exports/<source stem>.3mf")
    parser.add_argument("-D", "--define", action="append", default=[], help="OpenSCAD expression; repeatable")
    parser.add_argument("--settings", type=Path, help="explicit configuration (missing file is an error)")
    parser.add_argument("--profiles-dir", type=Path, help="OrcaSlicer profiles/BBL directory")
    parser.add_argument("--slicer", default="orca-slicer", help="OrcaSlicer CLI executable")
    parser.add_argument("--openscad", default="openscad", help="OpenSCAD executable")
    parser.add_argument("--timeout", type=int, default=600, help="timeout per CLI call, seconds (default: 600)")
    args = parser.parse_args()
    source = args.source.resolve()
    if not source.is_file() or source.suffix.lower() not in (".scad", ".stl"):
        raise ValueError("Source must be an existing .scad or .stl file")
    if source.suffix.lower() != ".scad" and args.define:
        raise ValueError("-D applies only to OpenSCAD sources")
    if args.timeout <= 0:
        raise ValueError("Timeout must be positive")
    folder = source.parent if source.parent.name == "exports" else source.parent / "exports"
    destination = (args.output or folder / (source.stem + ".3mf")).resolve()
    if destination.suffix.lower() != ".3mf":
        raise ValueError("Output must have a .3mf extension")
    names, settings, config_path = configuration(source, args.settings)
    slicer = shutil.which(args.slicer)
    if not slicer:
        raise ValueError(f"Slicer executable not found: {args.slicer}")
    root = find_profiles(args.profiles_dir, slicer)
    presets = {kind: resolve_profile(root, kind, names[key]) for kind, key in
               [("machine", "printer"), ("process", "process"), ("filament", "filament")]}
    for kind in ("process", "filament"):
        compatible = presets[kind].get("compatible_printers", [])
        if compatible and names["printer"] not in compatible:
            raise ValueError(f"{kind.capitalize()} is incompatible with printer; set matching 'printer', 'process' and 'filament' profiles")
    forbidden = set(settings) & {"name", "inherits", "type", "from", "instantiation", "print_settings_id"}
    if forbidden:
        raise ValueError(f"Reserved preset fields are not settings: {sorted(forbidden)}")
    presets["machine"]["printer_settings_id"] = names["printer"]
    presets["filament"]["filament_settings_id"] = [names["filament"]]
    presets["process"].update(settings)
    presets["process"]["name"] = f"{source.stem} - repository export"
    presets["process"]["from"] = "User"
    presets["process"]["print_settings_id"] = presets["process"]["name"]
    presets["process"]["curr_bed_type"] = names["plate"]
    expected = {**settings, "curr_bed_type": names["plate"], "printer_settings_id": names["printer"],
                "filament_settings_id": [names["filament"]]}
    print(f"Settings: {config_path or 'built-in defaults'}", flush=True)
    print(f"Printer: {names['printer']}; filament: {names['filament']}", flush=True)
    with tempfile.TemporaryDirectory(prefix="export-3mf-") as temporary:
        work = Path(temporary)
        mesh = source
        if source.suffix.lower() == ".scad":
            openscad = shutil.which(args.openscad)
            if not openscad:
                raise ValueError(f"OpenSCAD executable not found: {args.openscad}")
            mesh = work / (source.stem + ".stl")
            defines = [arg for value in args.define for arg in ("-D", value)]
            print("Rendering OpenSCAD…", flush=True)
            run([openscad, *defines, "-o", str(mesh), str(source)], work, args.timeout)
            if not mesh.is_file() or mesh.stat().st_size == 0:
                raise ValueError("OpenSCAD produced no mesh")
        for kind, data in presets.items():
            (work / (kind + ".json")).write_text(json.dumps(data))
        project = work / "project.3mf"
        base = [slicer, "--datadir", str(work / "slicer-data")]
        print("Exporting project…", flush=True)
        run([*base, "--load-settings", f"{work}/machine.json;{work}/process.json",
             "--load-filaments", str(work / "filament.json"), "--orient", "0", "--arrange", "1",
             "--export-3mf", str(project), str(mesh)], work, args.timeout)
        triangles = check_project(project, expected)
        print("Reopening and slice-checking project…", flush=True)
        reloaded = work / "reloaded.json"
        sliced = work / "slice"
        run([*base, "--slice", "0", "--outputdir", str(sliced), "--export-settings", str(reloaded),
             str(project)], work, args.timeout)
        check_settings(read_json(reloaded), expected)
        result = read_json(sliced / "result.json")
        if result.get("return_code") != 0 or not result.get("sliced_plates"):
            raise ValueError(f"Slice verification failed: {result}")
        gcodes = list(sliced.glob("*.gcode"))
        if not gcodes or any(p.stat().st_size == 0 for p in gcodes):
            raise ValueError("Slice verification produced no G-code")
        for plate in result["sliced_plates"]:
            if plate.get("warning_message"):
                print(f"Slicer warning: {plate['warning_message']}", file=sys.stderr)
        publish(project, destination)
    print(f"Saved {destination} ({triangles} triangles; {settings['wall_loops']} walls; "
          f"{settings['sparse_infill_density']} {settings['sparse_infill_pattern']}; "
          f"supports {'enabled' if settings['enable_support'] == '1' else 'disabled'})")


if __name__ == "__main__":
    try:
        main()
    except (ValueError, OSError, KeyError, ET.ParseError, zipfile.BadZipFile, subprocess.TimeoutExpired) as error:
        sys.exit(f"Export failed: {error}")
