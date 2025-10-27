# NixLine Demo Repository

This repository demonstrates how **[NixLine](https://github.com/NixLine-org/nixline-baseline)** keeps repositories aligned with organization-wide policies automatically, reproducibly and securely.

**NixLine Demo** is a consumer example showing how organizations can adopt NixLine's architecture for:
- **Policy materialization** - Sync `.editorconfig`, `LICENSE`, `SECURITY.md`, `CODEOWNERS` and more
- **Automated policy sync** - Weekly sync keeps policies up to date
- **CI validation** - Ensure policies stay in sync

It consumes reusable workflows from [`NixLine-org/.github`](https://github.com/NixLine-org/.github) and baseline logic from [`NixLine-org/nixline-baseline`](https://github.com/NixLine-org/nixline-baseline).

## Quick Start

This demo repository shows NixLine in action. To set up your own consumer repository, see the [NixLine Baseline Quick Start](https://github.com/NixLine-org/nixline-baseline#quick-start-for-consumer-repos) guide.

**Note:** This repository's CI initially fails because the policy files haven't been materialized yet. This is expected behavior for new consumer repositories. Run `nix run .#sync` to fix.

## How It Works

This repository uses the **consumer template** pattern:

- **`flake.nix`** - References the baseline and configures which packs to enable
- **`.github/workflows/policy-sync.yml`** - Runs weekly to sync policy updates
- **`.github/workflows/ci.yml`** - Validates policies are in sync on every push

## Available Apps

```bash
# Sync policies from baseline
nix run .#sync

# Check if policies are in sync
nix run .#check

# Generate SBOM (after sync)
nix run .#sbom

# Update flake.lock with PR
nix run .#flake-update

# Install pre-commit hooks
nix run .#setup-hooks
```

## Enabled Packs

This demo repository enables these packs in `flake.nix`:

| Pack | Purpose | Materialized File |
|------|---------|-------------------|
| `editorconfig` | Code formatting standards | `.editorconfig` |
| `license` | Apache 2.0 license | `LICENSE` |
| `security` | Security policy | `SECURITY.md` |
| `codeowners` | Code ownership rules | `.github/CODEOWNERS` |
| `precommit` | Pre-commit hooks | `.pre-commit-config.yaml` |
| `dependabot` | Dependabot config | `.github/dependabot.yml` |

## Automated Policy Sync

The repository includes a weekly policy sync workflow that:

1. Checks if policies are out of sync with baseline
2. If needed, materializes updated policies
3. Auto-commits changes directly to main branch

This ensures the repository stays up to date with organization policies without manual intervention.

## Why This Architecture?

- **Separation of Concerns** - The baseline defines policies, consumers just use them
- **Scalability** - One baseline update propagates to all consumer repositories automatically
- **No PR Bottleneck** - Policy updates materialize instantly without requiring manual review
- **Reproducible** - All policy content is defined declaratively in Nix

For organizations, this eliminates the traditional governance bottleneck where policy updates require hundreds of manual PRs across repositories.