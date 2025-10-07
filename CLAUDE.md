# NixOS Configuration - AI Discovery Guide

## Repository Structure & Discovery

**User**: hippo | **Location**: `~/nixos-config/` | **Machines**: 3 configurations

### Core Discovery Pattern
```
├── flake.nix              # START HERE: defines all machine configurations
├── machines/{name}/       # Machine-specific: configuration.nix lists all imports
├── programs/              # Each .nix = one program/service (check imports in machines/)
├── dotfiles/              # User configs: common/ + {machine}/ specific
└── scripts/               # Utilities and automation
```

## How to Investigate This Repository

### 1. Understanding Current Setup
- **Check active machine**: Use `hostname` command or ask user which machine they're using (stinkpad/tiny/vm)
- **Find machine config**: `machines/{machine}/configuration.nix` shows all imported programs
- **Discover installed programs**: List files in `programs/` directory
- **Find user configs**: Check `dotfiles/common/` for shared, `dotfiles/{machine}/` for specific

### 2. Understanding Program Architecture
- **Each program** gets its own `programs/{name}.nix` file
- **Pattern**: Read existing `programs/*.nix` files to understand structure
- **Dependencies**: Check `flake.nix` inputs section for external dependencies
- **Dotfile linking**: Look at `scripts/dotfiles-linker/` for symlinking mechanism

### 3. Finding Configuration Files
- **User configs location**: Always in `dotfiles/` hierarchy
- **Shared vs specific**: `common/` = all machines, `{machine}/` = that machine only
- **Config discovery**: Use `find dotfiles/ -name "*.toml" -o -name "*.py" -o -name "config*"` etc.

### 4. Understanding What's Installed
- **System packages**: Check `environment.systemPackages` in `programs/*.nix` files
- **Services**: Look for `services.*` in program modules
- **User setup**: Check `users.users.hippo` configuration in machine configs

## Investigation Strategies

### When User Asks "What's installed?"
1. List `programs/` directory contents
2. Check machine's `configuration.nix` imports
3. Grep for `environment.systemPackages` across programs/

### When User Wants to Add Something
1. Check if program module already exists in `programs/`
2. Look at similar existing modules for patterns
3. Determine if config goes in `dotfiles/common/` or `dotfiles/{machine}/`
4. Find machine config to add import

### When User Reports Issues
1. Check relevant `dotfiles/` configs for the problematic program
2. Look at program's `.nix` file in `programs/`
3. Check machine's import list in `machines/{machine}/configuration.nix`

### When User Wants to Understand Something
1. Use grep/search tools to find references across repository
2. Check git history for context on changes
3. Read program-specific documentation in `dotfiles/` configs

## Working Patterns

### Standard Program Addition Flow
1. **Investigate**: Check if `programs/{name}.nix` exists
2. **Pattern**: Copy similar existing program module structure  
3. **Config**: Add dotfiles to appropriate `dotfiles/` location
4. **Import**: Add module to relevant `machines/*/configuration.nix`

### Discovery Commands
- **List programs**: `ls programs/`
- **Find configs**: `find dotfiles/ -type f`
- **Check imports**: `grep -r "programs/" machines/`
- **System rebuild**: `sudo nixos-rebuild switch --flake .#{machine}`

## AI Guidelines for This Repository
- **Always investigate first** - don't assume what's installed or configured
- **Use file system exploration** - ls, find, grep to understand current state
- **Follow existing patterns** - read similar files before creating new ones
- **Check dependencies** - verify imports and relationships before changes
- **Prefer modifications** - edit existing files rather than creating new ones
