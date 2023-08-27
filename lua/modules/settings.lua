-- Setup utilities directory
local util_dir = os.getenv("HOME") .. "/.config/nvim/.util"

if (vim.fn.isdirectory(util_dir) == false) then
    vim.fn.mkdir(util_dir, "p")
end

-- Mouse input enabled because I'm a villanous snake
vim.opt.mouse = 'a'

-- Enable the use of the system clipboard
vim.opt.clipboard = "unnamed,unnamedplus"

-- Case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Default cursor setting
-- vim.opt.guicursor = ""

-- Objective line numbering
vim.opt.number = true

-- Make tabs great again
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- Indentation and line wrapping
vim.opt.smartindent = true
vim.opt.wrap = false

-- Backups, undos, and swapfiles
vim.opt.backup = true
vim.opt.backupdir = util_dir .. "/backups"
vim.opt.undofile = true
vim.opt.undodir = util_dir .. "/undos"
vim.opt.swapfile = false

-- Search highlighting
vim.opt.hlsearch = false
vim.opt.incsearch = true

-- Color scheming
vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.opt.colorcolumn = "80"

-- Python3 path
vim.g.python3_host_prog = '/usr/local/bin/python3'
