-- ┌─────────────────────────┐
-- │ Plugins outside of MINI │
-- └─────────────────────────┘
--
-- This file contains installation and configuration of plugins outside of MINI.
-- They significantly improve user experience in a way not yet possible with MINI.
-- These are mostly plugins that provide programming language specific behavior.
--
-- Use this file to install and configure other such plugins.

-- Make concise helpers for installing/adding plugins in two stages
local add, later = MiniDeps.add, MiniDeps.later
local now_if_args = _G.Config.now_if_args

-- Tree-sitter ================================================================

-- Tree-sitter is a tool for fast incremental parsing. It converts text into
-- a hierarchical structure (called tree) that can be used to implement advanced
-- and/or more precise actions: syntax highlighting, textobjects, indent, etc.
--
-- Tree-sitter support is built into Neovim (see `:h treesitter`). However, it
-- requires two extra pieces that don't come with Neovim directly:
-- - Language parsers: programs that convert text into trees. Some are built-in
--   (like for Lua), 'nvim-treesitter' provides many others.
-- - Query files: definitions of how to extract information from trees in
--   a useful manner (see `:h treesitter-query`). 'nvim-treesitter' also provides
--   these, while 'nvim-treesitter-textobjects' provides the ones for Neovim
--   textobjects (see `:h text-objects`, `:h MiniAi.gen_spec.treesitter()`).
--
-- Add these plugins now if file (and not 'mini.starter') is shown after startup.
now_if_args(function()
  add({
    source = 'nvim-treesitter/nvim-treesitter',
    -- Use `main` branch since `master` branch is frozen, yet still default
    checkout = 'main',
    -- Update tree-sitter parser after plugin is updated
    hooks = { post_checkout = function() vim.cmd('TSUpdate') end },
  })
  add({
    source = 'nvim-treesitter/nvim-treesitter-textobjects',
    -- Same logic as for 'nvim-treesitter'
    checkout = 'main',
  })

  -- Define languages which will have parsers installed and auto enabled
  local languages = {
    -- These are already pre-installed with Neovim. Used as an example.
    'lua',
    'vimdoc',
    'markdown',
    -- Additional languages for better development experience
    'python',
    'javascript',
    'typescript',
    'html',
    'css',
    'scss',
    'json',
    'yaml',
    'toml',
    'bash',
    'fish',
    'go',
    'rust',
    'c',
    'cpp',
    'java',
    'kotlin',
    'php',
    'ruby',
    'swift',
    'dart',
    'sql',
    'dockerfile',
    'gitignore',
    'gitcommit',
    'diff',
    -- Add here more languages with which you want to use tree-sitter
    -- To see available languages:
    -- - Execute `:=require('nvim-treesitter').get_available()`
    -- - Visit 'SUPPORTED_LANGUAGES.md' file at
    --   https://github.com/nvim-treesitter/nvim-treesitter/blob/main
  }
  local isnt_installed = function(lang)
    return #vim.api.nvim_get_runtime_file('parser/' .. lang .. '.*', false) == 0
  end
  local to_install = vim.tbl_filter(isnt_installed, languages)
  if #to_install > 0 then require('nvim-treesitter').install(to_install) end

  -- Enable tree-sitter after opening a file for a target language
  local filetypes = {}
  for _, lang in ipairs(languages) do
    for _, ft in ipairs(vim.treesitter.language.get_filetypes(lang)) do
      table.insert(filetypes, ft)
    end
  end
  local ts_start = function(ev) vim.treesitter.start(ev.buf) end
  _G.Config.new_autocmd('FileType', filetypes, ts_start, 'Start tree-sitter')
end)

-- Language servers ===========================================================

