-- Basic Neovim Settings
-- vim.opt.expandtab = true            -- Use spaces instead of tabs
-- vim.opt.tabstop = 4                 -- Set tab width to 4 spaces
-- vim.opt.shiftwidth = 4              -- Set indentation width to 4 spaces
vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.smartindent = true          -- Enable smart indentation
vim.opt.termguicolors = true        -- Enable true colors
vim.opt.wrap = true -- Enable line wrapping
vim.opt.clipboard = "unnamedplus"   -- Use system clipboard
vim.opt.cursorline = true           -- Highlight the current line
vim.o.ignorecase = true   -- ignore case when searching
vim.o.smartcase = true 

-- Keybindings
vim.g.mapleader = " "               -- Set leader key to Space
vim.keymap.set("n", "<leader>q", ":q<CR>", { silent = true }) -- Quit file
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
  { "folke/tokyonight.nvim", lazy = false, priority = 1000 },
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" }, -- Syntax highlighting
  { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } }, -- Fuzzy finder
  { "nvim-tree/nvim-tree.lua", dependencies = { "nvim-tree/nvim-web-devicons" },},
  { "nvim-lualine/lualine.nvim" }, -- Status line
  { "tpope/vim-commentary" }, -- Comment toggle
  { "neovim/nvim-lspconfig" }, -- LSP support
  { "hrsh7th/nvim-cmp", dependencies = { "hrsh7th/cmp-nvim-lsp" } }, -- Autocomplete
  { "L3MON4D3/LuaSnip" }, -- Snippet support
  {
  "akinsho/toggleterm.nvim",
  version = "*",
  cmd = { "ToggleTerm" },
  keys = { "<leader>t", "<leader>gg" },
  config = setup_toggleterm,
  }  
})

-- theme
vim.g.tokyonight_style = "night"
vim.cmd.colorscheme("tokyonight")

-- Treesitter Configuration
require("nvim-treesitter.configs").setup {
  ensure_installed = "all",
  highlight = { enable = true },
}

-- Lualine Configuration
require("lualine").setup()

-- Telescope Keybind
vim.keymap.set("n", "<leader>f", ":Telescope find_files<CR>", { silent = true })
vim.keymap.set("n", "<leader>/", ":Telescope live_grep<CR>", { silent = true })
vim.keymap.set("n", "<leader>r", ":Telescope lsp_references<CR>", { silent = true })
vim.keymap.set("n", "<leader>d", ":Telescope lsp_definitions<CR>", { silent = true })
vim.keymap.set('n', '<leader>o', ':NvimTreeToggle<CR>', { silent = true })

-- LSP Configuration
local lspconfig = require("lspconfig")
lspconfig.pyright.setup {}  -- Python LSP
lspconfig.clangd.setup {}   -- C/C++ LSP

-- Autocomplete Configuration
local cmp = require("cmp")
cmp.setup({
  mapping = {
    ["<Tab>"] = cmp.mapping.select_next_item(),
    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
  },
  sources = { { name = "nvim_lsp" } },
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
