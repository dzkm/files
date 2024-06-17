local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
local plugins = require("plugins")

-- Multi options
vim.opt.mouse = { v = true }
vim.opt.wildmode = { longtest = true, list = true }
vim.opt.mouse = { a = true}

-- Single Values
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.cc = '80'
vim.opt.clipboard = { unnamedplus = true}
vim.opt.backupdir = '/home/dfms/.cache/vim'

-- Booleans
vim.opt.showmatch = true
vim.opt.ignorecase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.ttyfast = true
vim.opt.wrap = false 

-- Commands
vim.cmd('filetype plugin indent on')
vim.cmd('filetype plugin on')
vim.cmd('syntax on')

require("lazy").setup(plugins, opts)
require("catppuccin").setup({flavour = "mocha", transparent_background = true})

vim.cmd.colorscheme "catppuccin"
