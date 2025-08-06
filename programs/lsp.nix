{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Fish shell LSP
    fish-lsp
  ];
}