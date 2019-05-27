"~/.vimrc
"
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

" Save file automatically when using :make
set autowrite

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

"=============================================================================="
" Leader key and mappings
"=============================================================================="

let mapleader = "\<Space>"

nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>r :source $MYVIMRC<CR>
nnoremap <leader>e :e 

" Toggle display of line numbers
nnoremap <leader>i :set number!<CR>

" Search/substitute word under cursor (Ctrl-R Ctrl-W inserts word under cursor
" in command-line mode, see :h c_CTRL-R_CTRL-W)
nnoremap <leader>s /<C-r><C-w><CR>
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
nnoremap <leader>c :call g:ToggleColorColumn()<CR>
function! g:ToggleColorColumn()
  if &colorcolumn == ''
    setlocal colorcolumn=81
  else
    setlocal colorcolumn&
  endif
endfunction
set colorcolumn=81

" Toggle spell checking
nnoremap <leader>x :set spell!<CR>

" Change current line to title case
nnoremap <leader>t :s/\<\(\w\)\(\w*\)\>/\u\1\L\2/g<CR>:nohlsearch<CR>

"=============================================================================="
" Buffers and split windows
"=============================================================================="

nnoremap <C-n> :bnext<CR>
nnoremap <C-p> :bprevious<CR>
nnoremap <C-d> :bd<CR>
nnoremap <leader>bo :BufOnly<CR>
"nnoremap <C-b> :enew<CR>
"nnoremap <leader><leader> <C-^>

set splitbelow
set splitright

nnoremap <silent> <leader>h :call WinMove('h')<CR>
nnoremap <silent> <leader>j :call WinMove('j')<CR>
nnoremap <silent> <leader>k :call WinMove('k')<CR>
nnoremap <silent> <leader>l :call WinMove('l')<CR>
nnoremap          <leader>o <C-w>q
nnoremap          <Tab> <C-w>w

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


" Remamp macro key from q to m
"nnoremap m q
"nnoremap q <Nop>

" Toggle netrw file explorer. See browsing commands on 'h: netrw-quickhelp'
" <CR> = open file, R = rename file, D = delete file, - = root up, gn = root
" down (to directory under cursor)
let g:netrw_banner=0
let g:netrw_winsize=30
let g:netrw_liststyle=3
let g:netrw_localrmdir='rm -r'
let g:netrw_maxfilenamelen=64
nnoremap E :call MyLexplore()<CR>
function! MyLexplore()
  " Make sure files are opened in the last active window (default is window 2).
  " You can also set this ad-hoc with ':NetrwC <n>' or '<n>C'.
  let g:netrw_chgwin = winnr() + 1
  :Lexplore
endfunction

" Submode for resizing windows. Requires plugin https://github.com/kana/vim-submode
" Enlarge width of current window
call submode#enter_with('resize-window', 'n', '', '<C-w>L', '5<C-w>>')
call submode#map('resize-window', 'n', '', 'L', '5<C-w>>')
" Reduce width of current window
call submode#enter_with('resize-window', 'n', '', '<C-w>H', '5<C-w><')
call submode#map('resize-window', 'n', '', 'H', '5<C-w><')
" Enlarge height of current window
call submode#enter_with('resize-window', 'n', '', '<C-w>K', '5<C-w>+')
call submode#map('resize-window', 'n', '', 'K', '5<C-w>+')
" Reduce height of current window
call submode#enter_with('resize-window', 'n', '', '<C-w>J', '5<C-w>-')
call submode#map('resize-window', 'n', '', 'J', '5<C-w>-')
let g:submode_timeout = 0
let g:submode_keep_leaving_key = 1


" Set spelling language(s)
set spelllang=en

" Remap 'join lines', which is J by default
nnoremap Z :join<CR>


" Do not move cursor one position back when exiting insert mode
" autocmd InsertEnter * let CursorColumnI = col('.')
" autocmd CursorMovedI * let CursorColumnI = col('.')
" autocmd InsertLeave * if col('.') != CursorColumnI | call cursor(0, col('.')+1) | endif

" Use Enter to insert an empty line below
nnoremap <CR> o<Esc>

" O (big-O) to open a line two lines below
nnoremap O o<CR>

