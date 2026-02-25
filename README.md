# docker-python-env

A minimal, production-ready Python application environment managed by [uv](https://docs.astral.sh/uv/), packaged as a Docker container, and deployable to AWS via Terraform.

The project is intentionally small. Its purpose is to establish a well-governed baseline that can be extended into a real application.

---

## What this project provides

| Layer              | Technology           | Role                                                        |
| ------------------ | -------------------- | ----------------------------------------------------------- |
| Package management | uv                   | Dependency resolution, virtual environments, script running |
| Code quality       | ruff, black, mypy    | Linting, formatting, static type checking                   |
| Testing            | pytest + pytest-cov  | Unit tests with branch coverage                             |
| Containerisation   | Docker (multi-stage) | Reproducible, minimal runtime image                         |
| Infrastructure     | Terraform + AWS ECR  | Container registry, ready for deployment                    |

---

## Design decisions

### uv over pip / poetry / pipenv

uv is significantly faster than pip-based toolchains and produces a deterministic `uv.lock` file that pins the full dependency graph. Dev dependencies are declared in a `[dependency-groups]` section in `pyproject.toml` and installed only when needed (`uv sync --group dev`), keeping the production dependency set clean. All tools are invoked via `uv run` so they always use the project's pinned versions. No global installs are required.

### src layout

Source code lives under `src/` rather than at the project root. This is now the recommended layout by the Python Packaging Authority and the default when initialising a project with uv. The key benefit is import isolation: without a `src/` directory, Python's module resolution can import the local source tree directly, meaning tests may pass against uninstalled code that would fail once packaged. With the `src/` layout, the package must be installed into the virtual environment before it can be imported, ensuring tests always exercise the installed artefact.

### ruff for linting

ruff replaces a collection of individual tools (flake8, isort, pyupgrade, and many plugins) with a single, fast binary. The enabled rule sets cover the most widely adopted community conventions: style (pycodestyle), correctness (pyflakes, bugbear), imports (isort), naming (pep8-naming), modernisation (pyupgrade), performance (perflint), and more. The full list is in `pyproject.toml`.

### mypy in strict mode

Python is optionally typed by default. Annotations are valid syntax but carry no runtime enforcement. This project removes that optionality. ruff's `ANN` rules require annotations on every function and method (including tests), and mypy in strict mode verifies their correctness: inferred return types, unsafe use of `Any`, and untyped third-party imports are all errors. The effect is a fully typed codebase where the type checker has the same authority as the compiler in a statically typed language.

### black for formatting

black is non-configurable by design (beyond line length). This eliminates formatting debates entirely. The formatter decides, and the answer is always the same. `make fix` reformats the whole codebase in one step.

### Multi-stage Docker build

The image uses two stages:

1. **Builder** — installs uv, resolves dependencies, pre-compiles `.pyc` files (`UV_COMPILE_BYTECODE=1`), and installs the project package with `--no-editable` so the source is baked into the venv's `site-packages`.
2. **Runtime** — a fresh `python:3.14-slim` image that receives only the compiled `.venv` from the builder. No build tools, no source tree, no uv binary in the final image.

The runtime container runs as a non-root user (`app`, uid 1001). `PYTHONDONTWRITEBYTECODE` and `PYTHONUNBUFFERED` are set to prevent `.pyc` generation at runtime and to ensure logs are flushed immediately.

### Terraform for infrastructure

Terraform manages the AWS infrastructure as code, making it reproducible and reviewable. The only resource provisioned here is an ECR repository (the natural home for the Docker image), with immutable image tags and scan-on-push enabled. The lifecycle policy retains only the three most recent images to control storage costs.

State is stored locally by default. Before using this in a team or CI pipeline, configure the S3 backend in `terraform/versions.tf`.

---

## Getting started

See [CONTRIBUTING.md](CONTRIBUTING.md) for full setup instructions and development workflow.
