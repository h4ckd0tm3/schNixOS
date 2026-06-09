_:

{
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
    { bin = "npx"; run = "npx --yes skills add mukul975/Anthropic-Cybersecurity-Skills"; }
  ];
}
