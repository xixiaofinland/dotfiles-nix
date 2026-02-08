# Nix Dotfiles Refactoring Plan

## Context

This plan addresses modularity, duplication, and readability issues in your working cross-platform Nix + home-manager dotfiles configuration (NixOS + macOS). The repository currently works smoothly, so this refactoring prioritizes **safety through incremental changes** with verification after each step.

### Why This Refactoring?

Your dotfiles have grown organically and now contain:
- **Duplication**: Cachix settings duplicated between NixOS and Darwin configs (~35 lines × 2)
- **Large files**: `flake.nix` (464 lines) and `modules/home.nix` (391 lines) mixing multiple concerns
- **Repetitive code**: 10 dev shells with ~90% identical boilerplate (~295 lines)
- **Organization**: Flat module structure makes navigation harder as complexity grows

### Goals

1. **Eliminate duplication** - DRY principle for cachix settings and dev shells
2. **Improve modularity** - Split large files into focused, single-purpose modules
3. **Enhance readability** - Better organization through logical directory structure
4. **Maintain stability** - Zero functional changes, extensive testing after each step

## Proposed Structure

```
/home/finxxi/dotfiles-nix/
├── flake.nix (REDUCED: 464 → ~150 lines)
├── lib/                          # NEW: Reusable functions
│   ├── cachix.nix                # Shared cachix config
│   ├── mkShell.nix               # Dev shell builder
│   └── overlays.nix              # Rust overlays
├── modules/
│   ├── system/                   # System-level configs
│   │   ├── common-config.nix     # (moved from modules/)
│   │   ├── nixos-config.nix      # (moved from modules/)
│   │   ├── mac-config.nix        # (moved from modules/)
│   │   ├── hyprland-config.nix   # (moved from modules/)
│   │   └── hyprland-pc-hardware-configuration.nix
│   └── home/                     # Home-manager configs
│       ├── home.nix (REDUCED: 391 → ~80 lines)
│       ├── home-hyprland.nix     # (moved from modules/)
│       ├── home-combined.nix     # (moved from modules/)
│       ├── packages.nix          # NEW: Package lists
│       ├── environment.nix       # NEW: Env vars & file links
│       └── programs/             # NEW: Program-specific configs
│           ├── fish.nix
│           ├── tmux.nix
│           ├── neovim.nix
│           ├── jujutsu.nix
│           ├── rbw.nix
│           ├── zoxide.nix
│           ├── direnv.nix
│           └── fzf.nix
└── shells/                       # NEW: Dev shells
    ├── default.nix               # Exports all shells
    ├── rust.nix
    ├── python.nix
    ├── ml.nix
    └── ... (6 more)
```

## Implementation Plan: 5 Phases

### Phase 1: Extract Cachix Configuration (PRIORITY 1)

**Impact**: Eliminates 35 lines of duplication, fixes hard-coded username bug
**Risk**: Very low (pure extraction)
**Time**: 30 minutes

**Steps**:

1. Create `lib/cachix.nix`:
   - Extract shared cachix settings from flake.nix lines 60-77 (NixOS) and 145-159 (Darwin)
   - Parameterize with `{userName}` argument
   - Include substituters and trusted-public-keys

2. Update `flake.nix`:
   - In `nixos-baseModules`: Replace lines 60-77 with `(import ./lib/cachix.nix {inherit userName;})`
   - In `darwinConfigurations`: Replace lines 145-159 with module import
   - Fix hard-coded `"xixiao"` on line 159 to use `mac-user` variable

3. Test:
   ```bash
   nix flake check
   darwin-rebuild build --flake .#Xis-MacBook-Pro  # macOS
   nixos-rebuild build --flake .#hyprland-pc       # NixOS
   ```

**Critical files**:
- `/home/finxxi/dotfiles-nix/lib/cachix.nix` (new)
- `/home/finxxi/dotfiles-nix/flake.nix` (modified)

---

### Phase 2: Extract Dev Shell Builder (PRIORITY 2)

**Impact**: Eliminates ~250 lines of boilerplate, improves maintainability
**Risk**: Low (well-tested pattern)
**Time**: 2 hours

**Steps**:

1. Create `lib/mkShell.nix`:
   - Build helper function accepting: name, emoji, packages, envVars, shellHook
   - Auto-generate package list display
   - Handle environment variable exports

2. Create `shells/` directory and individual shell files:
   - `shells/default.nix` - Exports all shells
   - `shells/rust.nix` - Extract from flake.nix lines 170-196
   - `shells/anomaly-rust.nix` - Extract from lines 198-232
   - `shells/afmt.nix` - Extract from lines 234-253
   - `shells/blog.nix` - Extract from lines 255-267
   - `shells/sf.nix` - Extract from lines 269-285
   - `shells/nvim.nix` - Extract from lines 287-334
   - `shells/python.nix` - Extract from lines 336-396
   - `shells/ml.nix` - Extract from lines 398-462

3. Update `flake.nix`:
   - Replace entire `devShells` section (lines 167-462) with:
     ```nix
     devShells = forAllSystems (pkgs: import ./shells {inherit pkgs;});
     ```

