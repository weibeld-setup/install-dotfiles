"~/.vimrc"
" Note: split lines with \ at the beginning of the new line.
"
" Daniel Weibel <daniel.weibel@unifr.ch> May 2015
"------------------------------------------------------------------------------"

execute pathogen#infect()
" Extend surround plugin with LaTeX command (usage example: ysiwc textbf)
let g:surround_{char2nr('c')} = "\\\1command\1{\r}"

" Prevent parenthesis matching plugin from being loaded
let loaded_matchparen=1

" Use line numbers
set number

" Highlicht first matches of search while typing pattern
set incsearch

" Highlight search matches (but prevent highlighting matches from last search
" when this file is sourced).
set hlsearch
nohlsearch

" Show number of search results and index of current result
set shortmess-=S

" Save file automatically when using :make
set autowrite

" Disable code folding
set nofoldenable

" Navigate in steps of multiple lines/columns
nnoremap <C-h> 5h
nnoremap <C-l> 5l
nnoremap <C-j> 5j
nnoremap <C-k> 5k

vnoremap <C-h> 5h
vnoremap <C-l> 5l
vnoremap <C-j> 5j
vnoremap <C-k> 5k

nnoremap H 20h
nnoremap L 20l
nnoremap J 10j
nnoremap K 10k

nnoremap H 20h
vnoremap L 20l
vnoremap J 10j
vnoremap K 10k

" Scroll single line up and down (use Ctrl-F and Ctrl-B to scroll by half pages)
nnoremap <C-u> <C-y>
nnoremap <C-d> <C-e>

nnoremap m @

"=============================================================================="
" Leader key and mappings
"=============================================================================="

let mapleader = "\<Space>"

nnoremap <leader>w :w<CR>
nnoremap <leader>q :x<CR>
"nnoremap <leader>q :q<CR>
nnoremap <leader>Q :qa<CR>
nnoremap <leader>r :source $MYVIMRC<CR>
nnoremap <leader>v :e $MYVIMRC<CR>
nnoremap <leader>e :e 
"nnoremap <leader>t :terminal<CR>

" Toggle display of line numbers
nnoremap <leader>n :set number!<CR>

" Search/substitute word under cursor 

"nnoremap <leader>s /<C-r><C-w><CR>

" Highlight occurrences of word under cursor and show number of matches. (Ctrl-R
" Ctrl-W inserts word under cursor in command-line mode, see :h c_CTRL-R_CTRL-W)
nnoremap <leader>s :%s/<C-r><C-w>//gn<CR><C-o>

" Substitute all occurrences of word under cursor (unfortunately jumps to the
" next occurrenc of cursor word when 'incsearch' is on).
nnoremap <leader>S :%s/\<<C-r><C-w>\>//g<left><left>

" Clear highlighted search matches
nnoremap <leader>, :nohlsearch<CR>

" Toggle invisible characters
nnoremap <leader>. :set list!<CR>

" Move line up and down in normal mode
"nnoremap <leader>k :m-2<CR>==
"nnoremap <leader>j :m+<CR>==

" Move selected lines up and down in visual mode
"xnoremap <leader>k :m-2<CR>gv=gv
"xnoremap <leader>j :m'>+<CR>gv=gv

" Toggle colour column
"nnoremap <leader>c :call g:ToggleColorColumn()<CR>
function! g:ToggleColorColumn()
  if &colorcolumn == ''
    setlocal colorcolumn=80,100
  else
    setlocal colorcolumn&
  endif
endfunction
set colorcolumn=80,100


" Change current line to title case
nnoremap <leader>T :s/\<\(\w\)\(\w*\)\>/\u\1\L\2/g<CR>:nohlsearch<CR>          

"=============================================================================="
" Buffers
"=============================================================================="

nnoremap <C-n> :bnext<CR>
nnoremap <C-p> :bprevious<CR>
"nnoremap <C-w> <C-^>
nnoremap <leader>b :buffer 
nnoremap <leader>d :bd<CR>
nnoremap <leader>bo :BufOnly<CR>
nnoremap <leader>B :buffers<CR>
"nnoremap <leader><Tab> <C-^> 
"nnoremap <C-b> :enew<CR>

"=============================================================================="
" Split windows
"=============================================================================="

set splitbelow
set splitright

