_:

[
### Development Tools
"gh" # GitHub CLI
"uv" # Python package installer

### Utilities
"mas" # Mac App Store CLI
"media-control" # now-playing info for the sketchybar media widget
"navi" # Interactive cheatsheet tool

"azure-cli"
"gemini-cli"
"openconnect"
"pre-commit"
"agent-browser"
"bun" # JavaScript runtime & package manager (homebrew-core)
"opencode" # AI coding agent built for the terminal
"llama.cpp" # LLM inference in C/C++
# nixpkgs builds mlx with MLX_BUILD_METAL=false (the metal compiler is closed source),
# so the brew bottle is the only way to get GPU inference on Apple Silicon.
"mlx-lm" # Run LLMs with Apple MLX (mlx_lm.generate / mlx_lm.server)
]