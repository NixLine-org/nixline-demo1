# NixLine Demo 1

This repository demonstrates how **[NixLine](https://github.com/NixLine-org/nixline)** keeps repositories aligned with organization-wide policies — automatically, reproducibly and securely.

**NixLine Demo 1** is a minimal example repository that demonstrates how an organization can adopt NixLine’s architecture.  
It consumes reusable workflows from `NixLine-org/.github` and baseline logic from `NixLine-org/nixline-baseline`, showing how CI enforcement, policy checks and dependency automation can all be centralized through declarative Nix.


## Demo Overview

This repo is a **consumer** of the NixLine ecosystem. It shows how a typical project in the org would integrate:

- The shared workflows stored in `NixLine-org/.github`
- The shared baseline logic stored in `NixLine-org/nixline-baseline`
- The CI validation that ensures compliance with org standards

## Important Concepts

### Baseline Repository  

[`NixLine-org/nixline-baseline`](https://github.com/NixLine-org/nixline-baseline)  

- Contains the canonical definitions used by workflows (e.g., apps `#sync` and `#check`).  
- Tag `stable` is used by workflows across the org for predictable behavior.

### Demo Repository  

This repository (`nixline-demo1`):  

Is a real-world style consumer project that uses the baseline and workflows.  

- Does *not* manage the baseline itself.  
- Runs a CI job that executes the baseline logic.

## Included Packs

GitHub Actions, Pre-commit, EditorConfig, CODEOWNERS, Security policy, License, SBOM, Dependabot, Flake updater

## CI Workflow

This project includes the following workflow(s) under `.github/workflows`:

- **[`.github/workflows/ci.yml`](.github/workflows/ci.yml)** — runs the `Demo CI (ephemeral)` workflow.  
  This workflow executes:

  ```bash
  nix run github:NixLine-org/nixline-baseline?ref=stable#sync
  nix run github:NixLine-org/nixline-baseline?ref=stable#check
  ```

Which means: use the baseline’s logic (tag `stable`) to perform sync/check.

- **[`.github/workflows/verify-all.yml`](.github/workflows/verify-all.yml)** — (optional) a manual or push-triggered workflow that runs all NixLine reusable workflows (CI, SBOM, flake-update, etc.) for demonstration and verification purposes.

## How to Run Locally

You don’t need to manage or modify the baseline logic in this repo. To validate the setup locally:

```bash
# Run baseline sync
nix run github:NixLine-org/nixline-baseline?ref=stable#sync

# Run baseline check
nix run github:NixLine-org/nixline-baseline?ref=stable#check
```

If both commands output `Hello, world!` (or equivalent), the baseline is working and the demo CI uses it correctly.

---

## Why This Architecture?

- **Separation of Concerns**  

  The [baseline repository](https://github.com/NixLine-org/nixline-baseline) is owned by the organization and defines shared logic and policy.  
  Consumer repositories (like this demo) simply *use* the baseline — they don’t need to re-implement or duplicate its logic.

- **Scalability**  

  A single baseline repo can power dozens or hundreds of consumer repos.  
  When policies or configurations are updated in the baseline, every consumer automatically inherits those changes through the shared workflows.

- **Clarity**  

  This setup works like a **library–client** model:  
  - The baseline provides reusable, versioned Nix modules and workflows.  
  - Consumer repos reference them declaratively.

- **Reusability Across Organizations**  

  Any organization can adopt this pattern by **forking** or **mirroring** the NixLine repositories:  
  
  1. Fork [`NixLine-org/.github`](https://github.com/NixLine-org/.github) for reusable workflows.  
  2. Fork [`NixLine-org/nixline-baseline`](https://github.com/NixLine-org/nixline-baseline) to define your own policies and baseline logic.  
  3. Add the `ci.yml` (and optionally `verify-all.yml`) workflow to your repos to start enforcing consistent CI behavior.

This architecture makes it easy for engineering or security teams to build their own **organization-wide governance layer** — one that automates policy inheritance, dependency updates and security enforcement in a reproducible and transparent way.
