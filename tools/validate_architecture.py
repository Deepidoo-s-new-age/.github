#!/usr/bin/env python3
"""Compare FastAPI route prefixes with docs/module.yaml.

A repository with no API package is skipped. A repository with routes and no
module contract records every prefix as a known gap in the baseline. A prefix
that is not in the baseline fails the check.
"""

from __future__ import annotations

import argparse
import ast
import sys
from pathlib import Path

ROUTER_CALLS = {"APIRouter", "CrudRouter"}
HTTP_METHODS = {"get", "post", "put", "patch", "delete"}
REQUIRED_GROUP_FIELDS = ("purpose", "actors", "access", "source")
OTHER_SERVICES = {"platform_api", "auth_service"}
SKIP_PARTS = frozenset(
    {
        ".venv",
        "venv",
        "node_modules",
        ".git",
        "site-packages",
        "__pycache__",
        "dist",
        ".yarn",
        "tests",
        "test",
        "examples",
        "docs",
    }
)
NESTED_GROUP_FIELDS = frozenset({"actors", "access"})


def api_directories(repo: Path) -> list[Path]:
    """Every application ``api`` package, including layouts such as ``src/scheduler/api``."""
    found: list[Path] = []
    for path in sorted(repo.rglob("api")):
        if not path.is_dir():
            continue
        relative = path.relative_to(repo)
        if any(part in SKIP_PARTS for part in relative.parts):
            continue
        python_files = [
            child
            for child in path.rglob("*.py")
            if child.name != "__init__.py"
            and not any(part in SKIP_PARTS for part in child.relative_to(repo).parts)
        ]
        if not python_files:
            continue
        if any(path != earlier and earlier in path.parents for earlier in found):
            continue
        found.append(path)
    return found


def _string_keyword(call: ast.Call, name: str) -> str | None:
    for keyword in call.keywords:
        if keyword.arg == name and isinstance(keyword.value, ast.Constant):
            value = keyword.value.value
            if isinstance(value, str):
                return value
    return None


def _decorator_path(decorator: ast.expr) -> str | None:
    if not isinstance(decorator, ast.Call):
        return None
    func = decorator.func
    if not isinstance(func, ast.Attribute) or func.attr not in HTTP_METHODS:
        return None
    if not decorator.args:
        return ""
    first = decorator.args[0]
    if isinstance(first, ast.Constant) and isinstance(first.value, str):
        return first.value
    return None


def route_prefixes(source: str) -> set[str]:
    tree = ast.parse(source)
    prefixes: dict[str, str] = {}
    paths: set[str] = set()
    for node in tree.body:
        if not isinstance(node, ast.Assign) or len(node.targets) != 1:
            continue
        target = node.targets[0]
        if not isinstance(target, ast.Name) or not isinstance(node.value, ast.Call):
            continue
        call = node.value
        func = call.func
        func_name = func.id if isinstance(func, ast.Name) else None
        if func_name not in ROUTER_CALLS:
            continue
        prefix = _string_keyword(call, "prefix") or ""
        prefixes[target.id] = prefix
        if prefix:
            paths.add(prefix if prefix.startswith("/") else f"/{prefix}")
    for node in tree.body:
        if not isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)):
            continue
        for decorator in node.decorator_list:
            route_path = _decorator_path(decorator)
            if route_path is None or not isinstance(decorator, ast.Call):
                continue
            func = decorator.func
            if not isinstance(func, ast.Attribute) or not isinstance(func.value, ast.Name):
                continue
            prefix = prefixes.get(func.value.id, "")
            full = f"{prefix.rstrip('/')}/{route_path.lstrip('/')}" if route_path else prefix
            if full:
                paths.add(full if full.startswith("/") else f"/{full}")
    return paths


def discover_routes(repo: Path) -> set[str]:
    found: set[str] = set()
    for directory in api_directories(repo):
        for path in sorted(directory.rglob("*.py")):
            if path.name == "__init__.py":
                continue
            if any(part in SKIP_PARTS for part in path.relative_to(repo).parts):
                continue
            found.update(route_prefixes(path.read_text(encoding="utf-8")))
    return found


def _indent(line: str) -> int:
    return len(line) - len(line.lstrip(" "))


def _assign_group_field(group: dict[str, object], key: str, value: str) -> None:
    if key == "prefix":
        group["prefix"] = value
    elif key in NESTED_GROUP_FIELDS:
        group[key] = value or "present"
    elif key in REQUIRED_GROUP_FIELDS:
        group[key] = value


def contract_prefixes(module_yaml: str) -> list[dict[str, object]]:
    """Read current_state.backend.route_groups without a YAML library."""
    lines = module_yaml.splitlines()
    groups: list[dict[str, object]] = []
    in_current = False
    in_backend = False
    in_groups = False
    backend_indent = 0
    groups_indent = 0
    item_indent: int | None = None
    current: dict[str, object] | None = None
    for raw in lines:
        if not raw.strip() or raw.lstrip().startswith("#"):
            continue
        indent = _indent(raw)
        stripped = raw.strip()
        key, _, value = stripped.partition(":")
        value = value.strip().strip("'\"")
        if indent == 0:
            in_current = key == "current_state"
            in_backend = False
            in_groups = False
            current = None
            continue
        if not in_current:
            continue
        if key == "backend" and value == "" and not in_groups:
            in_backend = True
            backend_indent = indent
            in_groups = False
            current = None
            continue
        if in_backend and indent <= backend_indent and key != "backend":
            in_backend = False
            in_groups = False
            current = None
        if not in_backend:
            continue
        if key == "route_groups" and value == "":
            in_groups = True
            groups_indent = indent
            item_indent = None
            current = None
            continue
        if in_groups and indent <= groups_indent and not stripped.startswith("-"):
            in_groups = False
            current = None
        if not in_groups:
            continue
        if stripped.startswith("- "):
            if item_indent is None:
                item_indent = indent
            if indent != item_indent:
                continue
            current = {}
            groups.append(current)
            rest = stripped[2:]
            field, _, field_value = rest.partition(":")
            _assign_group_field(current, field.strip(), field_value.strip().strip("'\""))
            continue
        if current is None or item_indent is None or indent != item_indent + 2:
            continue
        _assign_group_field(current, key, value)
    return groups


