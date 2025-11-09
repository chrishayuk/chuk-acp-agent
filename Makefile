.PHONY: clean clean-pyc clean-build clean-test clean-all test test-cov coverage-report run-examples build help install dev-install version lint format typecheck check examples

# Default target
help:
	@echo "Available targets:"
	@echo "  clean          - Remove Python bytecode and basic artifacts"
	@echo "  clean-all      - Deep clean everything (pyc, build, test, cache)"
	@echo "  install        - Install package in current environment"
	@echo "  dev-install    - Install package in development mode with dev dependencies"
	@echo "  test           - Run tests"
	@echo "  test-cov       - Run tests with coverage report (90% target)"
	@echo "  test-file      - Run tests for specific file with coverage"
	@echo "  coverage-report - Show current coverage report"
	@echo "  examples       - Run all example agents to verify they work"
	@echo "  lint           - Run code linters"
	@echo "  format         - Auto-format code"
	@echo "  typecheck      - Run type checking"
	@echo "  check          - Run all checks (lint, typecheck, test)"
	@echo "  build          - Build the project"
	@echo ""
	@echo "Usage examples:"
	@echo "  make test-file FILE=src/chuk_acp_agent/agent/base.py"
	@echo "  make examples"

# Basic clean - Python bytecode and common artifacts
clean: clean-pyc clean-build
	@echo "Basic clean complete."

# Remove Python bytecode files and __pycache__ directories
clean-pyc:
	@echo "Cleaning Python bytecode files..."
	@find . -type f -name '*.pyc' -delete 2>/dev/null || true
	@find . -type f -name '*.pyo' -delete 2>/dev/null || true
	@find . -type d -name '__pycache__' -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name '*.egg-info' -exec rm -rf {} + 2>/dev/null || true

# Remove build artifacts
clean-build:
	@echo "Cleaning build artifacts..."
	@rm -rf build/ dist/ *.egg-info 2>/dev/null || true
	@rm -rf .eggs/ 2>/dev/null || true
	@find . -name '*.egg' -exec rm -f {} + 2>/dev/null || true

# Remove test artifacts
clean-test:
	@echo "Cleaning test artifacts..."
	@rm -rf .pytest_cache/ 2>/dev/null || true
	@rm -rf .coverage 2>/dev/null || true
	@rm -rf htmlcov/ 2>/dev/null || true
	@rm -rf .tox/ 2>/dev/null || true
	@rm -rf .cache/ 2>/dev/null || true
	@find . -name '.coverage.*' -delete 2>/dev/null || true

# Deep clean - everything
clean-all: clean-pyc clean-build clean-test
	@echo "Deep cleaning..."
	@rm -rf .mypy_cache/ 2>/dev/null || true
	@rm -rf .ruff_cache/ 2>/dev/null || true
	@rm -rf .uv/ 2>/dev/null || true
	@find . -name '.DS_Store' -delete 2>/dev/null || true
	@find . -name '*.log' -delete 2>/dev/null || true
	@find . -name '*.tmp' -delete 2>/dev/null || true
	@find . -name '*~' -delete 2>/dev/null || true
	@echo "Deep clean complete."

# Install package
install:
	@echo "Installing package..."
	pip install .

# Install package in development mode with dev dependencies
dev-install:
	@echo "Installing package in development mode..."
	pip install -e ".[dev]"

# Run tests
test:
	@echo "Running tests..."
	@if command -v uv >/dev/null 2>&1; then \
		uv run pytest; \
	elif command -v pytest >/dev/null 2>&1; then \
		pytest; \
	else \
		python -m pytest; \
	fi

# Show current coverage report
coverage-report:
	@echo "Coverage Report:"
	@echo "================"
	@if command -v uv >/dev/null 2>&1; then \
		uv run coverage report --omit="tests/*" || echo "No coverage data found. Run 'make test-cov' first."; \
	else \
		coverage report --omit="tests/*" || echo "No coverage data found. Run 'make test-cov' first."; \
	fi

# Run tests with coverage (90% target per file)
test-cov coverage:
	@echo "Running tests with coverage (90% target per file)..."
	@if command -v uv >/dev/null 2>&1; then \
		uv run pytest --cov=src/chuk_acp_agent --cov-report=html --cov-report=term --cov-fail-under=90; \
		echo ""; \
		echo "Full coverage report saved to: htmlcov/index.html"; \
		echo "Target: 90% coverage per file"; \
	else \
		pytest --cov=src/chuk_acp_agent --cov-report=html --cov-report=term --cov-fail-under=90; \
		echo ""; \
		echo "Full coverage report saved to: htmlcov/index.html"; \
		echo "Target: 90% coverage per file"; \
	fi

