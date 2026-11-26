"""Tests for tools/check_app_release.py.

    python -I tools/test_check_app_release.py
"""

import json
import subprocess
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import check_app_release as c  # noqa: E402

NOTES = json.dumps([{"language": "en-US", "text": "Bug fixes."}])


def pubspec(version):
    return f"name: baby_app\ndescription: Palna\npublish_to: none\nversion: {version}\n"


class Version(unittest.TestCase):
    def test_pubspec_version(self):
        self.assertEqual(c.pubspec_version(pubspec("1.0.1+5")), "1.0.1")
        self.assertEqual(c.pubspec_version(pubspec("2.3.0")), "2.3.0")
        with self.assertRaises(ValueError):
            c.pubspec_version("name: baby_app\n")

    def test_parse(self):
        self.assertEqual(c.parse_version("1.0"), (1, 0, 0))
        self.assertGreater(c.parse_version("1.0.10"), c.parse_version("1.0.9"))
        for bad in ["", "1.x", "1.2.3.4", "v1.0"]:
            with self.assertRaises(ValueError):
                c.parse_version(bad)

    def test_bump(self):
        self.assertEqual(c.bump("1.0.0"), "1.0.1")
        self.assertEqual(c.bump("1.2"), "1.2.1")


class AutoSubmit(unittest.TestCase):
    def test_flag(self):
        on = "publishing:\n  app_store_connect:\n    submit_to_testflight: false\n    submit_to_app_store: true\n"
        off = on.replace("submit_to_app_store: true", "submit_to_app_store: false")
        commented = on.replace("    submit_to_app_store: true", "    # submit_to_app_store: true")
        self.assertTrue(c.auto_submits(on))
        self.assertFalse(c.auto_submits(off))
        self.assertFalse(c.auto_submits(commented))
        self.assertFalse(c.auto_submits("workflows: {}\n"))
        self.assertFalse(c.auto_submits(None))


class Notes(unittest.TestCase):
    def test_ok(self):
        self.assertEqual(c.notes_errors(NOTES), [])

    def test_bad(self):
        cases = {
            "not json": "{",
            "not a list": json.dumps({"language": "en-US", "text": "x"}),
            "empty text": json.dumps([{"language": "en-US", "text": "  "}]),
            "no en-US": json.dumps([{"language": "en-GB", "text": "x"}]),
            "angle brackets": json.dumps([{"language": "en-US", "text": "Faster <3"}]),
            "too long": json.dumps([{"language": "en-US", "text": "x" * 4001}]),
        }
        for name, text in cases.items():
            with self.subTest(name):
                self.assertTrue(c.notes_errors(text))


def errs(*args, **kw):
    return c.check(*args, **kw)[0]


def warns(*args, **kw):
    return c.check(*args, **kw)[1]


