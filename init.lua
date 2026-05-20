-- ══════════════════════════════════════════════════════════
--  Neovim config — single file, cross-platform (macOS/Linux/Windows)
-- ══════════════════════════════════════════════════════════

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Leader
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Path separator helper
local IS_WIN = vim.fn.has("win32") == 1
local SEP = IS_WIN and "\\" or "/"

-- ── Options ──────────────────────────────────────────────
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true
vim.opt.termguicolors = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.undofile = true
vim.opt.updatetime = 250
vim.opt.completeopt = "menu,menuone,noselect"
vim.opt.clipboard = "unnamedplus"
vim.opt.mouse = "a"
vim.opt.showmode = false

-- ── Keymaps (copy/paste/undo like normal editors) ────────
vim.keymap.set("v", "y", "y", { desc = "Copy (yank)" })       -- visual select + y = copy
vim.keymap.set("n", "<leader>p", '"+p', { desc = "Paste from clipboard" })
vim.keymap.set("v", "<leader>y", '"+y', { desc = "Copy to clipboard" })
-- Ctrl+S to save
vim.keymap.set({ "n", "i", "v" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })
-- Ctrl+Z to undo
vim.keymap.set({ "n", "i" }, "<C-z>", "<cmd>undo<cr>", { desc = "Undo" })

-- ── Prevent accidental exit: only :q/:qa can quit ───────
-- When last buffer closes, create a new empty buffer instead of quitting
vim.api.nvim_create_autocmd("QuitPre", {
  callback = function()
    -- Allow :q/:qa (command-line mode) to quit normally
    if vim.fn.mode() == "c" then return end
    -- Count real windows (exclude floating, neo-tree, etc.)
    local real_wins = 0
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local cfg = vim.api.nvim_win_get_config(win)
      if cfg.relative == "" then real_wins = real_wins + 1 end
    end
    -- If this is the last real window, open a new buffer instead of quitting
    if real_wins <= 1 then
      vim.cmd("enew")
      vim.cmd("setlocal bufhidden=wipe")
      -- Cancel the quit
      vim.api.nvim_err_writeln("Last window — use :q to quit")
      error("abort quit")
    end
  end,
})