-- Language Server Protocol (LSP) is a set of conventions that power creation of
-- language specific tools. It requires two parts:
-- - Server - program that performs language specific computations.
-- - Client - program that asks server for computations and shows results.
--
-- Here Neovim itself is a client (see `:h vim.lsp`). Language servers need to
-- be installed separately based on your OS, CLI tools, and preferences.
-- We use Mason to manage LSP servers, formatters, and linters.
--
-- Add it now if file (and not 'mini.starter') is shown after startup.
now_if_args(function()
  -- Install Mason for LSP server management
  add('mason-org/mason.nvim')
  add('mason-org/mason-lspconfig.nvim')
  add('neovim/nvim-lspconfig')
  add('hrsh7th/cmp-nvim-lsp')
  add('b0o/schemastore.nvim')

  -- Configure Mason
  require('mason').setup({
    ui = {
      border = 'rounded',
      icons = {
        package_installed = '✓',
        package_pending = '➜',
        package_uninstalled = '✗'
      }
    }
  })

  -- Configure mason-lspconfig
  require('mason-lspconfig').setup({
    ensure_installed = {
      'lua_ls',      -- Lua
      'pyright',     -- Python
      'ts_ls',       -- TypeScript/JavaScript
      'gopls',       -- Go
      'rust_analyzer', -- Rust
      'clangd',      -- C/C++
      'jsonls',      -- JSON
      'yamlls',      -- YAML
      'html',        -- HTML
      'cssls',       -- CSS
      'tailwindcss', -- Tailwind CSS
    },
    automatic_installation = true,
  })

  -- Configure LSP servers using the modern approach
  local capabilities = require('cmp_nvim_lsp').default_capabilities()

  -- Add additional capabilities
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  capabilities.textDocument.completion.completionItem.resolveSupport = {
    properties = { 'documentation', 'detail', 'additionalTextEdits' }
  }

  -- Global LSP on_attach function
  local on_attach = function(client, bufnr)
    -- Enable completion triggered by <c-x><c-o>
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
    
    -- Mappings for LSP
    local bufopts = { noremap = true, silent = true, buffer = bufnr }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
    vim.keymap.set('n', '<F2>', vim.lsp.buf.rename, bufopts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
    vim.keymap.set('n', '<F4>', vim.lsp.buf.code_action, bufopts)
    vim.keymap.set('n', '<F12>', vim.lsp.buf.definition, bufopts)
    
    -- Diagnostic keymaps
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, bufopts)
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, bufopts)
    vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, bufopts)
  end

  -- Use the modern vim.lsp.enable approach for automatic LSP setup
  vim.lsp.enable({
    'lua_ls',      -- Lua
    'pyright',     -- Python
    'ts_ls',       -- TypeScript/JavaScript
    'gopls',       -- Go
    'rust_analyzer', -- Rust
    'clangd',      -- C/C++
    'jsonls',      -- JSON
    'yamlls',      -- YAML
    'html',        -- HTML
    'cssls',       -- CSS
    'tailwindcss', -- Tailwind CSS
  })

  -- Configure specific LSP servers with custom settings
  local lspconfig = require('lspconfig')

  -- Lua LSP with custom settings
  lspconfig.lua_ls.setup({
    capabilities = capabilities,
    on_attach = on_attach,
    settings = {
      Lua = {
        runtime = { version = 'LuaJIT' },
        diagnostics = { globals = { 'vim' } },
        workspace = { library = vim.api.nvim_get_runtime_file('', true) },
        telemetry = { enable = false },
      },
    },
  })

  -- TypeScript/JavaScript LSP with enhanced settings
  lspconfig.ts_ls.setup({
    capabilities = capabilities,
    on_attach = on_attach,
    filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
    settings = {
      typescript = {
        inlayHints = {
          enabled = true,
        },
        suggest = {
          completeFunctionCalls = true,
        },
        preferences = {
          includePackageJsonAutoImports = 'on',
        },
      },
      javascript = {
        inlayHints = {
          enabled = true,
        },
        suggest = {
          completeFunctionCalls = true,
        },
        preferences = {
          includePackageJsonAutoImports = 'on',
        },
      },
    },
  })

  -- HTML LSP
  lspconfig.html.setup({
    capabilities = capabilities,
    on_attach = on_attach,
    filetypes = { 'html', 'htmldjango', 'htmlmoustache', 'handlebars' },
  })

  -- CSS LSP
  lspconfig.cssls.setup({
    capabilities = capabilities,
    on_attach = on_attach,
  })

  -- Tailwind CSS LSP
  lspconfig.tailwindcss.setup({
    capabilities = capabilities,
    on_attach = on_attach,
    filetypes = { 'html', 'css', 'scss', 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
  })

  -- JSON LSP
  lspconfig.jsonls.setup({
    capabilities = capabilities,
    on_attach = on_attach,
    settings = {
      json = {
        schemas = require('schemastore').json.schemas(),
      },
    },
  })

  -- Python LSP
  lspconfig.pyright.setup({
    capabilities = capabilities,
    on_attach = on_attach,
  })

  -- Go LSP
  lspconfig.gopls.setup({
    capabilities = capabilities,
    on_attach = on_attach,
  })

  -- Rust LSP
  lspconfig.rust_analyzer.setup({
    capabilities = capabilities,
    on_attach = on_attach,
  })

  -- C/C++ LSP
  lspconfig.clangd.setup({
    capabilities = capabilities,
    on_attach = on_attach,
  })

  -- YAML LSP
  lspconfig.yamlls.setup({
    capabilities = capabilities,
    on_attach = on_attach,
  })

  -- LSP autocommands for better diagnostics and formatting
  local augroup = vim.api.nvim_create_augroup('LspFormatting', {})
  local lsp_formatting = function(bufnr)
    vim.lsp.buf.format({
      bufnr = bufnr,
      filter = function(client)
        return client.name ~= 'tsserver' -- Use prettier for JS/TS
      end,
    })
  end

  -- Auto-format on save for supported filetypes
  vim.api.nvim_create_autocmd('BufWritePre', {
    group = augroup,
    pattern = { '*.lua', '*.py', '*.go', '*.rs', '*.cpp', '*.c', '*.h', '*.hpp' },
    callback = function()
      lsp_formatting(vim.api.nvim_get_current_buf())
    end,
  })

  -- Show diagnostics on cursor hold
  vim.api.nvim_create_autocmd('CursorHold', {
    pattern = '*',
    callback = function()
      vim.diagnostic.open_float(nil, { focus = false })
    end,
  })

  -- Highlight references on cursor hold
  vim.api.nvim_create_autocmd('CursorHold', {
    pattern = '*',
    callback = function()
      vim.lsp.buf.document_highlight()
    end,
  })

  -- Clear references when cursor moves
  vim.api.nvim_create_autocmd('CursorMoved', {
    pattern = '*',
    callback = function()
      vim.lsp.buf.clear_references()
    end,
  })

  -- Configure diagnostics
  vim.diagnostic.config({
    virtual_text = true,
    signs = true,
    update_in_insert = false,
    underline = true,
    severity_sort = true,
    float = {
      border = 'rounded',
      source = 'always',
      header = '',
      prefix = '',
    },
  })

  -- Show diagnostics in a floating window
  vim.fn.sign_define('DiagnosticSignError', { text = 'E', texthl = 'DiagnosticSignError' })
  vim.fn.sign_define('DiagnosticSignWarn', { text = 'W', texthl = 'DiagnosticSignWarn' })
  vim.fn.sign_define('DiagnosticSignInfo', { text = 'I', texthl = 'DiagnosticSignInfo' })
  vim.fn.sign_define('DiagnosticSignHint', { text = 'H', texthl = 'DiagnosticSignHint' })

end)