4. Test each shell:
   ```bash
   nix flake check
   nix develop         # Test default (rust)
   nix develop .#python
   nix develop .#ml
   ```

**Critical files**:
- `/home/finxfi/dotfiles-nix/lib/mkShell.nix` (new)
- `/home/finxxi/dotfiles-nix/shells/default.nix` (new)
- `/home/finxxi/dotfiles-nix/shells/*.nix` (8 new files)
- `/home/finxxi/dotfiles-nix/flake.nix` (modified, -295 lines!)

---

### Phase 3: Split home.nix into Modules (PRIORITY 3)

**Impact**: Reduces home.nix from 391 to ~80 lines, improves modularity
**Risk**: Medium (large refactoring, do incrementally)
**Time**: 3 hours

**Approach**: Extract one program at a time, test after each extraction

**Steps**:

1. Create `modules/home/` directory structure

2. Create `modules/home/packages.nix`:
   - Extract lines 1-61 from home.nix
   - Include finter package definition and home.packages list

3. Create `modules/home/environment.nix`:
   - Extract lines 63-108 from home.nix
   - Include sessionVariables, home.file, xdg.configFile, home.activation

4. Create program modules in `modules/home/programs/`:
   - `rbw.nix` - Extract lines 110-120
   - `zoxide.nix` - Extract lines 122-126
   - `direnv.nix` - Extract lines 128-131
   - `tmux.nix` - Extract lines 133-228 (96 lines!)
   - `fzf.nix` - Extract lines 230-236
   - `fish.nix` - Extract lines 238-343 (106 lines!!)
   - `neovim.nix` - Extract lines 346-351
   - `jujutsu.nix` - Extract lines 353-387

5. Create new `modules/home/home.nix` as orchestrator:
   ```nix
   {...}: {
     imports = [
       ./packages.nix
       ./environment.nix
       ./programs/fish.nix
       ./programs/tmux.nix
       ./programs/neovim.nix
       ./programs/jujutsu.nix
       ./programs/rbw.nix
       ./programs/zoxide.nix
       ./programs/direnv.nix
       ./programs/fzf.nix
     ];

     home.stateVersion = "24.05";
     programs.home-manager.enable = true;
   }
   ```

6. Move existing home-manager modules:
   - `modules/home-hyprland.nix` → `modules/home/home-hyprland.nix`
   - `modules/home-combined.nix` → `modules/home/home-combined.nix`

7. Update `flake.nix` references:
   - Change all `./modules/home.nix` to `./modules/home/home.nix`
   - Update home-combined and home-hyprland paths

8. Test after each program extraction:
   ```bash
   nix flake check
   home-manager build --flake .#xixiao@Xis-MacBook-Pro  # macOS
   home-manager build --flake .#finxxi@hyprland-pc      # NixOS

   # Test specific programs
   fish --version
   tmux -V
   nvim --version
   jj --version
   ```

**Critical files**:
- `/home/finxxi/dotfiles-nix/modules/home/home.nix` (new orchestrator, ~80 lines)
- `/home/finxxi/dotfiles-nix/modules/home/packages.nix` (new)
- `/home/finxxi/dotfiles-nix/modules/home/environment.nix` (new)
- `/home/finxxi/dotfiles-nix/modules/home/programs/*.nix` (8 new files)

---

### Phase 4: Reorganize System Modules (PRIORITY 4)

**Impact**: Better organization, clearer separation
**Risk**: Very low (just moving files)
**Time**: 30 minutes

**Steps**:

1. Create `modules/system/` directory

2. Move system configuration files:
   - `modules/common-config.nix` → `modules/system/common-config.nix`
   - `modules/nixos-config.nix` → `modules/system/nixos-config.nix`
   - `modules/mac-config.nix` → `modules/system/mac-config.nix`
   - `modules/hyprland-config.nix` → `modules/system/hyprland-config.nix`
   - `modules/hyprland-pc-hardware-configuration.nix` → `modules/system/hyprland-pc-hardware-configuration.nix`

3. Update all references in `flake.nix` to use new paths

4. Test:
   ```bash
   nix flake check
   darwin-rebuild build --flake .#Xis-MacBook-Pro
   nixos-rebuild build --flake .#hyprland-pc
   ```

**Critical files**:
- All files in `/home/finxxi/dotfiles-nix/modules/system/` (moved)
- `/home/finxxi/dotfiles-nix/flake.nix` (update imports)

---

### Phase 5: Extract Overlays & Cleanup (PRIORITY 5)

**Impact**: Final polish, remove dead code
**Risk**: Very low
**Time**: 30 minutes

**Steps**:

1. Create `lib/overlays.nix`:
   - Extract overlay definitions from flake.nix lines 40-49
   - Include rust-overlay and custom rust toolchains

2. Remove commented sfdx-nix code from `flake.nix`:
   - Lines 17-21: Commented input
   - Line 31: Commented output parameter
   - Line 44: Commented overlay reference
   - Lines 85, 93, 114: Commented inherit references

