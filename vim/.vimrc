set expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=2
set smarttab

set number
set relativenumber

set foldmethod=syntax
set foldcolumn=2
set foldlevel=1

set guifont=JetBrainsMono_Nerd_Font_Mono\ 10.5

colorscheme habamax

syntax on

" отключаю звук при ошибке или неверной клавише
set noerrorbells
set novisualbell

set mouse=a

let mapleader = " "

" комбинации клавиш
nmap <leader>w :w!<cr>
nmap <leader>qq :q<cr>

map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

map <leader>ss :setlocal spell!<CR>

set et " включим автозамену по умолчанию

set wrap " попросим Vim переносить длинные строки

set ai " включим автоотступы для новых строк
set cin " включим отступы в стиле Си

" Далее настроим поиск и подсветку результатов поиска и совпадения скобок
set showmatch
set hlsearch
set incsearch
set ignorecase
set incsearch

set lz " ленивая перерисовка экрана при выполнении скриптов

set listchars=tab:»\ ,trail:·,eol:¶
set list

" Порядок применения кодировок и формата файлов

set ffs=unix,dos,mac
set fencs=utf-8,cp1251,koi8-r,ucs-2,cp866

" Пытаемся занять максимально большое пространство на экране. Как водится, по-разному на разных системах:
if has('gui')
if has('win32')
au GUIEnter * call libcallnr('maximize', 'Maximize', 1)
elseif has('gui_gtk2')
au GUIEnter * :set lines=99999 columns=99999
endif
endif

" Опять же, системы сборки для разных платформ могут быть переопределены:
if has('win32')
set makeprg=nmake
compiler msvc
else
set makeprg=make
compiler gcc
endif

set paste " При копипасте корректно проставляются все отступы
" set pastetoggle=

set statusline=%t\ %y%m%r[%{&fileencoding}]%<[%{strftime(\"%d.%m.%y\",getftime(expand(\"%:p\")))}]%k%=%-14.(%l,%c%V%)\ %P
set laststatus=2 " always show the status line

set backspace=indent,eol,start

set wildmenu

set clipboard+=unnamed
