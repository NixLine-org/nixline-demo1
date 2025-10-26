# NixLine Demo 1

This repository demonstrates how **[NixLine](https://github.com/NixLine-org/nixline)** keeps repositories aligned with organization-wide policies — automatically, reproducibly and securely.

## Demo Overview

This demo uses **ephemeral sync mode**, meaning that NixLine applies policies *only during CI* without modifying the repository itself. Each CI run regenerates workflows, config files and policies from the shared NixLine baseline for validation and consistency checks.

## Included Packs

GitHub Actions, Pre-commit, EditorConfig, CODEOWNERS, Security policy, License, SBOM, Dependabot, Flake updater

## CI Workflow

See [`.github/workflows/ci.yml`](.github/workflows/ci.yml).