nnoremap <silent> <leader>h :call WinMove('h')<CR>
nnoremap <silent> <leader>j :call WinMove('j')<CR>
nnoremap <silent> <leader>k :call WinMove('k')<CR>
nnoremap <silent> <leader>l :call WinMove('l')<CR>
"nnoremap          <leader>d <C-w>q
nnoremap          <Tab>     <C-w>w

" Move to adjacent window on the  left/bottom/top/right, or create new one if
" at edge. New window starts with current buffer to prevent empty buffers.
function! WinMove(key)
  let t:curwin = winnr()
  exec "wincmd ".a:key
  " If still in same window (i.e. we're at the edge), create a new window
  if (t:curwin == winnr())
    if (a:key == "h")
      wincmd v
      wincmd h
    elseif (a:key == "j")
      wincmd s
    elseif (a:key == "k")
      wincmd s
      wincmd k
    elseif (a:key == "l")
      wincmd v
    endif
  endif    
endfunction

" Resize split windows, requires https://github.com/kana/vim-submode
" Increase width and height of current window
call submode#enter_with('resize-window', 'n', '', '<leader>H', '5<C-w>>')
call submode#map('resize-window', 'n', '', 'H', '5<C-w>>')
call submode#enter_with('resize-window', 'n', '', '<leader>J', '5<C-w>+')
call submode#map('resize-window', 'n', '', 'J', '5<C-w>+')
" Decrease width and height of current window
call submode#enter_with('resize-window', 'n', '', '<leader>L', '5<C-w><')
call submode#map('resize-window', 'n', '', 'L', '5<C-w><')
call submode#enter_with('resize-window', 'n', '', '<leader>K', '5<C-w>-')
call submode#map('resize-window', 'n', '', 'K', '5<C-w>-')
let g:submode_timeout = 0
let g:submode_keep_leaving_key = 1

"=============================================================================="
" Netrw
"=============================================================================="

" See browsing commands on 'h: netrw-quickhelp': <CR> = open, R = rename,
" D = delete file, - = root up, gn = root down (to directory under cursor)
let g:netrw_banner=0
let g:netrw_winsize=20
let g:netrw_liststyle=3
let g:netrw_localrmdir='rm -r'
let g:netrw_maxfilenamelen=64
nnoremap <leader>E :call MyLexplore()<CR>
function! MyLexplore()
  " Make sure files are opened in the last active window (default is window 2).
  " You can also set this ad-hoc with ':NetrwC <n>' or '<n>C'.
  let g:netrw_chgwin = winnr() + 1
  :Lexplore
endfunction

" Set spelling language(s)
set spelllang=en

" Do not move cursor one position back when exiting insert mode
" autocmd InsertEnter * let CursorColumnI = col('.')
" autocmd CursorMovedI * let CursorColumnI = col('.')
" autocmd InsertLeave * if col('.') != CursorColumnI | call cursor(0, col('.')+1) | endif

autocmd VimEnter * set expandtab

" Use Enter to insert an empty line below
nnoremap <CR> o<Esc>

" O (big-O) to open a line two lines below
nnoremap O o<CR>

" Use Back to delete the character to the left of the cursor
nnoremap <BS> i<BS><Esc>l


" Use specific color scheme if it exists (default, if it doesn't exist)
silent! colorscheme slate


" Define formatting of invisible characters
"set listchars=tab:>-,trail:.,eol:¬


set cursorline
" hi CursorLine cterm=NONE ctermbg=DarkGray  " For some reason does not work


" Minimum number of lines below or above the cursor when scrolling
set scrolloff=5

" Wrap lines at window border *between words*
set linebreak 

" Alternative for ':' for entering command line
"nnoremap - :

" Number of Ex commands (:) recorded in the history (default is 20)
set history=200

" Moving up and down in soft-wrapped lines
nnoremap j gj
nnoremap k gk

" Little one-line horizontal menu for completion suggestions
set wildmenu
" Complete to longest common substring and show alternatives in wildmenu
set wildmode=longest:full,full

" Disable arrow keys
map <up>    <nop>
map <down>  <nop>
map <left>  <nop>
map <right> <nop>

" Window operations with Ctrl-A (like in tmux)
"nnoremap <C-a> <C-w>

" Cycling between tabs as in tmux
"nnoremap <C-a>n gt
"nnoremap <C-a>p gT

" Closing a tab
"nnoremap tc     :tabclose<CR>

" Select pasted text
nnoremap gp `[v`]

" Disabling all format options (e.g. no automatic insertion of comment char)
set formatoptions=c

