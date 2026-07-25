{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Fish shell LSP
    fish-lsp
    
    # Go tools
    gopls
    gotools  # includes goimports
    delve
    
    # Language servers and tools
    marksman                           # Markdown LSP
    dockerfile-language-server         # Docker LSP
    docker-compose-language-service    # Docker Compose LSP
    yaml-language-server               # YAML LSP
    nil                               # Nix LSP
    sqls                              # SQL LSP
    rust-analyzer                     # Rust LSP
    taplo                             # TOML LSP
    typescript-language-server        # TypeScript LSP
    ruff                              # Python linter/formatter with LSP
    pyright                           # Python type checker
    clang-tools                       # C/C++ LSP (clangd)
    lua-language-server               # Lua LSP
  ];
}