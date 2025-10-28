# NixLine Demo Repository

Demonstrates **direct consumption** of [NixLine](https://github.com/NixLine-org/nixline-baseline) for organization-wide policy enforcement using default policies.

Shows how consumer repositories can:
- Call baseline directly via `nix run github:ORG/baseline#sync`
- Use default NixLine policies without configuration
- Validate policies automatically in CI
- Sync policy updates weekly without manual intervention
- Optionally add configuration for organization branding

Uses reusable workflows from [`NixLine-org/.github`](https://github.com/NixLine-org/.github) and policy definitions from [`NixLine-org/nixline-baseline`](https://github.com/NixLine-org/nixline-baseline).

## Quick Start

This demo repository shows NixLine in action. To set up your own consumer repository, see the [NixLine Baseline Quick Start](https://github.com/NixLine-org/nixline-baseline#quick-start-for-consumer-repos) guide.

**Note:** This repository's CI initially fails because the policy files haven't been materialized yet. This is expected behavior for new consumer repositories. Run `nix run github:NixLine-org/nixline-baseline#sync` to fix.

## How It Works

This repository demonstrates the **direct consumption** pattern:

- **Direct baseline calls** - Uses `nix run github:NixLine-org/nixline-baseline#command`
- **`.github/workflows/policy-sync.yml`** - Runs weekly to sync policy updates
- **`.github/workflows/ci.yml`** - Validates policies are in sync on every push

## Available Commands

```bash
# Sync default policies from baseline
nix run github:NixLine-org/nixline-baseline#sync

# Check if policies are in sync
nix run github:NixLine-org/nixline-baseline#check

# Preview changes without applying
nix run github:NixLine-org/nixline-baseline#sync -- --dry-run

# Select specific packs
nix run github:NixLine-org/nixline-baseline#sync -- --packs editorconfig,license,codeowners

# Override organization name (temporary customization)
nix run github:NixLine-org/nixline-baseline#sync -- --override org.name=MyCompany

# Create new policy pack
nix run github:NixLine-org/nixline-baseline#create-pack <name>

# Import existing policy files
nix run github:NixLine-org/nixline-baseline#import-policy -- --auto

# Fetch license from SPDX
nix run github:NixLine-org/nixline-baseline#fetch-license -- Apache-2.0 --holder "My Company"
```

## Materialized Packs

This demo repository materializes these packs by default:

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

## Organization Branding (Optional)

While this demo uses default policies, organizations can add branding via configuration:

**Create `.nixline.toml`:**
```toml
[organization]
name = "MyCompany"
security_email = "security@mycompany.com"
default_team = "@MyCompany/maintainers"

[packs]
enabled = ["editorconfig", "license", "codeowners"]
```

**Sync with configuration:**
```bash
nix run github:NixLine-org/nixline-baseline#sync -- --config .nixline.toml
```

This provides organization-specific branding (company name in CODEOWNERS, security email in SECURITY.md) without requiring baseline forking.

See [nixline-demo2](https://github.com/NixLine-org/nixline-demo2) for a complete configuration-driven example.

## Why This Architecture?

- **Separation of Concerns** - The baseline defines policies, consumers just use them
- **Scalability** - One baseline update propagates to all consumer repositories automatically
- **No PR Bottleneck** - Policy updates materialize instantly without requiring manual review
- **Reproducible** - All policy content is defined declaratively in Nix

For organizations, this eliminates the traditional governance bottleneck where policy updates require hundreds of manual PRs across repositories.