" If a new file is opened, hide existing buffer instead of closing it
set hidden

" Tab and indenting setup
set tabstop=2     " Tab width
set shiftwidth=2  " Indent width of '>>' or '<<'
set expandtab     " Use spaces for tabs

" Enable the backspace key
set backspace=indent,eol,start

" No backup files (.swp)
set nobackup
set noswapfile

" Alternatives for Esc in insert mode
inoremap <C-k> <Esc>

" Enable detection of file type for file-type specific plugins
filetype plugin on

" Enable syntax highlighting
syntax on

" Enable Bash variant of sh syntax highlighting mode (sh.vim)
let g:is_bash=1

" Event handlers
if has("autocmd")
  " Source the .vimrc file automatically when it is saved
  " autocmd bufwritepost .vimrc source $MYVIMRC
  " No colorcolumn in TeX files
  "autocmd filetype tex if v:version >= 703 set colorcolumn= endif
endif


" Disable certain modules of the vim-pandoc plugin
let g:pandoc#modules#disabled = [ "spell", "folding" ]

" Disable "conceal" for the vim-pandoc-syntax plugin
let g:pandoc#syntax#conceal#use = 0


" WildMenu: color of the selected item in the wildemnu (filename completion bar). The
" color of the bar itself is equals to StatusLine.
hi WildMenu ctermbg=white ctermfg=black cterm=bold

hi TabLine    ctermbg=black ctermfg=darkgray cterm=none
hi TabLineSel ctermbg=darkgray ctermfg=white cterm=bold
hi TabLineFill ctermfg=black

" Do Not Change The Working Directory When Opening A File
set noautochdir

" nnoremap <leader>t :s/\<\(\w\)\(\S*\)/\u\1\L\2/g<CR>

" vim-go plugin
"autocmd FileType go nmap gb <Plug>(go-build)
"autocmd FileType go nmap gr <Plug>(go-run)
"autocmd FileType go nmap gi <Plug>(go-install)
"autocmd FileType go nmap gd <Plug>(go-doc)
"autocmd FileType go nmap gdd <Plug>(go-doc-browser)
"autocmd FileType go nmap :gi :GoImport<Space>
"autocmd BufWritePost *.go :GoBuild 

" Disable 'K' for open docs (https://github.com/fatih/vim-go/issues/140)
"let g:go_doc_keywordprg_enabled = 0

" Fix filetype for Bash files
autocmd BufNewFile,BufRead .bashrc :set filetype=sh

" vim-terraform plugin
let g:terraform_align=1
"let g:terraform_fold_sections=1
"let g:terraform_remap_spacebar=1
let g:terraform_commentstring='//%s'
let g:terraform_fmt_on_save=0

"=============================================================================="
" Status line
"=============================================================================="

" Always display status line (not only in split windows)
set laststatus=2

" Left-justified: [+] (modified), file path, [RO] (read-only), [Help] (help)
" Right-justified: line, column, total lines, percent lines in file
set statusline=[%{getcwd()}]\ %F\ %m\ %r\ %h%=%l/%c\ %L\ (%p%%)
" Status line colors of active and inactive windows (see :help cterm-colors,
" for iTerm use numbers under NR-8, '*' means '+8')
hi StatusLine ctermfg=white ctermbg=darkgray cterm=bold
hi StatusLineNC ctermfg=black ctermbg=darkgray cterm=bold

"=============================================================================="
" Misc
"=============================================================================="

" Search for all top-level JavaScript functions in a file
nnoremap <leader>f /^export async function\\|^export function\\|^async function\\|^function<CR>

set runtimepath+=~/Desktop/hello-plugin/

autocmd BufNewFile,BufRead Jenkinsfile* set syntax=groovy shiftwidth=4 tabstop=4
autocmd BufNewFile,BufRead *.groovy set shiftwidth=4 tabstop=4
autocmd BufNewFile,BufRead *.tmpl set syntax=gotexttmpl

" Aliases :w for :wa and :wq for :waq
" See https://stackoverflow.com/a/3879737/4747193
cnoreabbrev wq xa

" For vim-table-mode plugin
let g:table_mode_corner='|'

" Abbreviations

ab :tick: ✅
ab :cross: ❌
ab :black: ⬛
ab :white: ⬜
ab :rightarrow: →

" Map Ctrl-<dash> to em-dash (U+2014)
inoremap  —
