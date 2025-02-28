vim.cmd("let g:netrw_liststyle = 3")

local opt = vim.opt

opt.relativenumber = true
opt.number = true
opt.wrap = false

opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = false
opt.autoindent = true

opt.ignorecase = true
opt.smartcase = true

opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"

opt.clipboard:append("unnamedplus")

opt.splitright = true
opt.splitbelow = true

if vim.g.neovide then
  vim.o.guifont = "JetBrainsMono NFM:h14" -- text below applies for VimScript
  vim.g.neovide_scale_factor = 1.7
  vim.opt.linespace = 0
end
