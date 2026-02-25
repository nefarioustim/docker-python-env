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

### Testing

```bash
make test        # pytest with branch coverage
```

Tests live in `tests/`. Coverage is reported to the terminal and written to `coverage.xml`. All new code should be covered.

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
