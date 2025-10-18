# Neovim Configuration - Minimax with Helix Inspiration

A clean, minimalist Neovim configuration based on the minimax defaults with Helix-inspired keybindings and workflow.

## Features

- **Clean, minimalist design** with Catppuccin colorscheme
- **Helix-inspired keybindings** for intuitive modal editing
- **LSP support** with auto-completion and diagnostics
- **File tree** with MiniFiles
- **Fuzzy finder** with MiniPick
- **Git integration** with MiniGit
- **Syntax highlighting** with Treesitter
- **Comment toggling** and auto-pairs
- **Indent guides** and visual enhancements
- **Mini plugins** for additional functionality

## Installation

1. Make sure you have Neovim 0.9+ installed
2. Clone or copy this configuration to `~/.config/nvim/`
3. Start Neovim and let MiniDeps install all plugins automatically

## Key Bindings

### Navigation
- `<leader>ff` - Find files
- `<leader>fg` - Live grep
- `<leader>fb` - Find buffers
- `<leader>fh` - Find help
- `<leader>fr` - Find recent files
- `<leader>fc` - Find commands

### File Tree
- `<leader>ed` - Open file explorer
- `<leader>ef` - Open directory of current file

### Window Management
- `<C-h/j/k/l>` - Navigate between windows
- `<C-Up/Down/Left/Right>` - Resize windows

### Buffer Management
- `<S-h/l>` - Previous/next buffer
- `<leader>bd` - Delete buffer
- `<leader>bw` - Wipeout buffer

### Selection (Helix-inspired)
- `<leader>ea` - Select all
- `<leader>ew` - Select current word
- `<leader>el` - Select current line
- `<leader>ee` - Select to end of line
- `<leader>eb` - Select to beginning of line
- `<leader>ei/I` - Select inside/around parentheses
- `<leader>e[/]` - Select inside/around brackets
- `<leader>e{/}` - Select inside/around braces
- `<leader>e'/"` - Select inside/around quotes

### Editing
- `<leader>ed` - Duplicate line
- `<leader>eD` - Delete line
- `<leader>ej` - Join lines
- `<leader>es` - Split line
- `<leader>ec` - Toggle comment
- `<leader>er` - Find and replace
- `<leader>ey` - Yank to system clipboard
- `<leader>ep` - Paste from system clipboard

### LSP
- `<leader>ld` - Show diagnostic popup
- `<leader>la` - Code actions
- `<leader>lr` - Rename
- `<leader>ls` - Go to definition
- `<leader>lR` - References
- `<leader>lf` - Format

### Git
- `<leader>gs` - Show Git info at cursor
- `<leader>gd` - Show diff
- `<leader>gl` - Show log
- `<leader>go` - Toggle diff overlay

## Configuration Structure

```
~/.config/nvim/
├── init.lua                 # Main entry point
├── plugin/                  # Plugin configurations
│   ├── 10_options.lua      # Neovim options
│   ├── 20_keymaps.lua      # Key mappings
│   ├── 30_mini.lua         # MINI configuration
│   └── 40_plugins.lua      # External plugins
├── after/                   # Override configurations
│   ├── ftplugin/           # Filetype-specific settings
│   ├── lsp/                # LSP configurations
│   └── snippets/           # Snippet files
├── snippets/                # Global snippets
└── README.md               # This file
```

## Customization

The configuration is modular and easy to customize:

- **Colorscheme**: Edit `plugin/40_plugins.lua` and change the Catppuccin flavor
- **Keybindings**: Modify `plugin/20_keymaps.lua`
- **Options**: Adjust `plugin/10_options.lua`
- **Mini modules**: Configure `plugin/30_mini.lua`
- **External plugins**: Add to `plugin/40_plugins.lua`

## LSP Servers

The following LSP servers are automatically enabled:
- lua_ls (Lua)
- pyright (Python)
- tsserver (TypeScript/JavaScript)
- gopls (Go)
- rust_analyzer (Rust)
- clangd (C/C++)
- jsonls (JSON)
- yamlls (YAML)
- html (HTML)
- cssls (CSS)
- tailwindcss (Tailwind CSS)

## Requirements

- Neovim 0.9+
- Git
- Node.js (for some LSP servers)
- Python (for some LSP servers)
- tree-sitter CLI (for syntax highlighting)

## Getting Started

1. Open Neovim
2. Wait for MiniDeps to install all plugins
3. Restart Neovim
4. Start coding!

The configuration will automatically set up LSP servers and provide a clean, efficient editing experience inspired by Helix's workflow.

## Helix-Inspired Features

This configuration draws heavily from Helix's design philosophy:

- **Modal editing** with intuitive key combinations
- **Selection-first workflow** with easy text object selection
- **Clean, minimalist interface** with focused functionality
- **Efficient navigation** with smart defaults
- **System clipboard integration** for seamless workflow

## Mini.nvim Integration

This configuration is built on top of the excellent mini.nvim library, providing:

- **MiniFiles** - File explorer with Miller columns
- **MiniPick** - Fuzzy finder for everything
- **MiniGit** - Git integration
- **MiniCompletion** - LSP completion
- **MiniSnippets** - Snippet management
- **MiniSurround** - Surround text operations
- **MiniAlign** - Text alignment
- **MiniComment** - Comment toggling
- **MiniPairs** - Auto-pairs
- **MiniStatusline** - Clean statusline
- **MiniTabline** - Buffer management
- **MiniStarter** - Start screen

And many more mini modules for a complete editing experience.