# Run tests for a specific file with coverage
test-file:
	@if [ -z "$(FILE)" ]; then \
		echo "Error: FILE not specified"; \
		echo "Usage: make test-file FILE=src/chuk_acp_agent/agent/base.py"; \
		exit 1; \
	fi; \
	echo "Running tests for $(FILE) with coverage..."; \
	if command -v uv >/dev/null 2>&1; then \
		uv run pytest --cov=$(FILE) --cov-report=term-missing tests/; \
	else \
		pytest --cov=$(FILE) --cov-report=term-missing tests/; \
	fi

# Run all examples to verify they work
examples:
	@echo "Running all example agents..."
	@echo ""
	@echo "1. Testing echo_agent.py..."
	@uvx chuk-acp client uv run examples/echo_agent.py --prompt "Test" 2>&1 | grep -q "You said" && echo "✓ echo_agent works" || echo "✗ echo_agent failed"
	@echo ""
	@echo "2. Testing file_agent.py..."
	@echo "test content" > /tmp/test_makefile.txt
	@uvx chuk-acp client uv run examples/file_agent.py --prompt "read /tmp/test_makefile.txt" 2>&1 | grep -q "test content" && echo "✓ file_agent works" || echo "✗ file_agent failed"
	@echo ""
	@echo "3. Testing plan_agent.py..."
	@uvx chuk-acp client uv run examples/plan_agent.py --prompt "test" 2>&1 | grep -q "Summary" && echo "✓ plan_agent works" || echo "✗ plan_agent failed"
	@echo ""
	@echo "4. Testing mcp_agent_simple.py..."
	@uvx chuk-acp client uv run examples/mcp_agent_simple.py --prompt "echo Test" 2>&1 | grep -q "Echo:" && echo "✓ mcp_agent_simple works" || echo "✗ mcp_agent_simple failed"
	@echo ""
	@echo "5. Testing mcp_agent_advanced.py..."
	@uvx chuk-acp client uv run examples/mcp_agent_advanced.py --prompt "batch" 2>&1 | grep -q "Batch results" && echo "✓ mcp_agent_advanced works" || echo "✗ mcp_agent_advanced failed"
	@echo ""
	@echo "6. Testing mcp_agent.py..."
	@uvx chuk-acp client uv run examples/mcp_agent.py --prompt "echo Test" 2>&1 | grep -q "MCP Echo" && echo "✓ mcp_agent works" || echo "✗ mcp_agent failed"
	@echo ""
	@echo "All example tests complete!"

# Build the project using the pyproject.toml configuration
build: clean-build
	@echo "Building project..."
	@if command -v uv >/dev/null 2>&1; then \
		uv build; \
	else \
		python3 -m build; \
	fi
	@echo "Build complete. Distributions are in the 'dist' folder."

# Show current version
version:
	@version=$$(grep '^version = ' pyproject.toml | cut -d'"' -f2); \
	echo "Current version: $$version"

# Check code quality
lint:
	@echo "Running linters..."
	@if command -v uv >/dev/null 2>&1; then \
		uv run ruff check .; \
		uv run ruff format --check .; \
	elif command -v ruff >/dev/null 2>&1; then \
		ruff check .; \
		ruff format --check .; \
	else \
		echo "Ruff not found. Install with: pip install ruff"; \
	fi

# Fix code formatting
format:
	@echo "Formatting code..."
	@if command -v uv >/dev/null 2>&1; then \
		uv run ruff format .; \
		uv run ruff check --fix .; \
	elif command -v ruff >/dev/null 2>&1; then \
		ruff format .; \
		ruff check --fix .; \
	else \
		echo "Ruff not found. Install with: pip install ruff"; \
	fi

# Type checking
typecheck:
	@echo "Running type checker..."
	@if command -v uv >/dev/null 2>&1; then \
		uv run mypy src; \
	elif command -v mypy >/dev/null 2>&1; then \
		mypy src; \
	else \
		echo "MyPy not found. Install with: pip install mypy"; \
	fi

# Run all checks
check: lint typecheck test
	@echo "All checks completed."