3. Update `flake.nix`:
   - Replace overlay definition with: `overlays = import ./lib/overlays.nix {inherit rust-overlay;};`

4. Verify no other sfdx references:
   ```bash
   rg -n "sfdx" /home/finxxi/dotfiles-nix --type nix
   ```

5. Test:
   ```bash
   nix flake check
   nix develop  # Verify rust overlay works
   ```

**Critical files**:
- `/home/finxxi/dotfiles-nix/lib/overlays.nix` (new)
- `/home/finxxi/dotfiles-nix/flake.nix` (cleanup)

---

## Expected Results

### Line Count Improvements

| File | Before | After | Reduction |
|------|--------|-------|-----------|
| flake.nix | 464 lines | ~150 lines | **68% reduction** |
| modules/home.nix | 391 lines | ~80 lines | **80% reduction** |
| **Total** | **855 lines** | **230 lines** | **73% reduction** |

### Code Organization

- **Eliminated duplication**: ~350 lines (cachix + dev shell boilerplate)
- **New focused modules**: 20+ files (lib, shells, programs)
- **Improved maintainability**: Each file has single, clear purpose
- **Better navigation**: Logical directory hierarchy

### Quality Improvements

✅ **DRY Principle**: Cachix settings and dev shells no longer duplicated
✅ **Single Responsibility**: Each module does one thing well
✅ **Separation of Concerns**: System, home, lib, and shells clearly separated
✅ **Readability**: Smaller files easier to understand and modify
✅ **Maintainability**: Changes to one program don't affect others

## Testing Strategy

After each phase:

1. **Syntax validation**:
   ```bash
   nix flake check
   ```

2. **Build verification**:
   ```bash
   # macOS
   darwin-rebuild build --flake .#Xis-MacBook-Pro

   # NixOS
   nixos-rebuild build --flake .#hyprland-pc

   # Dev shells
   nix develop
   nix develop .#python
   ```

3. **Functional testing**:
   ```bash
   # Test key programs still work
   fish --version
   tmux -V
   nvim --version
   jj --version
   which alejandra
   ```

4. **Rollback strategy**:
   ```bash
   # Commit after each phase
   git add .
   git commit -m "Phase N: [description]"

   # If something breaks
   git revert HEAD
   # or
   git reset --hard HEAD~1
   ```

## Risk Mitigation

- **Incremental approach**: Test after each phase, commit frequently
- **Low-risk first**: Start with pure extraction (cachix, overlays)
- **One program at a time**: In Phase 3, extract and test each program individually
- **Keep backups**: Git commits allow easy rollback
- **Verification**: Extensive testing on both platforms when possible

## Critical Files Summary

Files that will be created/modified during implementation:

**New files**:
- `/home/finxxi/dotfiles-nix/lib/cachix.nix`
- `/home/finxxi/dotfiles-nix/lib/mkShell.nix`
- `/home/finxxi/dotfiles-nix/lib/overlays.nix`
- `/home/finxxi/dotfiles-nix/shells/default.nix`
- `/home/finxxi/dotfiles-nix/shells/*.nix` (8 files)
- `/home/finxxi/dotfiles-nix/modules/home/packages.nix`
- `/home/finxxi/dotfiles-nix/modules/home/environment.nix`
- `/home/finxxi/dotfiles-nix/modules/home/programs/*.nix` (8 files)

**Modified files**:
- `/home/finxxi/dotfiles-nix/flake.nix` (major changes, -300+ lines)
- `/home/finxxi/dotfiles-nix/modules/home/home.nix` (complete rewrite as orchestrator)

**Moved files**:
- All in `modules/` → `modules/system/` or `modules/home/`

## Verification Plan

End-to-end verification after completing all phases:

```bash
# 1. Clean build test
nix flake check

# 2. Build both systems
darwin-rebuild build --flake .#Xis-MacBook-Pro
nixos-rebuild build --flake .#hyprland-pc

# 3. Test all dev shells
for shell in rust anomaly-rust afmt blog sf nvim python ml; do
  echo "Testing $shell..."
  nix develop .#$shell --command echo "✓ $shell works"
done

# 4. Verify home-manager configuration
home-manager build --flake .#xixiao@Xis-MacBook-Pro
home-manager build --flake .#finxxi@hyprland-pc

# 5. Test key programs (after applying config)
fish -c "echo '✓ Fish works'"
tmux -V
nvim --version
jj --version
```

## Implementation Notes

- **Order matters**: Phases build on each other, follow sequence
- **Platform-specific testing**: Some tests only work on respective platforms
- **Commit frequently**: After each successful phase
- **Read-only verification**: Use `build` not `switch` for safer testing
- **Consider incremental**: Can stop after any phase if time-constrained

## Estimated Timeline

- Phase 1: 30 minutes
- Phase 2: 2 hours
- Phase 3: 3 hours (most complex)
- Phase 4: 30 minutes
- Phase 5: 30 minutes
- **Total: 6.5 hours**

Can be split across multiple sessions. Phases 1-2 provide immediate high-value benefits.
