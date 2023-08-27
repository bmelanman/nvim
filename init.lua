
require("modules.packer")
require("modules.settings")
require("modules.remap")

local augroup = vim.api.nvim_create_augroup
local userGroup = augroup('user', {})
local yank_group = augroup('HighlightYank', {})
-- Automatically source and re-compile packer whenever this file is changed
local packer_group = augroup('Packer', { clear = true })

local autocmd = vim.api.nvim_create_autocmd

function R(name)
    require("plenary.reload").reload_module(name)
end

autocmd('TextYankPost', {
    group = yank_group,
    pattern = '*',
    callback = function()
        vim.highlight.on_yank({
            higroup = 'IncSearch',
            timeout = 40,
        })
    end,
})

autocmd({"BufWritePre"}, {
    group = userGroup,
    pattern = "*",
    command = [[%s/\s\+$//e]],
})

vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25

autocmd('BufWritePost', {
    command = 'source <file> | silent! LspStop | silent! LspStart | PackerCompile',
    group = packer_group,
    pattern = vim.fn.expand '$MYVIMRC',
})

