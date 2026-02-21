" === Performance tweaks ===
set lazyredraw               " Do not redraw while executing macros
set ttyfast                  " Faster redrawing
set nocursorline             " Disable cursorline (heavy in terminals)
set norelativenumber         " Disable relative numbers (heavy in terminals)
set synmaxcol=300            " Stop syntax highlighting after 300 columns
set updatetime=1000          " Reduce swap update frequency
set shortmess+=c             " Avoid extra completion messages

" === Appearance ===
set number                   " Show absolute line numbers
set nowrap                   " Do not wrap long lines
set background=dark

" === Interface & UI ===
set showcmd
set ruler
set wildmenu
set mouse=a

" === Clipboard ===
set clipboard=unnamedplus
vnoremap y "+y"*y
vnoremap Y "+y"*y

" === Search ===
set ignorecase
set smartcase
set hlsearch
set incsearch

" === Indentation & Tabs ===
set tabstop=4
set shiftwidth=4
set expandtab
set autoindent
set smartindent
set backspace=indent,eol,start

" === Encoding ===
set encoding=utf-8

" === Sound ===
set noerrorbells

" === Syntax & Colors (Gruvbox) ===
set termguicolors
set background=dark

highlight clear
syntax reset
syntax enable

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

set list
set listchars=tab:▸·,space:·,trail:•,extends:>,precedes:<
