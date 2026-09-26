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

-- Show whitespace
opt.list = true
opt.listchars = {
    tab = "▸·",
    space = "·",
    trail = "•",
    extends = ">",
    precedes = "<",
}
