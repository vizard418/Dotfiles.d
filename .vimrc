" === Appearance ===

set cursorline                  " Highlight the current line
set numberwidth=4               " Set width of line number column
set number                      " Show Absolute line numbers
set relativenumber              " Show relative line numbers
set nowrap                      " Do not wrap long lines
set background=dark             " Use colors optimized for dark background

" === Interface & UI ===
set showcmd                     " Show incomplete commands in the last line
set ruler                       " Show line and column number in the status line
set wildmenu                    " Enhanced command-line completion
set mouse=a                     " Enable mouse support in all modes

" === Clipboard ===
set clipboard=unnamedplus       " Use system clipboard for copy/paste

" === Search ===
set ignorecase                  " Ignore case in searches
set smartcase                   " Override ignorecase if search contains uppercase
set hlsearch                    " Highlight search results
set incsearch                   " Show matches as you type

" === Indentation & Tabs ===
set tabstop=4                   " Number of spaces that a <Tab> counts for
set shiftwidth=4                " Number of spaces to use for (auto)indent
set expandtab                   " Use spaces instead of tabs
set autoindent                  " Copy indent from current line when starting a new one
set smartindent                 " Smart autoindenting for new lines
set backspace=indent,eol,start  " Make the backspace key work as expected in insert mode

" === Encoding ===
set encoding=utf-8              " Use UTF-8 for internal encoding

" === Sound ===
set noerrorbells                " Disable error beep sounds

" === Appearance & highlights (only if syntax is supported) ===
if has("syntax")
    syntax enable                   " Enable syntax highlighting

    " Only apply termguicolors if supported
    if has("termguicolors")
        set termguicolors
    endif

    " Gruvbox Custom Highlight (Vibrant)
    if exists(":highlight")
        highlight clear
        syntax reset
        set background=dark

        " General UI
        highlight Normal guifg=#FBF1C7
        highlight Normal guibg=#32302F
        highlight Cursor guifg=#32302F
        highlight Cursor guibg=#D65D0E
        highlight CursorLine cterm=NONE
        highlight CursorLine term=NONE
        highlight CursorLine gui=NONE
        highlight CursorLine guibg=#504945
        highlight LineNr guifg=#A89984
        highlight LineNr guibg=#32302F
        highlight Comment guifg=#928374
        highlight Comment gui=italic
        highlight Visual guibg=#504945
        highlight Pmenu guifg=#FBF1C7
        highlight Pmenu guibg=#504945
        highlight PmenuSel guifg=#32302F
        highlight PmenuSel guibg=#D65D0E
        highlight MatchParen guifg=#FB4934
        highlight MatchParen guibg=#504945
        highlight MatchParen gui=bold
        highlight Search guifg=#32302F
        highlight Search guibg=#FABD2F
        highlight Search gui=bold

        " Syntax
        highlight Constant guifg=#FE8019
        highlight String guifg=#B8BB26
        highlight Identifier guifg=#8EC07C
        highlight Function guifg=#FABD2F
        highlight Statement guifg=#FB4934
        highlight Type guifg=#83A598
        highlight PreProc guifg=#D3869B
        highlight Number guifg=#D79921
        highlight Special guifg=#A89984
        highlight SpecialKey ctermfg=240
        highlight SpecialKey guifg=#666666
        highlight Todo guifg=#32302F
        highlight Todo guibg=#FABD2F
        highlight Todo gui=bold

        " UI tweaks
        highlight CursorLineNr guifg=#D79921
        highlight StatusLine guifg=#FBF1C7
        highlight StatusLine guibg=#504945
        highlight VertSplit guifg=#504945
        highlight VertSplit guibg=#32302F
    endif

    " Show whitespace characters (optional, only in full Vim)
    set list
    set listchars=tab:▸·,space:·,trail:•,extends:>,precedes:<
endif
