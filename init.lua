-- Basic Neovim Settings
vim.opt.relativenumber = true
vim.opt.number = true
vim.o.expandtab = true      -- Use spaces instead of tabs
vim.o.shiftwidth = 2        -- Indent by 2 spaces
vim.o.tabstop = 2           -- A tab is shown as 2 spaces
vim.opt.smartindent = true          -- Enable smart indentation
vim.opt.autoindent = true          -- Enable smart indentation
vim.opt.termguicolors = true        -- Enable true colors
vim.opt.wrap = true -- Enable line wrapping
vim.opt.clipboard = "unnamedplus"   -- Use system clipboard
vim.opt.cursorline = true           -- Highlight the current line
vim.o.ignorecase = true   -- ignore case when searching
vim.o.smartcase = true 

-- Keybindings
vim.g.mapleader = " "               -- Set leader key to Space
vim.keymap.set("n", "<leader>e", ":q<CR>", { silent = true }) -- Quit file
vim.keymap.set("n", "<leader>s", ":w<CR>", { silent = true, desc = "Save file" })
vim.keymap.set("n", "<leader>w", ":wq<CR>", { silent = true, desc = "Save and quit" })
vim.keymap.set("n", "gr", vim.lsp.buf.references, { silent = true })
vim.keymap.set("i", "jk", "<Esc>", { noremap = true }) -- exit insert mode
-- Toggle between relative number and absolute number
vim.keymap.set("n", "<leader>ln", function()
  if vim.opt.relativenumber:get() then
    vim.opt.relativenumber = false
  else
    vim.opt.relativenumber = true
  end
end, { desc = "Toggle line number mode" })

-- tab navigation shortcuts
vim.keymap.set('n', '<leader>j', ':tabprevious<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>k', ':tabnext<CR>', { noremap = true, silent = true })


-- Install lazy.nvim plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

-- set up toggleterminal after init to speed up the loading time of neovim
local function setup_toggleterm()
  require("toggleterm").setup({
    direction = "horizontal",
    size = 12,
    start_in_insert = true,
    persist_mode = false,
  })

  local Terminal = require("toggleterm.terminal").Terminal
  local lazygit = Terminal:new({
    cmd = "env LANG=en_US.UTF-8 lazygit",
    hidden = true,
    direction = "float",
  })

  vim.keymap.set("n", "<leader>t", ":ToggleTerm<CR>", { desc = "Toggle terminal", silent = true })
  vim.keymap.set("n", "<leader>gg", function() lazygit:toggle() end, { desc = "Open Lazygit", silent = true })
  vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]])
  vim.keymap.set("t", "<C-j>", [[<C-\><C-n>:ToggleTerm<CR>]], { silent = true, desc = "Close terminal with Ctrl-j" })
end

-- Plugin Setup
require("lazy").setup({
  {
    "navarasu/onedark.nvim",
    lazy = false,
    priority = 1000,
  },  
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" }, -- Syntax highlighting
  { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } }, -- Fuzzy finder
  { "nvim-tree/nvim-tree.lua", dependencies = { "nvim-tree/nvim-web-devicons" },},
  { "nvim-lualine/lualine.nvim" }, -- Status line
  { "tpope/vim-commentary" }, -- Comment toggle
  -- {
  --   "williamboman/mason.nvim",
  --   config = true
  -- },
  -- {
  --   "williamboman/mason-lspconfig.nvim",
  --   dependencies = { "williamboman/mason.nvim" },
  --   config = true
  -- },
  {
    "neovim/nvim-lspconfig"
  },
  { 
    "hrsh7th/nvim-cmp", 
    dependencies = { 
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "saadparwaiz1/cmp_luasnip"
    } 
  }, -- Autocomplete
  { "L3MON4D3/LuaSnip" }, -- Snippet support
  {
  "akinsho/toggleterm.nvim",
  version = "*",
  cmd = { "ToggleTerm" },
  keys = { "<leader>t", "<leader>gg" },
  config = setup_toggleterm,
  },  
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({})

      local cmp_status, cmp = pcall(require, "cmp")
      if cmp_status then
        local cmp_autopairs = require("nvim-autopairs.completion.cmp")
        cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
      end
    end,
  },
  {
    "justinmk/vim-sneak",
    event = "VeryLazy",
  },
  {
    "lewis6991/gitsigns.nvim",
    event = "InsertEnter", -- only load when you start editing
    config = function()
      require("gitsigns").setup({
        signs = {
          add          = { text = "+" },
          change       = { text = "~" },
          delete       = { text = "_" },
          topdelete    = { text = "‾" },
          changedelete = { text = "~" },
        },
        current_line_blame = true,
        current_line_blame_opts = {
          delay = 1000, -- ms delay before blame appears
          virt_text_pos = "eol", -- show at end of line
        },
      })
    end,
  },
  {
    "akinsho/flutter-tools.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      require("flutter-tools").setup({
        lsp = {
          settings = {
            dart = {
              closingLabels = true,
            }
          }
        }
      })
    end,
  },
  {
    "github/copilot.vim",
    lazy = false, 
    priority = 1000,
    config = function()
      -- Disable default Tab mapping for Copilot to avoid conflicts with nvim-cmp
      vim.g.copilot_no_tab_map = true
      
      -- Set Ctrl+F to accept Copilot suggestions
      vim.keymap.set("i", "<C-f>", 'copilot#Accept("<CR>")', {
        expr = true,
        replace_keycodes = false,
        silent = true,
        desc = "Accept Copilot suggestion"
      })
      
      -- Optional: Add Ctrl+] to dismiss Copilot suggestion
      vim.keymap.set("i", "<C-]>", "<Plug>(copilot-dismiss)", {
        silent = true,
        desc = "Dismiss Copilot suggestion"
      })
      
      -- Optional: Add Ctrl+Right/Left to navigate through suggestions
      vim.keymap.set("i", "<C-Right>", "<Plug>(copilot-next)", {
        silent = true,
        desc = "Next Copilot suggestion"
      })
      vim.keymap.set("i", "<C-Left>", "<Plug>(copilot-previous)", {
        silent = true,
        desc = "Previous Copilot suggestion"
      })
    end,
  },
  {"goolord/alpha-nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = setup_alpha_dashboard,  
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      require("which-key").setup({
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      })
    end,
  }
})