-- ══════════════════════════════════════════════════════════
--  All plugins in one place
-- ══════════════════════════════════════════════════════════
require("lazy").setup({

  -- ── Theme ────────────────────────────────────────────
  {
    "rebelot/kanagawa.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("kanagawa").setup({ compile = true, transparent = false, theme = "wave", dimInactive = true })
      vim.cmd.colorscheme("kanagawa")
    end,
  },

  -- ── UI ───────────────────────────────────────────────
  { "nvim-tree/nvim-web-devicons", lazy = true },

  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = { theme = "kanagawa", component_separators = { left = "", right = "" }, section_separators = { left = "", right = "" }, globalstatus = true },
    },
  },

  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    opts = { options = { diagnostics = "nvim_lsp", offsets = { { filetype = "neo-tree", text = "Explorer", padding = 1 } } } },
    keys = {
      { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev buffer" },
      { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
    },
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    opts = { indent = { char = "│" }, scope = { enabled = true } },
  },

  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    config = function()
      local db = require("alpha.themes.dashboard")
      db.section.header.val = {
        [[  ███╗   ██╗██╗   ██╗██╗███╗   ███╗  ]],
        [[  ████╗  ██║██║   ██║██║████╗ ████║  ]],
        [[  ██╔██╗ ██║██║   ██║██║██╔████╔██║  ]],
        [[  ██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║  ]],
        [[  ██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║  ]],
        [[  ╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝  ]],
      }
      db.section.buttons.val = {
        db.button("f", "  Find file", ":Telescope find_files<CR>"),
        db.button("g", "  Live grep", ":Telescope live_grep<CR>"),
        db.button("r", "  Recent files", ":Telescope oldfiles<CR>"),
        db.button("l", "  Lazy", ":Lazy<CR>"),
        db.button("q", "  Quit", ":qa<CR>"),
      }
      require("alpha").setup(db.opts)
    end,
  },

  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
    opts = {
      lsp = { override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        ["cmp.entry.get_documentation"] = true,
      }},
      presets = { bottom_search = true, command_palette = true, lsp_doc_border = true },
    },
  },

  -- ── File explorer ────────────────────────────────────
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons", "MunifTanjim/nui.nvim" },
    keys = {
      { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Explorer" },
      { "<leader>o", "<cmd>Neotree focus<cr>", desc = "Focus explorer" },
    },
    opts = {
      close_if_last_window = true,
      filesystem = { follow_current_file = { enabled = true }, use_libuv_file_watcher = true, filtered_items = { visible = true, hide_dotfiles = false, hide_gitignored = false } },
      window = { width = 35, mappings = { ["<space>"] = "none" } },
      default_component_configs = {
        indent = { with_expanders = true },
        git_status = { symbols = { added = "", modified = "", deleted = "✖", renamed = "󰁕", untracked = "" } },
      },
    },
  },

  -- ── Telescope ────────────────────────────────────────
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      "nvim-telescope/telescope-ui-select.nvim",
    },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent files" },
      { "<leader>fd", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics" },
      { "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Symbols" },
      { "<leader>fw", "<cmd>Telescope lsp_workspace_symbols<cr>", desc = "Workspace symbols" },
      { "<leader>gc", "<cmd>Telescope git_commits<cr>", desc = "Git commits" },
      { "<leader>gb", "<cmd>Telescope git_branches<cr>", desc = "Git branches" },
      { "<leader>gs", "<cmd>Telescope git_status<cr>", desc = "Git status" },
      { "gr", "<cmd>Telescope lsp_references<cr>", desc = "References" },
      { "gd", "<cmd>Telescope lsp_definitions<cr>", desc = "Definitions" },
      { "gi", "<cmd>Telescope lsp_implementations<cr>", desc = "Implementations" },
      { "gt", "<cmd>Telescope lsp_type_definitions<cr>", desc = "Type definitions" },
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          prompt_prefix = "   ", selection_caret = " ",
          layout_config = { horizontal = { preview_width = 0.55 } },
          file_ignore_patterns = { "node_modules", ".git/", "dist/" },
        },
        extensions = {
          fzf = { fuzzy = true, override_generic_sorter = true, override_file_sorter = true },
          ["ui-select"] = { require("telescope.themes").get_dropdown() },
        },
      })
      telescope.load_extension("fzf")
      telescope.load_extension("ui-select")
    end,
  },

  -- ── Treesitter ───────────────────────────────────────
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      ensure_installed = {
        "lua", "typescript", "tsx", "javascript", "python", "go", "rust",
        "html", "css", "json", "yaml", "toml", "bash", "markdown", "markdown_inline",
        "dockerfile", "sql", "vim", "vimdoc", "regex",
      },
      auto_install = true,
    },
    main = "nvim-treesitter",
  },

  -- ── LSP (Mason + native vim.lsp) ────────────────────
  { "hrsh7th/cmp-nvim-lsp", lazy = true },

  {
    "mason-org/mason.nvim",
    build = ":MasonUpdate",
    config = function()
      require("mason").setup()

      -- Add Mason bin to PATH (cross-platform)
      local mason_bin = vim.fn.stdpath("data") .. SEP .. "mason" .. SEP .. "bin"
      local path_sep = IS_WIN and ";" or ":"
      if not vim.env.PATH:find(mason_bin, 1, true) then
        vim.env.PATH = mason_bin .. path_sep .. vim.env.PATH
      end

      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Keymaps on LSP attach
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = ev.buf, desc = "LSP: " .. desc })
          end
          map("K", vim.lsp.buf.hover, "Hover")
          map("<leader>ca", vim.lsp.buf.code_action, "Code action")
          map("<leader>rn", vim.lsp.buf.rename, "Rename")
          map("<leader>D", vim.lsp.buf.declaration, "Declaration")
          map("[d", function() vim.diagnostic.jump({ count = -1 }) end, "Prev diagnostic")
          map("]d", function() vim.diagnostic.jump({ count = 1 }) end, "Next diagnostic")
          map("<leader>dd", vim.diagnostic.open_float, "Diagnostic float")
        end,
      })

      vim.diagnostic.config({
        signs = { text = {
          [vim.diagnostic.severity.ERROR] = " ",
          [vim.diagnostic.severity.WARN] = " ",
          [vim.diagnostic.severity.HINT] = "󰌵 ",
          [vim.diagnostic.severity.INFO] = " ",
        }},
        virtual_text = { prefix = "●" },
        float = { border = "rounded" },
      })

      -- Server definitions
      local servers = {
        pyright       = { cmd = { "pyright-langserver", "--stdio" }, filetypes = { "python" }, root_markers = { "pyproject.toml", "setup.py", "requirements.txt", ".git" } },
        ts_ls         = { cmd = { "typescript-language-server", "--stdio" }, filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" }, root_markers = { "tsconfig.json", "package.json", ".git" } },
        lua_ls        = { cmd = { "lua-language-server" }, filetypes = { "lua" }, root_markers = { ".luarc.json", ".git" },
          settings = { Lua = { runtime = { version = "LuaJIT" }, diagnostics = { globals = { "vim" } }, workspace = { library = vim.api.nvim_get_runtime_file("", true), checkThirdParty = false }, telemetry = { enable = false } } },
        },
        gopls         = { cmd = { "gopls" }, filetypes = { "go", "gomod", "gowork", "gotmpl" }, root_markers = { "go.mod", ".git" } },
        rust_analyzer = { cmd = { "rust-analyzer" }, filetypes = { "rust" }, root_markers = { "Cargo.toml", ".git" } },
        html          = { cmd = { "vscode-html-language-server", "--stdio" }, filetypes = { "html" }, root_markers = { ".git" } },
        cssls         = { cmd = { "vscode-css-language-server", "--stdio" }, filetypes = { "css", "scss", "less" }, root_markers = { ".git" } },
        tailwindcss   = { cmd = { "tailwindcss-language-server", "--stdio" }, filetypes = { "html", "css", "javascript", "typescript", "typescriptreact", "javascriptreact" }, root_markers = { "tailwind.config.js", "tailwind.config.ts", ".git" } },
        jsonls        = { cmd = { "vscode-json-language-server", "--stdio" }, filetypes = { "json", "jsonc" }, root_markers = { ".git" } },
        yamlls        = { cmd = { "yaml-language-server", "--stdio" }, filetypes = { "yaml", "yml" }, root_markers = { ".git" } },
        bashls        = { cmd = { "bash-language-server", "start" }, filetypes = { "sh", "bash", "zsh" }, root_markers = { ".git" } },
        dockerls      = { cmd = { "docker-langserver", "--stdio" }, filetypes = { "dockerfile" }, root_markers = { "Dockerfile", ".git" } },
      }

      local names = {}
      for name, cfg in pairs(servers) do
        cfg.capabilities = capabilities
        vim.lsp.config(name, cfg)
        table.insert(names, name)
      end
      vim.lsp.enable(names)
    end,
  },

  -- ── Autocompletion ───────────────────────────────────
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-buffer", "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline", "L3MON4D3/LuaSnip", "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets", "onsails/lspkind.nvim",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      local lspkind = require("lspkind")
      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
        window = { completion = cmp.config.window.bordered(), documentation = cmp.config.window.bordered() },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fb) if cmp.visible() then cmp.select_next_item() elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump() else fb() end end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fb) if cmp.visible() then cmp.select_prev_item() elseif luasnip.jumpable(-1) then luasnip.jump(-1) else fb() end end, { "i", "s" }),
        }),
        sources = cmp.config.sources(
          { { name = "nvim_lsp", priority = 1000 }, { name = "luasnip", priority = 750 }, { name = "path", priority = 500 } },
          { { name = "buffer", priority = 250 } }
        ),
        formatting = { format = lspkind.cmp_format({ mode = "symbol_text", maxwidth = 50, ellipsis_char = "..." }) },
      })
      cmp.setup.cmdline(":", { mapping = cmp.mapping.preset.cmdline(), sources = { { name = "cmdline" }, { name = "path" } } })
      cmp.setup.cmdline("/", { mapping = cmp.mapping.preset.cmdline(), sources = { { name = "buffer" } } })
    end,
  },

  -- ── Git ──────────────────────────────────────────────
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      signs = {
        add          = { text = "│" },
        change       = { text = "│" },
        delete       = { text = "_" },
        topdelete    = { text = "‾" },
        changedelete = { text = "~" },
      },
      on_attach = function(buf)
        local gs = require("gitsigns")
        local map = function(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buf, desc = desc })
        end
        map("n", "]h", function() gs.nav_hunk("next") end, "Next hunk")
        map("n", "[h", function() gs.nav_hunk("prev") end, "Prev hunk")
        map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
        map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
        map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
        map("n", "<leader>hS", gs.stage_buffer, "Stage buffer")
        map("n", "<leader>hu", gs.undo_stage_hunk, "Undo stage hunk")
        map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame line")
        map("n", "<leader>hd", gs.diffthis, "Diff this")
      end,
    },
  },

  {
    "NeogitOrg/neogit",
    cmd = "Neogit",
    dependencies = { "nvim-lua/plenary.nvim", "sindrets/diffview.nvim" },
    keys = {
      { "<leader>gg", "<cmd>Neogit<cr>", desc = "Neogit (git status)" },
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diff view" },
      { "<leader>gl", "<cmd>Neogit log<cr>", desc = "Git log" },
    },
    opts = { integrations = { diffview = true } },
  },

  { "sindrets/diffview.nvim", cmd = { "DiffviewOpen", "DiffviewFileHistory" } },

  -- ── Terminal (toggle with Ctrl+`) ────────────────────
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = {
      { "<C-\\>", "<cmd>ToggleTerm<cr>", desc = "Toggle terminal", mode = { "n", "t" } },
      { "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "Float terminal" },
      { "<leader>th", "<cmd>ToggleTerm direction=horizontal size=15<cr>", desc = "Horizontal terminal" },
      { "<leader>tv", "<cmd>ToggleTerm direction=vertical size=80<cr>", desc = "Vertical terminal" },
      { "<leader>tt", "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" },
    },
    opts = {
      open_mapping = [[<C-\>]],
      direction = "horizontal",
      size = 15,
      shade_terminals = true,
      shell = IS_WIN and "pwsh" or vim.o.shell,
    },
  },

  -- ── Markdown render (in-editor) ──────────────────────
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    opts = {},
  },

  -- ── Editor extras ────────────────────────────────────
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },
  { "numToStr/Comment.nvim", event = { "BufReadPost", "BufNewFile" }, opts = {} },
  { "folke/which-key.nvim", event = "VeryLazy", opts = {} },

}, {
  change_detection = { notify = false },
  checker = { enabled = true, notify = false },
})

vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    vim.schedule(function()
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf)
          and vim.api.nvim_buf_get_name(buf) == ""
          and vim.bo[buf].buftype == ""
          and vim.api.nvim_buf_line_count(buf) == 1
          and vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] == ""
          and buf ~= vim.api.nvim_get_current_buf()
        then
          pcall(vim.api.nvim_buf_delete, buf, {})
        end
      end
    end)
  end,
})

-- ── Run current file (Space + r) ─────────────────────────
local run_cmds = {
  python     = "python3 %s",
  javascript = "node %s",
  typescript = "npx ts-node %s",
  lua        = "lua %s",
  go         = "go run %s",
  rust       = "cargo run",
  sh         = "bash %s",
  bash       = "bash %s",
}
vim.keymap.set("n", "<leader>r", function()
  local ft = vim.bo.filetype
  local cmd = run_cmds[ft]
  if not cmd then
    vim.notify("No run command for filetype: " .. ft, vim.log.levels.WARN)
    return
  end
  local file = vim.fn.expand("%:p")
  local full_cmd = string.format(cmd, file)
  -- Use toggleterm to run
  local ok, term = pcall(require, "toggleterm.terminal")
  if ok then
    term.Terminal:new({ cmd = full_cmd, direction = "horizontal", close_on_exit = false }):toggle()
  else
    vim.cmd("split | terminal " .. full_cmd)
  end
end, { desc = "Run current file" })