def contract_route_prefix(module_yaml: str) -> str:
    in_current = False
    in_backend = False
    backend_indent = 0
    for raw in module_yaml.splitlines():
        if not raw.strip() or raw.lstrip().startswith("#"):
            continue
        indent = _indent(raw)
        key, _, value = raw.strip().partition(":")
        value = value.strip().strip("'\"")
        if indent == 0:
            in_current = key == "current_state"
            in_backend = False
            continue
        if not in_current:
            continue
        if key == "backend" and value == "":
            in_backend = True
            backend_indent = indent
            continue
        if in_backend and indent <= backend_indent:
            in_backend = False
        if in_backend and key == "route_prefix" and value:
            return value
    return ""


def join_route_prefix(base: str, prefix: str) -> str:
    base = base.rstrip("/")
    prefix = prefix.rstrip("/")
    if not prefix:
        return base
    if not prefix.startswith("/"):
        prefix = f"/{prefix}"
    if base and (prefix == base or prefix.startswith(f"{base}/")):
        return prefix
    return f"{base}{prefix}" if base else prefix


def cross_service_imports(repo: Path) -> list[str]:
    parents = []
    for directory in api_directories(repo):
        parent = directory.parent
        if parent not in parents and parent != repo:
            parents.append(parent)
    found: list[str] = []
    for directory in parents:
        found.extend(_imports_under(repo, directory))
    return found


def _imports_under(repo: Path, directory: Path) -> list[str]:
    found: list[str] = []
    for path in sorted(directory.rglob("*.py")):
        if any(part in SKIP_PARTS for part in path.relative_to(repo).parts):
            continue
        tree = ast.parse(path.read_text(encoding="utf-8"))
        for node in ast.walk(tree):
            modules: list[str] = []
            if isinstance(node, ast.Import):
                modules = [alias.name.split(".", 1)[0] for alias in node.names]
            elif isinstance(node, ast.ImportFrom) and node.module and node.level == 0:
                modules = [node.module.split(".", 1)[0]]
            for name in modules:
                if name in OTHER_SERVICES:
                    relative = path.relative_to(repo)
                    found.append(f"cross-service-import {relative} {name}")
    return found


def findings_for(repo: Path) -> list[str]:
    if not api_directories(repo):
        return []
    routes = discover_routes(repo)
    contract_path = repo / "docs" / "module.yaml"
    found: list[str] = cross_service_imports(repo)
    if not contract_path.is_file():
        found.append("missing-module-yaml")
        found.extend(f"route-not-in-contract {path}" for path in sorted(routes))
        return found
    text = contract_path.read_text(encoding="utf-8")
    base = contract_route_prefix(text).rstrip("/")
    declared: list[str] = []
    for group in contract_prefixes(text):
        prefix = str(group.get("prefix", "")).strip()
        full = "" if not prefix.strip("/") else join_route_prefix(base, prefix)
        if full:
            declared.append(full if full.startswith("/") else f"/{full}")
        for field in REQUIRED_GROUP_FIELDS:
            if not str(group.get(field, "")).strip():
                found.append(f"route-group-missing-field {prefix or full} {field}")
    for path in sorted(routes):
        if not any(path == item or path.startswith(f"{item}/") for item in declared):
            found.append(f"route-not-in-contract {path}")
    return found


def read_baseline(path: Path) -> set[str]:
    if not path.is_file():
        return set()
    return {
        line.strip()
        for line in path.read_text(encoding="utf-8").splitlines()
        if line.strip() and not line.strip().startswith("#")
    }


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo", type=Path, required=True)
    parser.add_argument("--baseline", type=Path, default=None)
    parser.add_argument("--mode", choices=("report", "check"), default="check")
    parser.add_argument("--write-baseline", action="store_true")
    args = parser.parse_args(argv)
    repo = args.repo.resolve()
    baseline_path = args.baseline or (repo / "docs" / "architecture-baseline.txt")
    current = findings_for(repo)
    if args.write_baseline:
        baseline_path.parent.mkdir(parents=True, exist_ok=True)
        baseline_path.write_text("\n".join(current) + ("\n" if current else ""), encoding="utf-8")
        print(f"wrote {len(current)} gaps to {baseline_path}")
        return 0
    if not current and not api_directories(repo):
        print("no API package; architecture check skipped")
        return 0
    known = read_baseline(baseline_path)
    unexpected = [item for item in current if item not in known]
    for item in current:
        print(item)
    if args.mode == "report":
        print(f"{len(unexpected)} gaps are not in the baseline")
        return 0
    if unexpected:
        print("new architecture gaps:", file=sys.stderr)
        for item in unexpected:
            print(item, file=sys.stderr)
        return 1
    print(f"architecture check passed ({len(current)} baselined gaps)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
