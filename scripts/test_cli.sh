#!/bin/zsh
set -euo pipefail

cd "$(dirname "$0")/.."

make >/dev/null

output=$(./gs-queue-pulse 2>&1 || true)
print -r -- "$output" | rg -q "Usage:"

output=$(./gs-queue-pulse add 2>&1 || true)
print -r -- "$output" | rg -q "Usage: gs-queue-pulse add"

output=$(./gs-queue-pulse recent 2>&1 || true)
print -r -- "$output" | rg -q "DATABASE_URL is not set"
