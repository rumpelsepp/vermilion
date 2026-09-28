# SPDX-FileCopyrightText: 2026 Stefan Tatschner <stefan.tatschner@mailbox.org>
# SPDX-License-Identifier: GPL-3.0-or-later

# The recipes run the tools of the active environment: `uv run just ...`
# (the CI), or `just ...` in the environment of `just venv`.

# list the recipes
default:
    @just --list

# an environment with PyGObject and pycairo of the distribution instead of
# building them (see README); activate it: `. .venv/bin/activate`
venv:
    uv venv --clear --system-site-packages --python /usr/bin/python3
    printf 'pygobject\npycairo\n' | uv pip install --excludes /dev/stdin -e . --group dev

# all linters and the tests
check: lint test

# all linters
lint: ruff mypy ty reuse

# ruff lints and formatting
ruff:
    ruff check
    ruff format --check

# mypy (strict)
mypy:
    mypy

# ty
ty:
    ty check

# REUSE compliance (licence and copyright of every file)
reuse:
    reuse lint

# compile the Blueprint files to the .ui files the application loads
blueprints:
    python tools/blueprints.py

# the sdist and the wheel (in dist/), with the compiled Blueprint files
build: blueprints
    uv build

# tests
test *args: blueprints
    pytest {{ args }}

# format the code and apply the safe ruff fixes
fmt:
    ruff check --fix
    ruff format
