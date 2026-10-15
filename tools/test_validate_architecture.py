import tempfile
import unittest
from pathlib import Path

from validate_architecture import findings_for, main, route_prefixes


class RoutePrefixTests(unittest.TestCase):
    def test_router_prefix_and_decorator_join(self) -> None:
        source = '''
from fastapi import APIRouter
router = APIRouter(prefix="/v1/auth")

@router.get("/login")
def login():
    return None
'''
        self.assertEqual(route_prefixes(source), {"/v1/auth", "/v1/auth/login"})

    def test_health_routes_have_no_prefix(self) -> None:
        source = '''
from fastapi import APIRouter
router = APIRouter(tags=["health"])

@router.get("/health")
def health():
    return None
'''
        self.assertEqual(route_prefixes(source), {"/health"})


class FindingTests(unittest.TestCase):
    def test_missing_contract_lists_every_route(self) -> None:
        with tempfile.TemporaryDirectory() as raw:
            repo = Path(raw)
            api = repo / "app" / "api"
            api.mkdir(parents=True)
            (api / "health.py").write_text(
                'from fastapi import APIRouter\nrouter = APIRouter()\n\n@router.get("/health")\ndef health():\n    return None\n',
                encoding="utf-8",
            )
            self.assertEqual(
                findings_for(repo),
                ["missing-module-yaml", "route-not-in-contract /health"],
            )

    def test_declared_prefix_covers_child_routes(self) -> None:
        with tempfile.TemporaryDirectory() as raw:
            repo = Path(raw)
            api = repo / "backend" / "app" / "api"
            api.mkdir(parents=True)
            (api / "auth.py").write_text(
                'from fastapi import APIRouter\nrouter = APIRouter(prefix="/v1/auth")\n\n@router.post("/login")\ndef login():\n    return None\n',
                encoding="utf-8",
            )
            docs = repo / "docs"
            docs.mkdir()
            (docs / "module.yaml").write_text(
                "\n".join(
                    [
                        "current_state:",
                        "  backend:",
                        "    route_prefix: /v1",
                        "    route_groups:",
                        "      - prefix: /auth",
                        "        purpose: Sign in.",
                        "        actors: [operator]",
                        "        access: {}",
                        "        source: backend/app/api/auth.py",
                    ]
                ),
                encoding="utf-8",
            )
            self.assertEqual(findings_for(repo), [])

    def test_new_route_fails_the_check(self) -> None:
        with tempfile.TemporaryDirectory() as raw:
            repo = Path(raw)
            api = repo / "app" / "api"
            api.mkdir(parents=True)
            (api / "extra.py").write_text(
                'from fastapi import APIRouter\nrouter = APIRouter(prefix="/v1/extra")\n',
                encoding="utf-8",
            )
            docs = repo / "docs"
            docs.mkdir()
            (docs / "architecture-baseline.txt").write_text("missing-module-yaml\n", encoding="utf-8")
            self.assertEqual(main(["--repo", str(repo), "--mode", "check"]), 1)

    def test_cross_service_import_is_a_gap(self) -> None:
        with tempfile.TemporaryDirectory() as raw:
            repo = Path(raw)
            app = repo / "app"
            app.mkdir()
            (app / "main.py").write_text("import platform_api\n", encoding="utf-8")
            api = app / "api"
            api.mkdir()
            (api / "health.py").write_text(
                'from fastapi import APIRouter\nrouter = APIRouter()\n',
                encoding="utf-8",
            )
            self.assertIn("cross-service-import app/main.py platform_api", findings_for(repo))

    def test_template_shape_accepts_nested_access_and_lists(self) -> None:
        with tempfile.TemporaryDirectory() as raw:
            repo = Path(raw)
            api = repo / "backend" / "app" / "api"
            api.mkdir(parents=True)
            (api / "example.py").write_text(
                'from fastapi import APIRouter\nrouter = APIRouter(prefix="/api/example")\n',
                encoding="utf-8",
            )
            docs = repo / "docs"
            docs.mkdir()
            (docs / "module.yaml").write_text(
                "\n".join(
                    [
                        "current_state:",
                        "  backend:",
                        "    route_prefix: /api",
                        "    route_groups:",
                        "      - prefix: /example",
                        "        purpose: One or two sentences.",
                        "        actors:",
                        "          - operator",
                        "        access:",
                        "          any_scope: []",
                        "        source: backend/app/api/example.py",
                        "        downstream:",
                        "          - platform-api",
                    ]
                ),
                encoding="utf-8",
            )
            self.assertEqual(findings_for(repo), [])

    def test_absolute_prefix_is_not_joined_twice(self) -> None:
        with tempfile.TemporaryDirectory() as raw:
            repo = Path(raw)
            api = repo / "src" / "scheduler" / "api"
            api.mkdir(parents=True)
            (api / "jobs.py").write_text(
                'from fastapi import APIRouter\nrouter = APIRouter(prefix="/scheduler")\n',
                encoding="utf-8",
            )
            docs = repo / "docs"
            docs.mkdir()
            (docs / "module.yaml").write_text(
                "\n".join(
                    [
                        "current_state:",
                        "  backend:",
                        "    route_prefix: /scheduler",
                        "    route_groups:",
                        "      - prefix: /scheduler",
                        "        purpose: Jobs.",
                        "        actors: []",
                        "        access:",
                        "          any_scope: []",
                        "        source: src/scheduler/api/jobs.py",
                    ]
                ),
                encoding="utf-8",
            )
            self.assertEqual(findings_for(repo), [])

    def test_scheduler_layout_without_a_contract_is_not_skipped(self) -> None:
        with tempfile.TemporaryDirectory() as raw:
            repo = Path(raw)
            api = repo / "src" / "scheduler" / "api"
            api.mkdir(parents=True)
            (api / "jobs.py").write_text(
                'from fastapi import APIRouter\nrouter = APIRouter(prefix="/scheduler")\n',
                encoding="utf-8",
            )
            self.assertEqual(
                main(["--repo", str(repo), "--mode", "check"]),
                1,
            )

    def test_empty_purpose_and_source_are_missing(self) -> None:
        with tempfile.TemporaryDirectory() as raw:
            repo = Path(raw)
            api = repo / "backend" / "app" / "api"
            api.mkdir(parents=True)
            (api / "example.py").write_text(
                'from fastapi import APIRouter\nrouter = APIRouter(prefix="/api/example")\n',
                encoding="utf-8",
            )
            docs = repo / "docs"
            docs.mkdir()
            (docs / "module.yaml").write_text(
                "\n".join(
                    [
                        "current_state:",
                        "  backend:",
                        "    route_prefix: /api",
                        "    route_groups:",
                        "      - prefix: /example",
                        "        purpose:",
                        "        actors:",
                        "          - operator",
                        "        access:",
                        "          any_scope: []",
                        "        source:",
                    ]
                ),
                encoding="utf-8",
            )
            findings = findings_for(repo)
            self.assertIn("route-group-missing-field /example purpose", findings)
            self.assertIn("route-group-missing-field /example source", findings)
            self.assertFalse(any("actors" in item or "access" in item for item in findings))

    def test_target_state_does_not_cover_current_routes(self) -> None:
        with tempfile.TemporaryDirectory() as raw:
            repo = Path(raw)
            api = repo / "app" / "api"
            api.mkdir(parents=True)
            (api / "future.py").write_text(
                'from fastapi import APIRouter\nrouter = APIRouter(prefix="/future")\n',
                encoding="utf-8",
            )
            docs = repo / "docs"
            docs.mkdir()
            (docs / "module.yaml").write_text(
                "\n".join(
                    [
                        "current_state:",
                        "  backend:",
                        "    route_prefix: /api",
                        "    route_groups:",
                        "      - prefix: /example",
                        "        purpose: Current group.",
                        "        actors: []",
                        "        access: {}",
                        "        source: app/api/example.py",
                        "target_state:",
                        "  backend:",
                        "    route_prefix: /future",
                        "    route_groups:",
                        "      - prefix: /future",
                        "        actors: []",
                    ]
                ),
                encoding="utf-8",
            )
            self.assertEqual(findings_for(repo), ["route-not-in-contract /future"])

    def test_prefix_without_a_leading_slash_keeps_route_prefix(self) -> None:
        with tempfile.TemporaryDirectory() as raw:
            repo = Path(raw)
            api = repo / "backend" / "app" / "api"
            api.mkdir(parents=True)
            (api / "example.py").write_text(
                'from fastapi import APIRouter\nrouter = APIRouter(prefix="/api/example")\n',
                encoding="utf-8",
            )
            docs = repo / "docs"
            docs.mkdir()
            (docs / "module.yaml").write_text(
                "\n".join(
                    [
                        "current_state:",
                        "  backend:",
                        "    route_prefix: /api",
                        "    route_groups:",
                        "      - prefix: example",
                        "        purpose: Example.",
                        "        actors: []",
                        "        access: {}",
                        "        source: backend/app/api/example.py",
                    ]
                ),
                encoding="utf-8",
            )
            self.assertEqual(findings_for(repo), [])

    def test_blank_group_prefix_does_not_cover_the_base(self) -> None:
        with tempfile.TemporaryDirectory() as raw:
            repo = Path(raw)
            api = repo / "backend" / "app" / "api"
            api.mkdir(parents=True)
            (api / "routes.py").write_text(
                "\n".join(
                    [
                        "from fastapi import APIRouter",
                        'example = APIRouter(prefix="/api/example")',
                        'other = APIRouter(prefix="/api/other")',
                        'health = APIRouter(prefix="/health")',
                    ]
                ),
                encoding="utf-8",
            )
            docs = repo / "docs"
            docs.mkdir()
            (docs / "module.yaml").write_text(
                "\n".join(
                    [
                        "current_state:",
                        "  backend:",
                        "    route_prefix: /api",
                        "    route_groups:",
                        "      - prefix:",
                        "        purpose: Blank prefix.",
                        "        actors: []",
                        "        access: {}",
                        "        source: backend/app/api/routes.py",
                        "      - prefix: /example",
                        "        purpose: Example.",
                        "        actors: []",
                        "        access: {}",
                        "        source: backend/app/api/routes.py",
                    ]
                )
                + "\n"
                + "\n".join(
                    [
                        "target_state:",
                        "  backend:",
                        "    route_prefix: /",
                        "    route_groups:",
                        "      - prefix: /health",
                        "        purpose: Health.",
                        "        actors: []",
                        "        access: {}",
                        "        source: backend/app/api/routes.py",
                    ]
                ),
                encoding="utf-8",
            )
            self.assertEqual(
                findings_for(repo),
                ["route-not-in-contract /api/other", "route-not-in-contract /health"],
            )

    def test_root_route_prefix_keeps_an_absolute_group_prefix(self) -> None:
        with tempfile.TemporaryDirectory() as raw:
            repo = Path(raw)
            api = repo / "app" / "api"
            api.mkdir(parents=True)
            (api / "health.py").write_text(
                'from fastapi import APIRouter\nrouter = APIRouter(prefix="/health")\n',
                encoding="utf-8",
            )
            docs = repo / "docs"
            docs.mkdir()
            (docs / "module.yaml").write_text(
                "\n".join(
                    [
                        "current_state:",
                        "  backend:",
                        "    route_prefix: /",
                        "    route_groups:",
                        "      - prefix: /health",
                        "        purpose: Health.",
                        "        actors: []",
                        "        access: {}",
                        "        source: app/api/health.py",
                    ]
                ),
                encoding="utf-8",
            )
            self.assertEqual(findings_for(repo), [])

    def test_examples_docs_and_venv_are_not_api_packages(self) -> None:
        with tempfile.TemporaryDirectory() as raw:
            repo = Path(raw)
            for relative in ("examples/api", "docs/api", "venv/api"):
                directory = repo / relative
                directory.mkdir(parents=True)
                (directory / "routes.py").write_text(
                    'from fastapi import APIRouter\nrouter = APIRouter(prefix="/hidden")\n',
                    encoding="utf-8",
                )
            self.assertEqual(findings_for(repo), [])
            self.assertEqual(main(["--repo", str(repo), "--mode", "check"]), 0)

    def test_baselined_route_passes(self) -> None:
        with tempfile.TemporaryDirectory() as raw:
            repo = Path(raw)
            api = repo / "app" / "api"
            api.mkdir(parents=True)
            (api / "extra.py").write_text(
                'from fastapi import APIRouter\nrouter = APIRouter(prefix="/v1/extra")\n',
                encoding="utf-8",
            )
            self.assertEqual(main(["--repo", str(repo), "--mode", "check", "--write-baseline"]), 0)
            self.assertEqual(main(["--repo", str(repo), "--mode", "check"]), 0)


if __name__ == "__main__":
    unittest.main()
