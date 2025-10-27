{
  description = "NixLine consumer repository";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixline-baseline = {
      url = "github:NixLine-org/nixline-baseline?ref=stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixline-baseline }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
    in
    {
      # Expose apps from baseline packs
      apps = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
          lib = nixpkgs.lib;
          baseline = nixline-baseline.lib.${system};

          # CUSTOMIZE: Select which packs to enable
          # Persistent packs (committed to repo for visibility)
          persistentPacks = [
            "editorconfig"   # Code formatting standards
            "license"        # Repository license (Apache 2.0)
            "security"       # Security policy
            "codeowners"     # Code ownership rules
            "precommit"      # Pre-commit hooks
            "dependabot"     # Dependabot configuration
          ];

          # Ephemeral packs (materialized in CI only, not committed)
          ephemeralPacks = [
            "flake-update"   # Flake update workflow
          ];

          # Pure app packs (no file materialization, run via nix run .#app)
          # sbom - Generate SBOM via nix run .#sbom

          # Get persistent files only
          selectedPacks = lib.filterAttrs (name: _: lib.elem name persistentPacks) baseline.packs;
          persistentFiles = lib.foldl' (acc: pack: acc // pack.files) {} (lib.attrValues selectedPacks);

          # Get ephemeral files (for CI use)
          ephemeralSelected = lib.filterAttrs (name: _: lib.elem name ephemeralPacks) baseline.packs;
          ephemeralFiles = lib.foldl' (acc: pack: acc // pack.files) {} (lib.attrValues ephemeralSelected);

          # Sync app - materialize persistent policy files
          sync = pkgs.writeShellApplication {
            name = "nixline-sync";
            text = ''
              echo "╔════════════════════════════════════════════════════════════╗"
              echo "║                    NixLine Sync                            ║"
              echo "╚════════════════════════════════════════════════════════════╝"
              echo ""
              echo "Persistent packs (committed): ${lib.concatStringsSep ", " persistentPacks}"
              echo ""

              ${lib.concatStringsSep "\n" (lib.mapAttrsToList (path: content: ''
                mkdir -p "$(dirname "${path}")"
                cat > "${path}" << 'NIXLINE_EOF'
${content}
NIXLINE_EOF
                echo "✓ ${path}"
              '') persistentFiles)}

              echo ""
              echo "Sync complete"
              echo ""
              echo "These files should be committed to your repository."
              echo "Run: git add ${lib.concatStringsSep " " (lib.attrNames persistentFiles)}"
            '';
          };

          # Sync ephemeral app - for CI use only
          sync-ephemeral = pkgs.writeShellApplication {
            name = "nixline-sync-ephemeral";
            text = ''
              echo "╔════════════════════════════════════════════════════════════╗"
              echo "║              NixLine Sync (Ephemeral)                      ║"
              echo "╚════════════════════════════════════════════════════════════╝"
              echo ""
              echo "Ephemeral packs (CI only): ${lib.concatStringsSep ", " ephemeralPacks}"
              echo ""

              ${lib.concatStringsSep "\n" (lib.mapAttrsToList (path: content: ''
                mkdir -p "$(dirname "${path}")"
                cat > "${path}" << 'NIXLINE_EOF'
${content}
NIXLINE_EOF
                echo "✓ ${path}"
              '') ephemeralFiles)}

              echo ""
              echo "Ephemeral sync complete (do not commit these files)"
            '';
          };

          # Check app - validate persistent files match baseline
          check = pkgs.writeShellApplication {
            name = "nixline-check";
            runtimeInputs = [ pkgs.diffutils ];
            text = ''
              echo "╔════════════════════════════════════════════════════════════╗"
              echo "║                   NixLine Check                            ║"
              echo "╚════════════════════════════════════════════════════════════╝"
              echo ""
              echo "Validating persistent policy files..."
              echo ""

              FAILED=0

              ${lib.concatStringsSep "\n" (lib.mapAttrsToList (path: content: ''
                if [[ ! -f "${path}" ]]; then
                  echo "[-] Missing: ${path}"
                  FAILED=1
                else
                  cat > /tmp/nixline-expected-${builtins.hashString "sha256" path} << 'NIXLINE_EOF'
${content}
NIXLINE_EOF
                  if diff -q "${path}" /tmp/nixline-expected-${builtins.hashString "sha256" path} > /dev/null; then
                    echo "[+] ${path}"
                  else
                    echo "[-] Out of sync: ${path}"
                    FAILED=1
                  fi
                  rm /tmp/nixline-expected-${builtins.hashString "sha256" path}
                fi
              '') persistentFiles)}

              echo ""
              if [[ $FAILED -eq 1 ]]; then
                echo "FAILED: Validation failed"
                echo ""
                echo "Run 'nix run .#sync' to fix"
                exit 1
              else
                echo "All checks passed"
              fi
            '';
          };

          # SBOM app - pure Nix app (no file materialization)
          sbom = let
            formats = [ "cyclonedx-json" "spdx-json" ];
            scanTarget = ".";
            outputDir = "sbom-output";
          in
          pkgs.writeShellApplication {
            name = "generate-sbom";
            runtimeInputs = [ pkgs.syft ];
            text = ''
              echo "════════════════════════════════════════════════════════════"
              echo "  Generating SBOM"
              echo "════════════════════════════════════════════════════════════"
              echo ""
              echo "Target: ${scanTarget}"
              echo "Formats: ${lib.concatStringsSep ", " formats}"
              echo "Output: ${outputDir}/"
              echo ""

              mkdir -p ${outputDir}

              ${lib.concatMapStringsSep "\n" (format: ''
                echo "Generating ${format} SBOM..."
                syft dir:${scanTarget} -o ${format} > ${outputDir}/sbom.${format}
                echo "✓ ${outputDir}/sbom.${format}"
              '') formats}

              echo ""
              echo "SBOM generation complete"
              echo ""
              echo "Files generated:"
              ls -lh ${outputDir}/
            '';
          };
        in
        {
          # Sync persistent policy files (commit these)
          sync = {
            type = "app";
            program = "${sync}/bin/nixline-sync";
          };

          # Sync ephemeral workflow files (CI only, do not commit)
          sync-ephemeral = {
            type = "app";
            program = "${sync-ephemeral}/bin/nixline-sync-ephemeral";
          };

          # Check persistent files match baseline
          check = {
            type = "app";
            program = "${check}/bin/nixline-check";
          };

          # Generate SBOM (pure app, no materialization)
          sbom = {
            type = "app";
            program = "${sbom}/bin/generate-sbom";
          };
        }
      );
    };
}
