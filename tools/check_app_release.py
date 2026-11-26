"""Release check for the phone app (the release pull request dev -> main).

    python -I tools/check_app_release.py [BASE [HEAD]]

BASE and HEAD are git revisions; the default, HEAD^1 and HEAD, is what the
pull request's merge commit brings into main (CI checks out that merge
commit). Locally: python -I tools/check_app_release.py origin/main dev

A release that changes anything in app/ starts the Codemagic builds
(codemagic.yaml). Once the iPhone workflow sends builds to App Review by
itself (submit_to_app_store: true, after version 1.0 was approved; todos
46e), each such build goes into a new App Store version named after
app/pubspec.yaml's version and is released once approved. Then this fails
the release pull request when app/ changed but:
  1. pubspec's version name (1.0.1 in "version: 1.0.1+5") did not go up:
     Apple refuses new builds for a version that is already live, so the
     iPhone upload would fail;
  2. release_notes.json (the App Store's "What's New" text) was not updated,
     so the new version would go out with the last version's notes.
While auto-submit is off (the first App Store version, sent by hand with
its in-app purchases), those two aren't required.
Always: fails when the version went down or release_notes.json is
malformed, and warns when codemagic.yaml changed without app/: Codemagic
builds anyway when its own file changed, so without a higher version the
iPhone upload fails and Play gets the same app again; cancel those builds
or raise the version.
"""

import json
import os
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PUBSPEC = "app/pubspec.yaml"
CODEMAGIC = "codemagic.yaml"
NOTES = "release_notes.json"
PRIMARY_LANGUAGE = "en-US"
MAX_NOTES = 4000  # App Store "What's New" limit


def pubspec_version(text):
    """The version name from pubspec.yaml: "version: 1.0.1+5" -> "1.0.1"."""
    match = re.search(r"^version:\s*([^\s+#]+)", text, re.MULTILINE)
    if not match:
        raise ValueError(f"no version line in {PUBSPEC}")
    return match.group(1)


def parse_version(text):
    """App Store versions are 1 to 3 dot-separated integers: "1.0" -> (1, 0, 0)."""
    parts = text.split(".")
    if not 1 <= len(parts) <= 3 or not all(p.isdigit() for p in parts):
        raise ValueError(f"not an App Store version: {text!r}")
    nums = tuple(int(p) for p in parts)
    return nums + (0,) * (3 - len(nums))


def auto_submits(codemagic_text):
    """True if codemagic.yaml sends iPhone builds to App Review by itself."""
    if codemagic_text is None:
        return False
    return re.search(r"^\s*submit_to_app_store:\s*true\b", codemagic_text, re.MULTILINE) is not None


def notes_errors(text):
    """Problems with release_notes.json (Codemagic's format), or []."""
    try:
        notes = json.loads(text)
    except ValueError as e:
        return [f"{NOTES} is not valid JSON: {e}"]
    if not isinstance(notes, list) or not all(isinstance(n, dict) for n in notes):
        return [f'{NOTES} must be a list like [{{"language": "{PRIMARY_LANGUAGE}", "text": "..."}}].']
    errors = []
    languages = []
    for note in notes:
        language, body = note.get("language"), note.get("text")
        if not isinstance(language, str) or not isinstance(body, str) or not body.strip():
            errors.append(f'Every entry in {NOTES} needs a "language" and a non-empty "text".')
            continue
        languages.append(language)
        if len(body) > MAX_NOTES:
            errors.append(f"The {language} text in {NOTES} is {len(body)} characters; the App Store allows {MAX_NOTES}.")
        if "<" in body or ">" in body:
            errors.append(f"The {language} text in {NOTES} contains < or >, which App Store Connect refuses.")
    if PRIMARY_LANGUAGE not in languages:
        errors.append(f"{NOTES} has no {PRIMARY_LANGUAGE} text (the app's primary language).")
    return errors


def check(base_pubspec, head_pubspec, changed, head_notes, auto_submit=True):
    """Returns (errors, warnings), each a list of messages."""
    errors, warnings = [], []
    app_changed = any(p.startswith("app/") for p in changed)
    if CODEMAGIC in changed and not app_changed:
        warnings.append(
            f"{CODEMAGIC} changed, so Codemagic starts both app builds after the merge even "
            "though app/ didn't change. Cancel them in Codemagic (the version wasn't raised, so the "
            "iPhone upload would fail and Play would get the same app again), or raise the version "
            f"in {PUBSPEC} and update {NOTES} to ship a release.")
    head_version = pubspec_version(head_pubspec)
    base_version = pubspec_version(base_pubspec) if base_pubspec is not None else None

    if base_version is not None:
        if parse_version(head_version) < parse_version(base_version):
            errors.append(f"The app version went down: {base_version} -> {head_version} ({PUBSPEC}).")
        elif auto_submit and app_changed and parse_version(head_version) == parse_version(base_version):
            errors.append(
                f"app/ changed, but the version in {PUBSPEC} is still {head_version}. Raise it "
                f"(e.g. {bump(head_version)}): Apple refuses new builds for a version that's already "
                "live, so the iPhone release would fail.")

    if head_notes is None:
        if auto_submit and app_changed:
            errors.append(f"{NOTES} is missing; it holds the App Store's \"What's New\" text.")
    else:
        errors += notes_errors(head_notes)
        if auto_submit and app_changed and NOTES not in changed:
            errors.append(
                f"app/ changed, but {NOTES} didn't: write this version's \"What's New\" text there, "
                "or the App Store shows the last version's notes.")
    return errors, warnings


def bump(version):
    """1.0.0 -> 1.0.1 (a suggestion for the error message)."""
    major, minor, patch = parse_version(version)
    return f"{major}.{minor}.{patch + 1}"


def git(*args):
    return subprocess.run(["git", *args], cwd=ROOT, check=True, capture_output=True, text=True).stdout


def show(rev, path):
    """The file at a revision, or None if it doesn't exist there."""
    try:
        return git("show", f"{rev}:{path}")
    except subprocess.CalledProcessError:
        return None


def annotate(kind, message):
    """A GitHub annotation in CI, plain text elsewhere."""
    if os.environ.get("GITHUB_ACTIONS") == "true":
        print(f"::{kind}::{message}")
    else:
        print(f"{kind.upper()}: {message}")


def main(argv):
    base, head = (argv + ["HEAD^1", "HEAD"][len(argv):])[:2]
    head_pubspec = show(head, PUBSPEC)
    changed = git("diff", "--name-only", base, head).split()
    auto_submit = auto_submits(show(head, CODEMAGIC))
    errors, warnings = check(show(base, PUBSPEC), head_pubspec, changed, show(head, NOTES), auto_submit)
    for message in warnings:
        annotate("warning", message)
    for message in errors:
        annotate("error", message)
    if not errors:
        mode = "App Review auto-submit on" if auto_submit else "App Review auto-submit off"
        print(f"App release check OK (version {pubspec_version(head_pubspec)}, {mode}).")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