class Check(unittest.TestCase):
    """With App Review auto-submit on (the default)."""

    def test_codemagic_yaml_alone_warns(self):
        args = (pubspec("1.0.0"), pubspec("1.0.0"), ["codemagic.yaml", "website/index.html"], NOTES)
        self.assertEqual(errs(*args), [])
        self.assertEqual(len(warns(*args)), 1)
        self.assertIn("Cancel", warns(*args)[0])

    def test_codemagic_yaml_with_app_release_does_not_warn(self):
        changed = ["codemagic.yaml", "app/lib/main.dart", "app/pubspec.yaml", "release_notes.json"]
        self.assertEqual(c.check(pubspec("1.0.0"), pubspec("1.0.1"), changed, NOTES), ([], []))

    def test_no_warning_without_codemagic_change(self):
        self.assertEqual(warns(pubspec("1.0.0"), pubspec("1.0.0"), ["website/index.html"], NOTES), [])

    def test_no_app_change(self):
        self.assertEqual(errs(pubspec("1.0.0+1"), pubspec("1.0.0+1"), ["website/index.html"], NOTES), [])

    def test_no_app_change_and_no_notes_yet(self):
        self.assertEqual(errs(pubspec("1.0.0+1"), pubspec("1.0.0+1"), ["website/index.html"], None), [])

    def test_app_change_with_bump_and_notes(self):
        changed = ["app/lib/main.dart", "app/pubspec.yaml", "release_notes.json"]
        self.assertEqual(errs(pubspec("1.0.0+1"), pubspec("1.0.1+1"), changed, NOTES), [])

    def test_app_change_without_bump(self):
        errors = errs(pubspec("1.0.0+1"), pubspec("1.0.0+1"), ["app/lib/main.dart", "release_notes.json"], NOTES)
        self.assertEqual(len(errors), 1)
        self.assertIn("still 1.0.0", errors[0])
        self.assertIn("1.0.1", errors[0])

    def test_build_number_alone_is_not_a_bump(self):
        changed = ["app/pubspec.yaml", "release_notes.json"]
        self.assertEqual(len(errs(pubspec("1.0.0+1"), pubspec("1.0.0+9"), changed, NOTES)), 1)

    def test_app_change_without_new_notes(self):
        errors = errs(pubspec("1.0.0"), pubspec("1.1.0"), ["app/lib/main.dart", "app/pubspec.yaml"], NOTES)
        self.assertEqual(len(errors), 1)
        self.assertIn("What's New", errors[0])

    def test_app_change_without_notes_file(self):
        errors = errs(pubspec("1.0.0"), pubspec("1.0.1"), ["app/lib/main.dart"], None)
        self.assertEqual(len(errors), 1)
        self.assertIn("missing", errors[0])

    def test_version_down(self):
        errors = errs(pubspec("1.1.0"), pubspec("1.0.9"), ["app/pubspec.yaml", "release_notes.json"], NOTES)
        self.assertEqual(len(errors), 1)
        self.assertIn("went down", errors[0])

    def test_bad_notes_fail_any_release(self):
        bad = json.dumps([{"language": "en-US", "text": ""}])
        self.assertTrue(errs(pubspec("1.0.0"), pubspec("1.0.0"), ["release_notes.json"], bad))

    def test_first_pubspec(self):
        self.assertEqual(errs(None, pubspec("1.0.0"), ["app/pubspec.yaml", "release_notes.json"], NOTES), [])


class CheckWithoutAutoSubmit(unittest.TestCase):
    """Before 1.0 is approved: builds only go to TestFlight."""

    def test_app_change_needs_no_bump_or_notes(self):
        self.assertEqual(errs(pubspec("1.0.0+1"), pubspec("1.0.0+1"), ["app/lib/main.dart"], None,
                              auto_submit=False), [])
        self.assertEqual(errs(pubspec("1.0.0+1"), pubspec("1.0.0+1"), ["app/lib/main.dart"], NOTES,
                              auto_submit=False), [])

    def test_still_refuses_a_lower_version_and_bad_notes(self):
        self.assertTrue(errs(pubspec("1.1.0"), pubspec("1.0.0"), ["app/pubspec.yaml"], NOTES, auto_submit=False))
        bad = json.dumps([{"language": "en-US", "text": ""}])
        self.assertTrue(errs(pubspec("1.0.0"), pubspec("1.0.0"), ["app/lib/main.dart"], bad, auto_submit=False))


class Repo(unittest.TestCase):
    def test_repo_files(self):
        """The repo's own pubspec and release notes parse."""
        c.parse_version(c.pubspec_version((c.ROOT / c.PUBSPEC).read_text(encoding="utf-8")))
        self.assertEqual(c.notes_errors((c.ROOT / c.NOTES).read_text(encoding="utf-8")), [])

    def test_cli_runs(self):
        result = subprocess.run(
            [sys.executable, "-I", str(c.ROOT / "tools" / "check_app_release.py"), "HEAD", "HEAD"],
            capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)


if __name__ == "__main__":
    unittest.main()