-- theme
-- vim.g.tokyonight_style = "night"
-- require("tokyonight").setup({
--   -- transparent = true
--  })
-- vim.cmd.colorscheme("tokyonight")

-- vim-sneak case insensitive
vim.g["sneak#use_ic_scs"] = 1
vim.api.nvim_set_keymap("n", "s", "<Plug>Sneak_s", {})
vim.api.nvim_set_keymap("n", "S", "<Plug>Sneak_S", {})

-- Treesitter Configuration
require("nvim-treesitter.configs").setup {
  ensure_installed = "all",
  highlight = { enable = true },
}

-- Lualine Configuration
require("lualine").setup()

-- Telescope Keybind
vim.keymap.set("n", "<leader>ff", ":Telescope find_files<CR>", { silent = true })
vim.keymap.set("n", "<leader>/", ":Telescope live_grep<CR>", { silent = true })
vim.keymap.set("n", "<leader>c", ":Telescope lsp_references<CR>", { silent = true })
vim.keymap.set("n", "<leader>d", ":Telescope lsp_definitions<CR>", { silent = true })

vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "LSP Rename" })
vim.keymap.set('n', '<leader>o', ':NvimTreeToggle<CR>', { silent = true })
vim.keymap.set("n", "<leader>fo", ":FlutterOutlineToggle<CR>", { silent = true, desc = "Toggle Flutter Outline" })

vim.keymap.set("n", "<leader>gb", function()
  require("gitsigns").blame_line({ full = true })
end, { desc = "Show full git blame for current line" })

vim.keymap.set("n", "<leader>gr", function()
  require("gitsigns").reset_hunk()
end, { desc = "Reset Git hunk" })

vim.keymap.set("n", "<leader>gp", function()
  require("gitsigns").preview_hunk()
end, { desc = "preview git hunk diff" })

-- LSP Configuration
-- require("mason-lspconfig").setup {
--     ensure_installed = { "pyright", "clangd" },
-- }

-- Python LSP Setup with pyright
local lspconfig = require("lspconfig")

-- Configure pyright for Python
lspconfig.pyright.setup({
  capabilities = require("cmp_nvim_lsp").default_capabilities(),
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "workspace"
      }
    }
  }
})

-- LSP keybindings
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    local opts = { buffer = ev.buf }
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
  end,
})

-- Autocomplete Configuration
local cmp = require("cmp")
local luasnip = require("luasnip")

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = {
    ["<Tab>"] = cmp.mapping.select_next_item(),
    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<C-Space>"] = cmp.mapping.complete(),
  },
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "luasnip" },
  }, {
    { name = "buffer" },
    { name = "path" },
  }),
})

-- nvim-tree setup
require("nvim-tree").setup({
  view = { width = 30, side = "left" },
  renderer = { group_empty = true },
  filters = { dotfiles = false },
})

-- NvimTree keymap: open file in new tab with 't'
vim.api.nvim_create_autocmd("FileType", {
  pattern = "NvimTree",
  callback = function()
    vim.keymap.set("n", "t", function()
     local api = require("nvim-tree.api")
     local node = api.tree.get_node_under_cursor()
      if node and node.link_to or node.nodes == nil then
        vim.cmd("tabnew " .. node.absolute_path)
      end
    end, { buffer = true, silent = true })
  end,
})

-- setting file name and parent as the warp tab name 
vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    vim.schedule(function()  -- 🔁 DEFER the logic
      local filepath = vim.fn.expand("%:p")
      if filepath == "" then
        vim.o.titlestring = "nvim - [No Name]"
        return
      end

      local filename = vim.fn.fnamemodify(filepath, ":t")
      local parent = vim.fn.fnamemodify(filepath, ":h:t")
      vim.cmd("set title")
      vim.o.titlestring = parent .. "/" .. filename
    end)
  end,
})

local function setup_alpha_dashboard()
  local alpha = require("alpha")
  local dashboard = require("alpha.themes.dashboard")

  dashboard.section.header.val = {
    "🧠 Neovim Dashboard",
    "🚀 Ready to code",
  }

  dashboard.section.buttons.val = {
    dashboard.button("f", "🔍  Find file", ":Telescope find_files<CR>"),
    dashboard.button("n", "📄  New file", ":ene <BAR> startinsert<CR>"),
    dashboard.button("r", "🕘  Recent files", ":Telescope oldfiles<CR>"),
    dashboard.button("q", "❌  Quit", ":qa<CR>"),
  }

  alpha.setup(dashboard.config)
end

require("colorscheme")
