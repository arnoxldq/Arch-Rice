-- =================================================
-- 🔹 CYBERPUNK NEOVIM SINGLE FILE CONFIG
-- Nordic theme + true transparency + Treesitter + LSP + Telescope + Lualine
-- Safe: Won't crash if Treesitter isn't installed yet
-- =================================================

-- ===== Basic Options =====
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.background = "dark"
vim.opt.cursorline = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.autoindent = true
vim.opt.smartindent = false
vim.opt.wrap = false
vim.opt.clipboard = "unnamedplus"

-- ===== Bootstrap Packer =====
local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  print("Installing packer.nvim...")
  fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
  vim.cmd [[packadd packer.nvim]]
end

-- ===== Plugins =====
require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  use 'alexvzyl/nordic.nvim'
  use 'nvim-lualine/lualine.nvim'
  use { 'nvim-telescope/telescope.nvim', requires = { {'nvim-lua/plenary.nvim'} } }
  use 'nvim-tree/nvim-web-devicons'
  use {'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'}
end)

-- ===== Nordic Theme + True Transparency =====
local ok, nordic = pcall(require, "nordic")
if ok then
  nordic.load({
    style = "dark",
    accent = "#abbcda",
    transparent = {
      floating_windows = true,
      telescope_background = true,
      popup = true
    },
    styles = {
      comments = "italic",
      keywords = "bold",
      functions = "none",
      variables = "none",
      cursorline = "none"
    }
  })
end

-- ===== Highlight Fixes =====
vim.cmd [[
hi Normal guibg=NONE ctermbg=NONE
hi NormalNC guibg=NONE ctermbg=NONE
hi NormalFloat guibg=NONE ctermbg=NONE
hi FloatBorder guibg=NONE ctermbg=NONE
hi VertSplit guibg=NONE ctermbg=NONE
hi CursorLine guibg=NONE gui=NONE
hi LineNr guibg=NONE ctermbg=NONE
]]

-- ===== Lualine =====
local ok, lualine = pcall(require, 'lualine')
if ok then
  lualine.setup {
    options = {
      theme = 'nordic',
      section_separators = '',
      component_separators = '',
      globalstatus = true
    }
  }
end

-- ===== Telescope =====
local ok, telescope = pcall(require, 'telescope')
if ok then
  telescope.setup{
    defaults = {
      prompt_prefix = " ",
      selection_caret = " ",
      layout_strategy = "horizontal",
      layout_config = { width = 0.8, prompt_position = "top" },
      sorting_strategy = "ascending",
      color_devicons = true,
      borderchars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
    }
  }
end

-- ===== Treesitter (safe) =====
local ok, ts_configs = pcall(require, 'nvim-treesitter.configs')
if ok then
  ts_configs.setup{
    ensure_installed = { "c", "cpp", "lua", "python", "bash" },
    highlight = { enable = true },
    indent = { enable = true },
    auto_install = true
  }
end

-- ===== LSP (new vim.lsp API) =====
-- Python
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.lsp.start({ name = "pyright" })
  end
})

-- C/C++
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp" },
  callback = function()
    vim.lsp.start({ name = "clangd" })
  end
})

-- ===== Telescope Keymaps =====
vim.api.nvim_set_keymap('n', '<Leader>ff', "<cmd>Telescope find_files<cr>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Leader>fg', "<cmd>Telescope live_grep<cr>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Leader>fb', "<cmd>Telescope buffers<cr>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Leader>fh', "<cmd>Telescope help_tags<cr>", { noremap = true, silent = true })

-- ===== Safe C/C++ indentation fix =====
vim.cmd [[
augroup c_indent_fix
  autocmd!
  autocmd FileType c,cpp setlocal nosmartindent
  autocmd FileType c,cpp setlocal autoindent
augroup END
]]