-- Completion =================================================================

-- Auto-completion is a crucial feature for modern code editing. It provides
-- intelligent suggestions as you type, making coding faster and more accurate.
--
-- nvim-cmp is the most popular completion engine for Neovim, providing a
-- unified interface for various completion sources including LSP, snippets,
-- and more.
now_if_args(function()
  add('hrsh7th/nvim-cmp')
  add('hrsh7th/cmp-buffer')
  add('hrsh7th/cmp-path')
  add('hrsh7th/cmp-cmdline')
  add('saadparwaiz1/cmp_luasnip')
  add('L3MON4D3/LuaSnip')

  local cmp = require('cmp')
  local luasnip = require('luasnip')

  cmp.setup({
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end,
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }),
      ['<Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        else
          fallback()
        end
      end, { 'i', 's' }),
      ['<S-Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { 'i', 's' }),
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'luasnip' },
    }, {
      { name = 'buffer' },
      { name = 'path' },
    }),
  })

  -- Set configuration for specific filetypes
  cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
      { name = 'git' },
    }, {
      { name = 'buffer' },
    })
  })

  -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore)
  cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' }
    }
  })

  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore)
  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    })
  })
end)

-- Formatting =================================================================

-- Programs dedicated to text formatting (a.k.a. formatters) are very useful.
-- Neovim has built-in tools for text formatting (see `:h gq` and `:h 'formatprg'`).
-- They can be used to configure external programs, but it might become tedious.
--
-- The 'stevearc/conform.nvim' plugin is a good and maintained solution for easier
-- formatting setup.
later(function()
  add('stevearc/conform.nvim')

  -- Configure formatters
  require('conform').setup({
    formatters_by_ft = {
      lua = { 'stylua' },
      javascript = { 'prettier' },
      javascriptreact = { 'prettier' },
      typescript = { 'prettier' },
      typescriptreact = { 'prettier' },
      json = { 'prettier' },
      yaml = { 'prettier' },
      markdown = { 'prettier' },
      html = { 'prettier' },
      css = { 'prettier' },
      scss = { 'prettier' },
      python = { 'black', 'isort' },
      go = { 'gofmt', 'goimports' },
      rust = { 'rustfmt' },
      c = { 'clang-format' },
      cpp = { 'clang-format' },
    },
    format_on_save = {
      timeout_ms = 500,
      lsp_fallback = true,
    },
  })
end)