" Change the cursor to a block in normal mode and bar in insert mode
" (problem: changes cursor of terminal which remains after quitting vim)
" let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
" let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"

" Use Back to delete the character to the left of the cursor
nnoremap <BS> i<BS><Esc>l


" Use specific color scheme if it exists (default, if it doesn't exist)
silent! colorscheme slate


" Define formatting of invisible characters
"set listchars=tab:>-,trail:.,eol:¬


set cursorline
hi CursorLine cterm=NONE ctermbg=DarkGray  " For some reason does not work


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

" Open the .vimrc file in a separate tab for editing
nnoremap <leader>v :tabedit $MYVIMRC<CR>

" Disable certain modules of the vim-pandoc plugin
let g:pandoc#modules#disabled = [ "spell", "folding" ]

" Disable "conceal" for the vim-pandoc-syntax plugin
let g:pandoc#syntax#conceal#use = 0


" WildMenu: color of the selected item in the wildemnu (filename completion bar). The
" color of the bar itself is equals to StatusLine.
hi WildMenu ctermbg=white ctermfg=black cterm=bold

" TabLine: TabLineSel = selected, TabLine = unselected, TabLineFill = rest
hi TabLineSel ctermbg=darkgreen ctermfg=white cterm=bold
hi TabLine ctermbg=darkgray ctermfg=white cterm=none
hi TabLineFill ctermfg=black
" Color of tab number (preceding tab label)
hi TabLineSelNumber ctermbg=darkgreen ctermfg=yellow cterm=bold
hi TabLineNumber ctermbg=darkgray ctermfg=yellow cterm=bold

" Set custom tab line
"set tabline=%!MyTabLine()
"
"" Return string representing custom tab line (same principle as status line)
"function! MyTabLine()
"  let s = ''
"  "Add substring consisting of ' <tab number> <tab label> ' for each tab
"  for i in range(1, tabpagenr('$'))
"    if i == tabpagenr()
"      let numberHi = '%#TabLineSelNumber#'
"      let labelHi = '%#TabLineSel#'
"    else
"      let numberHi = '%#TabLineNumber#'
"      let labelHi = '%#TabLine#'
"    endif
"    let s .= numberHi . ' ' . i . ' ' . labelHi . '%{MyTabLabel(' . i . ')} '
"  endfor
"  " After all tabs, change color to TabLineFill and reset tab counter
"  return s . '%#TabLineFill#%T'
"endfunction
"
"" Return label for a specific tab number. The label consists of the filename
"" of the file in the current window in this tab.
"function! MyTabLabel(n)
"  " Get currently open buffers in this tab
"  let buflist = tabpagebuflist(a:n)
"  " Get buffer of current window in this tab
"  let bufcurrent = buflist[tabpagewinnr(a:n) - 1]
"  " Get filename of buffer
"  let fname = fnamemodify(bufname(bufcurrent), ":t")
"  if (fname == "")
"    return '[No Name]'
"  else
"    return fname
"endfunction

" Custom commands

" Jekyll
"command! L e _layouts
"command! I e _includes
"command! S e _sass
"command! P e _pages
"command! C e _config.yml
"command! A e assets

" Do Not Change The Working Directory When Opening A File
set noautochdir

" nnoremap <leader>t :s/\<\(\w\)\(\S*\)/\u\1\L\2/g<CR>

" vim-go plugin
autocmd FileType go nmap gb <Plug>(go-build)
autocmd FileType go nmap gr <Plug>(go-run)
autocmd FileType go nmap gi <Plug>(go-info)
autocmd FileType go nmap gd <Plug>(go-doc)
autocmd FileType go nmap gdd <Plug>(go-doc-browser)
"autocmd FileType go nmap :gi :GoImport<Space>
autocmd BufWritePost *.go :GoBuild 

" Disable 'K' for open docs (https://github.com/fatih/vim-go/issues/140)
let g:go_doc_keywordprg_enabled = 0

" Fix filetype for Bash files
autocmd BufNewFile,BufRead .bashrc :set filetype=sh

" vim-terraform plugin
let g:terraform_align=1
let g:terraform_fold_sections=1
let g:terraform_remap_spacebar=1
let g:terraform_commentstring='//%s'
let g:terraform_fmt_on_save=1

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

set runtimepath+=~/Desktop/hello-plugin/

