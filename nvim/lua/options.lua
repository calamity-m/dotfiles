vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = "> ", trail = ".", nbsp = "+" }
vim.opt.inccommand = "split"
vim.opt.cursorline = true
vim.opt.hlsearch = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.showtabline = 2

vim.o.mousescroll = "ver:25,hor:6"
vim.o.switchbuf = "useopen,usetab"

-- Start off with fold level of 99 rather than 0
vim.opt.foldlevel = 99 -- current window
vim.opt.foldlevelstart = 99 -- starting level on new buffer

-- Enable experiemental ui2
require("vim._core.ui2").enable()
