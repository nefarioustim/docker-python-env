.DEFAULT_GOAL := help

.PHONY: help lint format typecheck fix check

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2}'

lint: ## Run ruff linter
	uv run ruff check .

format: ## Run black formatter (check mode)
	uv run black --check .

typecheck: ## Run mypy type checker
	uv run mypy src/

fix: ## Auto-fix ruff violations and reformat with black
	uv run ruff check --fix .
	uv run black .

check: lint format typecheck ## Run all checks (lint, format, typecheck)
