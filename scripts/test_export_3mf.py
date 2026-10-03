"""Run with: python -m unittest discover -s scripts -p 'test_*.py'."""

import importlib.util
import json
from pathlib import Path
import tempfile
import unittest
import zipfile

spec = importlib.util.spec_from_file_location("export_3mf", Path(__file__).with_name("export-3mf.py"))
export = importlib.util.module_from_spec(spec)
spec.loader.exec_module(export)


class ExportTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        self.source = self.root / "model.scad"

    def write(self, path, data):
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(json.dumps(data))

    def test_missing_config_uses_shared_defaults(self):
        names, settings, path = export.configuration(self.source)
        self.assertIsNone(path)
        self.assertEqual(settings["wall_loops"], "2")
        self.assertEqual(settings["sparse_infill_density"], "15%")
        self.assertEqual(settings["sparse_infill_pattern"], "gyroid")
        self.assertEqual(settings["enable_support"], "1")
        self.assertEqual(settings["support_type"], "tree(auto)")

    def test_partial_config_and_stl_in_exports(self):
        self.write(self.root / "3mf-settings.json", {"settings": {
            "wall_loops": 4, "sparse_infill_density": "30%", "enable_support": False}})
        _, settings, path = export.configuration(self.root / "exports/model.stl")
        self.assertEqual(path, self.root / "3mf-settings.json")
        self.assertEqual(settings["wall_loops"], "4")
        self.assertEqual(settings["enable_support"], "0")
        self.assertEqual(settings["sparse_infill_pattern"], "gyroid")
        self.assertEqual(export.DEFAULTS["wall_loops"], "2")

    def test_explicit_missing_config_is_error(self):
        with self.assertRaises(FileNotFoundError):
            export.configuration(self.source, self.root / "missing.json")

    def test_typo_and_malformed_config_are_errors(self):
        path = self.root / "3mf-settings.json"
        for data in ({"wall_loop": 4}, {"settings": []}, []):
            self.write(path, data)
            with self.assertRaises(ValueError):
                export.configuration(self.source)
        path.write_text('{"settings":')
        with self.assertRaises(ValueError):
            export.configuration(self.source)

    def test_profile_inheritance_and_missing_parent(self):
        self.write(self.root / "process/base.json", {"wall_loops": "2", "layer_height": "0.2"})
        self.write(self.root / "process/child.json", {"inherits": "base", "wall_loops": "4"})
        actual = export.resolve_profile(self.root, "process", "child")
        self.assertEqual(actual, {"wall_loops": "4", "layer_height": "0.2"})
        (self.root / "process/base.json").unlink()
        with self.assertRaisesRegex(ValueError, "Missing"):
            export.resolve_profile(self.root, "process", "child")

    def test_profile_cycle_is_error(self):
        self.write(self.root / "process/a.json", {"inherits": "b"})
        self.write(self.root / "process/b.json", {"inherits": "a"})
        with self.assertRaisesRegex(ValueError, "cycle"):
            export.resolve_profile(self.root, "process", "a")

    def test_export_without_geometry_is_rejected(self):
        path = self.root / "empty.3mf"
        with zipfile.ZipFile(path, "w") as archive:
            archive.writestr("Metadata/project_settings.config", json.dumps(export.DEFAULTS))
            archive.writestr("3D/3dmodel.model", '<model><resources/><build/></model>')
        with self.assertRaisesRegex(ValueError, "no printable objects"):
            export.check_project(path, export.DEFAULTS)

    def test_missing_or_changed_settings_are_rejected(self):
        for actual in ({}, {"wall_loops": "2"}):
            with self.assertRaisesRegex(ValueError, "lost or changed"):
                export.check_settings(actual, {"wall_loops": "4"})

    def test_failed_publish_preserves_previous_file(self):
        destination = self.root / "model.3mf"
        destination.write_bytes(b"previous good export")
        with self.assertRaises(FileNotFoundError):
            export.publish(self.root / "missing.3mf", destination)
        self.assertEqual(destination.read_bytes(), b"previous good export")
        self.assertEqual(list(self.root.glob(".export-*")), [])


if __name__ == "__main__":
    unittest.main()
