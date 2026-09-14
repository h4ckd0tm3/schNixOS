{ graphify }:

{
  # Nix packages installed into the home profile on every Mac (via
  # modules/darwin/home-base.nix). Prefer this over `globals` when nixpkgs
  # already ships the tool.
  packages = [
    graphify # Turn a code/docs folder into a queryable knowledge graph
  ];

  # Persistent global npm CLIs (npm install -g). Pin versions here.
  globals = [
    "uipro-cli@2.2.3" # ui-ux-pro-max CLI
  ];

  # Setup/installer commands run on each rebuild, after globals are installed.
  # `bin` is checked on PATH first; `run` is executed if present.
  setup = [
    # ui-ux-pro-max: wire the installed CLI into Claude Code.
    # uipro init installs into <cwd>/.claude/skills and has no --global flag,
    # so run it from $HOME to land in ~/.claude/skills/ (global for the user).
    { bin = "uipro"; run = "sh -c 'cd $HOME && uipro init --ai claude'"; }
    # GSD (get-shit-done): one-time installer, kept current via @latest
    { bin = "npx"; run = "npx --yes @opengsd/gsd-core@latest --claude --global"; }
    # Anthropic Cybersecurity Skills, installed via the `skills` CLI
    #{ bin = "npx"; run = "npx --yes skills add mukul975/Anthropic-Cybersecurity-Skills"; }
    # i-have-adhd (ADHD-friendly output style): plugin for Claude Code and Codex.
    # Marketplace add + install are idempotent; invoke via /i-have-adhd or $i-have-adhd.
    { bin = "claude"; run = "sh -c 'claude plugin marketplace add ayghri/i-have-adhd && claude plugin install i-have-adhd@i-have-adhd'"; }
    { bin = "codex"; run = "sh -c 'codex plugin marketplace add ayghri/i-have-adhd --ref main && codex plugin add i-have-adhd@i-have-adhd'"; }
    # graphify (https://github.com/Graphify-Labs/graphify): copies the skill to
    # ~/.claude/skills/graphify (and registers it in ~/.claude/CLAUDE.md) resp.
    # ~/.codex/skills/graphify. Re-running refreshes the skill after upgrades.
    # Usage: `/graphify .` inside a repo; output lands in graphify-out/.
    { bin = "graphify"; run = "graphify install --platform claude"; }
    { bin = "graphify"; run = "graphify install --platform codex"; }
  ];
}
