set shell := ["bash", "-euo", "pipefail", "-c"]

# Lists the commands.
default:
    @just --list

# Prepares the backend environment with the declared runtime and dependency sources.
setup:
    uv venv --python python services/backend/.venv
    uv pip install --python services/backend/.venv/bin/python -r services/backend/requirements.txt

# Checks authored Python syntax and the command source without executing the application.
check:
    just --fmt --check
    python3 scripts/check-python-source.py

# Runs the existing backend unit suite and byte compilation.
test:
    cd services/backend && .venv/bin/python -m unittest discover -s tests -v
    cd services/backend && .venv/bin/python -m compileall -q app

# Runs the full backend validation.
verify: check test
