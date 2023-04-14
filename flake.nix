{
  description = "Github Copilot CLI";
  inputs.nixpkgs-path.url = "nixpkgs/release-22.11";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  outputs = { self, nixpkgs-path, flake-utils }: 
    let
      inherit (flake-utils.lib.system) 
        x86_64-darwin 
        aarch64-darwin;
    in flake-utils.lib.eachSystem [ x86_64-darwin aarch64-darwin ] (system: 
      let
        pkgs = nixpkgs-path.legacyPackages.${system};
        node2nix = pkgs.node2nix;
        npm-name = "@githubnext/github-copilot-cli";
        copilot-version = "0.1.32";
        github-copilot-cli-nix = pkgs.runCommand "node2nix-github-copilot-cli-nix" {
            buildInputs = [
              node2nix
            ];
        } ''
        mkdir -p "$out"

        cat > i.json <<-HERE
        [
          { "${npm-name}": "${copilot-version}" }
        ]
        HERE

        node2nix -i i.json
        mv *.nix $out
        '';
        github-copilot-cli = (import github-copilot-cli-nix.out { inherit pkgs; })."${npm-name}-${copilot-version}".override ({
            buildInputs = [
              pkgs.nodePackages.node-pre-gyp
              pkgs.nodePackages.node-gyp-build
            ];
          }
        );
      in
      {
        devShell = pkgs.mkShell {
            packages = [];
            buildInputs = [
              node2nix
            ];
          # Change the prompt to show that you are in a devShell
          shellHook = "export PS1='\\e[1;34mƛ > \\e[0m'";
          };
        apps = rec {
          default = runGithubCopilotCli;
          runGithubCopilotCli = {
            type = "app";
            program = "${github-copilot-cli}/bin/github-copilot-cli";
          };
        };
        packages.default = github-copilot-cli;
      });
}