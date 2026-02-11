# OpenCode Configuration

This directory contains your global OpenCode configuration managed by Nix + home-manager.

## Overview

This is your **global OpenCode config** that applies across all projects. It's symlinked to `~/.config/opencode/` via home-manager and contains general preferences, formatters, and tools that work everywhere.

For **project-specific** settings, create an `opencode.json` in individual project roots - those will override these global settings.

## Structure

- `opencode.json` - Global configuration file
- `agents/` - Custom agents (optional)
- `commands/` - Custom commands (optional)
- `skills/` - Agent skills (optional)
- `themes/` - Custom themes (optional)

## Configuration

The `opencode.json` includes:

- **Theme**: Using the default "opencode" theme
- **Models**: Claude Sonnet 4.5 for main tasks, Haiku 4.5 for quick tasks
- **Custom Commands**: Generic project commands
  - `/test` - Run tests with coverage
- **Formatters**: 
  - Alejandra for Nix files
  - Prettier for JS/TS/JSON/MD/YAML
- **File Watcher**: Ignores node_modules, .direnv, result, .git, .venv
- **TUI Settings**: Smooth scrolling with acceleration

## Usage

After rebuilding your system config, OpenCode will automatically use this global configuration for all projects.

You can customize it by editing `dotfiles/.opencode/opencode.json` in this repository, then rebuilding your system.

## Project-Specific Overrides

For project-specific settings (e.g., Nix commands in your dotfiles-nix repo), create `opencode.json` in the project root:

```json
{
  "command": {
    "rebuild": {
      "template": "Run sudo nixos-rebuild switch --flake ~/dotfiles-nix/.#hyprland-pc",
      "description": "Rebuild NixOS config"
    }
  }
}
```

## Adding Custom Agents

Create markdown files in `dotfiles/.opencode/agents/` directory. Example:

```markdown
# code-reviewer

You are a meticulous code reviewer focused on best practices.

## Guidelines
- Look for security issues
- Check error handling
- Suggest performance improvements
```

## References

- [OpenCode Docs](https://opencode.ai/docs)
- [Config Schema](https://opencode.ai/docs/config)
- [Custom Commands](https://opencode.ai/docs/commands)
- [Custom Agents](https://opencode.ai/docs/agents)
