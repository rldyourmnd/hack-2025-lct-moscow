"""Parse the tracked authored Python files without importing or writing bytecode."""

import ast
import subprocess
from pathlib import Path

paths = subprocess.check_output(
    ["git", "ls-files", "-z", "--", "services/backend/app", "services/backend/tests", "scripts"]
).decode().split("\0")
files = [Path(path) for path in paths if path.endswith(".py")]
for path in files:
    ast.parse(path.read_bytes(), filename=str(path))
print(f"Parsed {len(files)} authored Python files")
