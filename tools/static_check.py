#!/usr/bin/env python3
"""Lightweight repository checks for environments without Flutter/Dart SDK.

This script does not replace `flutter analyze`, but catches common regressions:
- missing Dart imports
- UI BLoCs used without providers/factories
- empty onPressed/onTap callbacks

Usage:
    python3 tools/static_check.py
"""
from __future__ import annotations

import os
import re
import sys
from pathlib import Path

try:
    import yaml  # type: ignore
except Exception:  # pragma: no cover
    yaml = None

ROOT = Path(__file__).resolve().parents[1]
LIB = ROOT / "lib"


def read_pubspec() -> dict:
    if yaml is None:
        return {}
    with (ROOT / "pubspec.yaml").open(encoding="utf-8") as fp:
        return yaml.safe_load(fp) or {}


def dart_files():
    for path in LIB.rglob("*.dart"):
        yield path


def check_imports() -> list[str]:
    pubspec = read_pubspec()
    known = {"dart", "flutter", pubspec.get("name", "")}
    known.update((pubspec.get("dependencies") or {}).keys())
    known.update((pubspec.get("dev_dependencies") or {}).keys())

    issues: list[str] = []
    for path in dart_files():
        text = path.read_text(encoding="utf-8")
        for imp in re.findall(r"import\s+'([^']+)'", text):
            if imp.startswith("dart:"):
                continue
            if imp.startswith("package:"):
                pkg = imp.split("/")[0].split(":")[1]
                if pkg == pubspec.get("name"):
                    local = LIB / "/".join(imp.split("/")[1:])
                    if not local.exists():
                        issues.append(f"missing package import: {path.relative_to(ROOT)} -> {imp}")
                elif pkg not in known:
                    issues.append(f"package not in pubspec: {path.relative_to(ROOT)} -> {imp}")
            else:
                target = (path.parent / imp).resolve()
                if not target.exists():
                    issues.append(f"missing relative import: {path.relative_to(ROOT)} -> {imp}")
    return issues


def check_bloc_wiring() -> list[str]:
    main = (LIB / "main.dart").read_text(encoding="utf-8")
    di = (LIB / "core/di/injection_container.dart").read_text(encoding="utf-8")

    providers = set(re.findall(r"BlocProvider<([A-Za-z0-9_]+)>", main))
    factories = set(re.findall(r"getIt\.registerFactory\(\(\)\s*=>\s*([A-Za-z0-9_]+)\s*\(", di))

    used: set[str] = set()
    for path in dart_files():
        text = path.read_text(encoding="utf-8")
        for tup in re.findall(
            r"context\.(?:read|watch)<([A-Za-z0-9_]+)>|"
            r"BlocBuilder<([A-Za-z0-9_]+)\s*,|"
            r"BlocListener<([A-Za-z0-9_]+)\s*,",
            text,
        ):
            used.update(value for value in tup if value)

    issues: list[str] = []
    for bloc in sorted(used - providers):
        issues.append(f"missing BlocProvider in main.dart: {bloc}")
    for bloc in sorted(used - factories):
        issues.append(f"missing getIt factory in injection_container.dart: {bloc}")
    return issues


def check_empty_callbacks() -> list[str]:
    issues: list[str] = []
    pattern = re.compile(r"on(?:Pressed|Tap):\s*\(\)\s*\{\s*\}")
    for path in dart_files():
        for line_no, line in enumerate(path.read_text(encoding="utf-8").splitlines(), start=1):
            if pattern.search(line):
                issues.append(f"empty callback: {path.relative_to(ROOT)}:{line_no}: {line.strip()}")
    return issues


def check_todo_markers() -> list[str]:
    issues: list[str] = []
    pattern = re.compile(r"TODO|FIXME")
    for path in dart_files():
        for line_no, line in enumerate(path.read_text(encoding="utf-8").splitlines(), start=1):
            if pattern.search(line):
                issues.append(f"todo marker: {path.relative_to(ROOT)}:{line_no}: {line.strip()}")
    return issues


def check_common_suspicious_patterns() -> list[str]:
    issues: list[str] = []
    patterns = {
        "lastUpdated null": re.compile(r"lastUpdated:\s*null"),
        "placeholder maps key": re.compile(r"YOUR_GOOGLE_MAPS_API_KEY"),
        "timer arrow async-like callback": re.compile(r"Timer(?:\.periodic)?\([^\n;]*=>\s*_[A-Za-z0-9_]+\("),
        "mock terminology": re.compile(r"\b[Mm]ock\b"),
        "demo-mode marker": re.compile(r"Demo-mode|sample data|simulation|_mock"),
        "unfinished placeholder wording": re.compile(r"tayyorlanmoqda"),
        "empty generic callback argument": re.compile(r"_(?:quickAction|actionButton|settingsTile)\([^\n;]*\(\)\s*\{\s*\}"),
        "unused generated order card fallback": re.compile(r"Widget\s+_buildOrderCard\(int\s+index\)"),
    }
    for path in dart_files():
        text = path.read_text(encoding="utf-8")
        for label, pattern in patterns.items():
            for match in pattern.finditer(text):
                line_no = text[:match.start()].count("\n") + 1
                issues.append(f"{label}: {path.relative_to(ROOT)}:{line_no}")
    return issues


def check_env_config_imports() -> list[str]:
    issues: list[str] = []
    for path in dart_files():
        if path.name == "env_config.dart":
            continue
        text = path.read_text(encoding="utf-8")
        if "EnvConfig" in text and "env_config.dart" not in text:
            issues.append(f"EnvConfig used without import: {path.relative_to(ROOT)}")
    return issues


def check_domain_layer_boundaries() -> list[str]:
    issues: list[str] = []
    forbidden = ("/data/", "/presentation/", "../data/", "../../data/", "../presentation/", "../../presentation/")
    for path in dart_files():
        rel = path.relative_to(ROOT).as_posix()
        if "/domain/" not in rel:
            continue
        text = path.read_text(encoding="utf-8")
        for imp in re.findall(r"import\s+'([^']+)'", text):
            if any(part in imp for part in forbidden):
                issues.append(f"domain layer imports non-domain dependency: {rel} -> {imp}")
    return issues


def main() -> int:
    checks = {
        "imports": check_imports(),
        "bloc_wiring": check_bloc_wiring(),
        "empty_callbacks": check_empty_callbacks(),
        "todo_markers": check_todo_markers(),
        "suspicious_patterns": check_common_suspicious_patterns(),
        "env_config_imports": check_env_config_imports(),
        "domain_boundaries": check_domain_layer_boundaries(),
    }
    failed = False
    for name, issues in checks.items():
        print(f"{name}: {len(issues)} issue(s)")
        for issue in issues[:50]:
            print(f"  - {issue}")
        if issues:
            failed = True
    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
