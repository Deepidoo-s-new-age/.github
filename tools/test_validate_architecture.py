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
            (app / "api").mkdir()
            self.assertIn("cross-service-import app/main.py platform_api", findings_for(repo))

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
