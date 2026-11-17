set shell := ["bash", "-euo", "pipefail", "-c"]

# List the project commands.
default:
    @just --list

# Prepare both components on an execution host.
setup: setup-backend setup-frontend

# Prepare the existing backend runtime and dependency sources.
[group("components")]
setup-backend:
    uv venv --python python services/backend/.venv
    uv pip install --python services/backend/.venv/bin/python -r services/backend/requirements.txt

# Install the existing frontend lock without package lifecycle scripts.
[group("components")]
setup-frontend:
    npm ci --prefix services/frontend --ignore-scripts --no-audit --no-fund

# Check all authored source without building or running the application.
check: check-backend check-frontend

# Check Python syntax and the project command source.
[group("components")]
check-backend:
    just --fmt --check
    python3 scripts/check-python-source.py

# Type-check the frontend and Vite configuration without emitting files or build metadata.
[group("components")]
check-frontend:
    services/frontend/node_modules/.bin/tsc --noEmit -p services/frontend/tsconfig.json
    services/frontend/node_modules/.bin/tsc --noEmit --composite false --incremental false -p services/frontend/tsconfig.node.json

# Run the existing backend unit suite and byte compilation.
test:
    cd services/backend && .venv/bin/python -m unittest discover -s tests -v
    cd services/backend && .venv/bin/python -m compileall -q app

# Build the frontend bundle from the existing dependency lock.
build:
    npm run --prefix services/frontend build

# Run the full component validation on an execution host.
verify: check test build

# Run the backend's source and existing behavioral checks.
[group("ci")]
verify-backend: check-backend test

# Run the real frontend type checks and bundle build.
[group("ci")]
verify-frontend: check-frontend build