-- Snippets ===================================================================

-- Although 'mini.snippets' provides functionality to manage snippet files, it
-- deliberately doesn't come with those.
--
-- The 'rafamadriz/friendly-snippets' is currently the largest collection of
-- snippet files. They are organized in 'snippets/' directory (mostly) per language.
-- 'mini.snippets' is designed to work with it as seamlessly as possible.
-- See `:h MiniSnippets.gen_loader.from_lang()`.
later(function() add('rafamadriz/friendly-snippets') end)

-- Honorable mentions =========================================================

-- 'mason-org/mason.nvim' (a.k.a. "Mason") is a great tool (package manager) for
-- installing external language servers, formatters, and linters. It provides
-- a unified interface for installing, updating, and deleting such programs.
--
-- The caveat is that these programs will be set up to be mostly used inside Neovim.
-- If you need them to work elsewhere, consider using other package managers.
--
-- You can use it like so:
-- later(function()
--   add('mason-org/mason.nvim')
--   require('mason').setup()
-- end)

-- Beautiful, usable, well maintained color schemes outside of 'mini.nvim' and
-- have full support of its highlight groups. Use if you don't like 'miniwinter'
-- enabled in 'plugin/30_mini.lua' or other suggested 'mini.hues' based ones.
MiniDeps.now(function()
  -- Install Catppuccin for clean, minimalist styling
  add('catppuccin/nvim')
  
  -- Configure and enable Catppuccin
  require('catppuccin').setup({
    flavour = "frappe", -- latte, frappe, macchiato, mocha
    background = {
      light = "latte",
      dark = "mocha",
    },
    transparent_background = false,
    show_end_of_buffer = false,
    term_colors = false,
    dim_inactive = {
      enabled = false,
      shade = "dark",
      percentage = 0.15,
    },
    no_italic = false,
    no_bold = false,
    no_underline = false,
    styles = {
      comments = { "italic" },
      conditionals = { "italic" },
      loops = {},
      functions = {},
      keywords = {},
      strings = {},
      variables = {},
      numbers = {},
      booleans = {},
      properties = {},
      types = {},
      operators = {},
    },
    color_overrides = {},
    custom_highlights = {},
    integrations = {
      cmp = true,
      gitsigns = true,
      nvimtree = true,
      telescope = true,
      notify = false,
      mini = {
        enabled = true,
        indentscope_color = "",
      },
    },
  })
  vim.cmd.colorscheme("catppuccin")
end)
