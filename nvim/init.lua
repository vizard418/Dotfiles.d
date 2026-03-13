local opt = vim.opt

-- Performance
opt.lazyredraw = true
opt.synmaxcol = 300
opt.updatetime = 1000
opt.shortmess:append("c")

-- Appearance
opt.number = true
opt.wrap = false
opt.background = "dark"

-- UI
opt.showcmd = true
opt.ruler = true
opt.wildmenu = true
opt.mouse = "a"

-- Clipboard
opt.clipboard = "unnamedplus"

vim.keymap.set("v", "y", '"+y')
vim.keymap.set("v", "Y", '"+y')

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- Indentation
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true
opt.backspace = "indent,eol,start"

-- Encoding
opt.encoding = "utf-8"

-- Sound
opt.errorbells = false

-- Colors
opt.termguicolors = true

vim.cmd("syntax enable")

-- Gruvbox-like colors
vim.cmd [[
highlight clear

highlight Normal guifg=#FBF1C7 guibg=#32302F
highlight Cursor guifg=#32302F guibg=#D65D0E
highlight CursorLine guibg=#504945
highlight LineNr guifg=#A89984 guibg=#32302F
highlight Comment guifg=#928374 gui=italic
highlight Visual guibg=#504945
highlight Pmenu guifg=#FBF1C7 guibg=#504945
highlight PmenuSel guifg=#32302F guibg=#D65D0E
highlight MatchParen guifg=#FB4934 guibg=#504945 gui=bold
highlight Search guifg=#32302F guibg=#FABD2F gui=bold
highlight Constant guifg=#FE8019
highlight String guifg=#B8BB26
highlight Identifier guifg=#8EC07C
highlight Function guifg=#FABD2F
highlight Statement guifg=#FB4934
highlight Type guifg=#83A598
highlight PreProc guifg=#D3869B
highlight Number guifg=#D79921
highlight Special guifg=#A89984
highlight Todo guifg=#32302F guibg=#FABD2F gui=bold
highlight CursorLineNr guifg=#D79921
highlight StatusLine guifg=#FBF1C7 guibg=#504945
highlight VertSplit guifg=#504945 guibg=#32302F

highlight clear NonText
highlight clear SpecialKey
highlight clear Whitespace

highlight NonText guifg=#504945 guibg=NONE
highlight SpecialKey guifg=#504945 guibg=NONE
highlight Whitespace guifg=#504945 guibg=NONE
]]

-- Show whitespace
opt.list = true
opt.listchars = {
    tab = "▸·",
    space = "·",
    trail = "•",
    extends = ">",
    precedes = "<",
}

-- Mapping
vim.keymap.set('i', '<C-Space>', '<C-n>', { noremap = true, silent = true })

