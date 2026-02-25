# Contributing

## Prerequisites

- [uv](https://docs.astral.sh/uv/) — Python package and project manager
- [Docker](https://docs.docker.com/get-docker/) — container runtime
- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.5

## Setup

Install all dependencies (including dev tools):

```bash
uv sync --group dev
```

## Development workflow

All common tasks are available via `make`. Run `make help` to see the full list.

### Dependency management

Runtime and dev dependencies are declared in `pyproject.toml` and pinned in `uv.lock`. Always commit both files together.

Add a runtime dependency:

```bash
uv add <package>
```

Add a dev-only dependency (tools, linters, test libraries):

```bash
uv add --group dev <package>
```

Remove a dependency:

```bash
uv remove <package>
```

Upgrade all dependencies to the latest allowed versions:

```bash
uv lock --upgrade
```

Upgrade a single package:

```bash
uv lock --upgrade-package <package>
```

After any lock file change, run `uv sync --group dev` to update your local environment, then run `make check` to confirm nothing is broken.

### Code quality

```bash
make lint        # ruff — linting
make format      # black — formatting check
make typecheck   # mypy — strict type checking
make check       # all three, plus tests (use before pushing)
```

To automatically fix violations:

```bash
make fix         # ruff --fix + black reformat
```

### Standards

- **Formatting**: [black](https://black.readthedocs.io), 88-char line length
- **Linting**: [ruff](https://docs.astral.sh/ruff/) with a broad community ruleset — pycodestyle, pyflakes, isort, pep8-naming, pyupgrade, bugbear, comprehensions, simplify, type-checking, annotations, pathlib, perflint
- **Types**: [mypy](https://mypy.readthedocs.io) in strict mode — all public functions and methods must be fully annotated

## Code governance

This project enforces a strict quality baseline. All checks must pass before code is merged.

### Type annotations

Every function and method — including tests — must carry complete type annotations. This is enforced by two layers:

- **ruff** (`ANN` rules) rejects missing annotations at lint time.
- **mypy** in strict mode performs full static type checking, including inferred return types, `Any` usage, and untyped third-party imports.

There are no per-file or per-directory exemptions. Annotate everything.

### Linting and formatting

Code must be formatted with **black** and pass all **ruff** rules without suppression. If a rule produces a false positive, discuss disabling it project-wide in `pyproject.toml` rather than adding inline `# noqa` comments.

### Test coverage

All new code must be covered by tests. Branch coverage is measured — ensure conditional paths are exercised, not just the happy path. `make check` will fail if coverage drops.

### Testing

```bash
make test        # pytest with branch coverage
```

Tests live in `tests/`. Coverage is reported to the terminal and written to `coverage.xml`. All new code should be covered.

## Commit messages

This project uses [Conventional Commits](https://www.conventionalcommits.org/). Every commit message must follow the format:

```
<type>(<scope>): <description>
```

The `scope` is optional. Use the types below:

| Type | When to use |
|---|---|
| `feat` | A new feature or behaviour |
| `fix` | A bug fix |
| `docs` | Documentation only |
| `chore` | Maintenance — dependencies, config, tooling |
| `build` | Build system or CI changes |
| `test` | Adding or updating tests |
| `refactor` | Code change that neither fixes a bug nor adds a feature |
| `perf` | Performance improvement |

Keep the description short (under 72 characters), in the imperative mood, and in lower case. For example:

```
feat(auth): add JWT validation middleware
fix: handle empty response from upstream API
docs: document src layout rationale
```

## Docker

```bash
make build       # build the image
make run         # run the container
```

The image uses a multi-stage build: dependencies are installed in a builder stage and only the compiled venv is copied to the final `python:3.14-slim` runtime image. The container runs as a non-root user.

## Infrastructure

Terraform configuration lives in `terraform/`. AWS credentials must be available in the environment (e.g. via `AWS_PROFILE` or `aws sso login`).

```bash
make tf-init     # initialise working directory and download providers
make tf-plan     # preview changes
make tf-apply    # apply changes
make tf-destroy  # tear down all managed resources
```

The state is stored locally by default. Before working in a team or running in CI, configure the S3 backend in `terraform/versions.tf`.
