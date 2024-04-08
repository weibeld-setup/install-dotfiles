" .vimrc
"
" Main .vimrc file.
" Notes:
" - This and all sourced files are compatible with both Vim and Neovim
"------------------------------------------------------------------------------"

source ~/.vimrc.core  " TODO: rename to .vimrc.compat
source ~/.vimrc.plugins
source ~/.vimrc.lib

"=============================================================================="
"++Settings
" => More in ~/.vimrc.core
"=============================================================================="

set number
set expandtab
set linebreak
set nofoldenable
set noswapfile
" Allow opening another buffer without saving current buffer
set hidden
" Shell-like completion in wildmenu (complete to longest common match)
set wildmode=longest:full,full
" Disable all auto-formatting of text (see :help fo-table)
set formatoptions=
" Use Bash instead of sh for default shell syntax (see :h ft-sh-syntax)
let g:is_bash=1
" Do not move cursor one position back when exiting insert mode
" autocmd InsertEnter * let CursorColumnI = col('.')
" autocmd CursorMovedI * let CursorColumnI = col('.')
" autocmd InsertLeave * if col('.') != CursorColumnI | call cursor(0, col('.')+1) | endif
" Vim (most of these settings are default in Neovim
if !has('nvim')
  " Disable vi-compatibility mode (also default in Vim, except when -u is used)
  set nocompatible
  " Display number and index of search results
  set shortmess-=S
  " Enable popup menu for command completion
  set wildmenu
  if v:version >= 900
    set wildoptions=tagfile,pum
  else
    set wildoptions=tagfile
  endif
  " Enable the Backspace key in insert mode
  set backspace=indent,eol,start
  " Always display the status line
  set laststatus=2
  " Align with default non-printable character set of Neovim
  set listchars=tab:>\ ,trail:-,nbsp:+
  " Disable strict Ex mode (use gQ instead, Neovim has only gQ)
  nnoremap Q <Nop>
" Neovim
else
  " Use ~/.vim as main config directory (this is the default in Vim)
  set runtimepath+=~/.vim
  " Disable displaying of normal mode command below status line
  set noshowcmd
endif 

"=============================================================================="
"++Mappings
" => More in .vimrc.core
"=============================================================================="

" Leader key
let mapleader = "\<Space>"
" Leader key mappings
nnoremap <leader>G :set spell!<CR>
nnoremap <leader>f :echo @%<CR>
nnoremap <leader>F :echo expand('%:p')<CR>
nnoremap <leader>i :echo 'B=' . bufnr() . ', W=' . winnr() . ', T=' . tabpagenr()<CR>
nnoremap <leader>v :source ~/.vimrc<CR>
nnoremap <leader>V :edit ~/.vimrc<CR>
nnoremap <leader>r :redir 
nnoremap <leader>R :redir END<CR>
" Special characters
nnoremap <leader>> i→<ESC>
nnoremap <leader>< i←<ESC>
nnoremap <leader>o i⌥<ESC>
nnoremap <leader>c i⌘<ESC>
" Prevent mistyping  :q as q: (command-line window -> :h cmdwin)
nnoremap q: <Nop>
nnoremap q/ <Nop>
nnoremap q? <Nop>
nnoremap C: q:
nnoremap C/ q/
nnoremap C? q?
" Entering Ex mode
nnoremap X gQ
" Allow inserting new lines from normal mode
"nnoremap <CR> o<Esc>
"nnoremap <BS> i<BS><Esc>l
" Omni-completion trigger (https://vim.fandom.com/wiki/Omni_completion)
inoremap <C-n> <C-X><C-O>
inoremap <C-e> <C-X><C-F>
" Yank to system clipboard
vnoremap Y "*y

"=============================================================================="
"++File types
"=============================================================================="

autocmd BufNewFile,BufRead .bashrc* set filetype=sh
autocmd BufNewFile,BufRead .vimrc* set filetype=vim

"=============================================================================="
"++Buffers
" => More in ~/.vimrc.core
"=============================================================================="
" Notes:
" - A tab contains one or more windows
" - A window displays exactly one buffer
" - A buffer can be displayed in any number of windows (including zero)
" - Tabs are enumerated consecutively starting at 1 (tab number)
"   - The tab number of a tab may change: for example, if there are three tabs
"     numbered T1, T2, and T3, and T2 is deleted, then T3 becomes T2
" - Windows of a tab are enumerated consecutively starting at 1 (win number)
"   - The window number of a window may change: for example, if there are three
"     windows numbered W1, W2, and W3, and W2 is deleted, then W3 becomes W2
" - Buffers have global immutable IDs that are the same across all tabs and
"   windows and never change
" References:
"   [1] :h window
"   [2] :h tab-pages
" From ':h window':
"   A buffer is the in-memory text of a file.
"   A window is a viewport on a buffer.
"   A tab page is a collection of windows.

" TODO: create some mappings for opening new buffers (e.g. new empty buffer,
" new empty buffer in split window, etc.).

nnoremap <leader>b :call OpenBuffer(input('BUF: ', '', 'buffer'))<CR>
nnoremap <leader>B :call DeleteBuffers(input('DELETE BUF: '))<CR>

" Toggle previously open buffer
"nnoremap <C-w>b :b#<CR>
nnoremap <leader>e :b#<CR>

"=============================================================================="
"++Windows
" => More in ~/.vimrc.core
"=============================================================================="

" Switch to or close a specific window by number. Abort with Ctrl-C.
" Vim compat: only :[count]wincmd {arg}, not :wincmd [count] {arg}
nnoremap <leader>a :<C-u>execute input('Switch to window: ')..'wincmd w'<CR>
" TODO: prevent closing of current window when typing <Esc> in prompt
nnoremap <leader>A :<C-u>execute 'close '..input('Close window: ')<CR>

" TODO: create mapping for toggling maximising a window, i.e. hide all other
" windows when pressing the mapping again, the previous state is restored,
" similar to 'resize-pane -Z' in tmux (<C-a>m).

" Go to the window with a specific window number (local to tab)
" nnoremap <C-w>1 :1wincmd w<CR>
" nnoremap <C-w>2 :2wincmd w<CR>
" nnoremap <C-w>3 :3wincmd w<CR>
" nnoremap <C-w>4 :4wincmd w<CR>
" nnoremap <C-w>5 :5wincmd w<CR>
" nnoremap <C-w>6 :6wincmd w<CR>
" nnoremap <C-w>7 :7wincmd w<CR>
" nnoremap <C-w>8 :8wincmd w<CR>
" nnoremap <C-w>9 :9wincmd w<CR>

" Disable moving of windows and reuse mappings for resizing windows
nnoremap <C-w>H <Nop>
nnoremap <C-w>J <Nop>
nnoremap <C-w>K <Nop>
nnoremap <C-w>L <Nop>

" Increase/decrease horizontal size of current window
call submode#enter_with('resize-win', 'n', '', '<C-w>H', '10<C-w>>')
call submode#map('resize-win', 'n', '', 'H', '10<C-w>>')
call submode#enter_with('resize-win', 'n', '', '<C-w>L', '10<C-w><')
call submode#map('resize-win', 'n', '', 'L', '10<C-w><')

" Increase/decrease vertical size of current window
call submode#enter_with('resize-win', 'n', '', '<C-w>K', '5<C-w>+')
call submode#map('resize-win', 'n', '', 'K', '5<C-w>+')
call submode#enter_with('resize-win', 'n', '', '<C-w>J', '5<C-w>-')
call submode#map('resize-win', 'n', '', 'J', '5<C-w>-')

"=============================================================================="
"++Tabs
"=============================================================================="

" Create a new tab at the end of the tabline
nnoremap <C-w>t :$tabnew<CR>

" Go to next and previous tab (wraps at last and first tab)
call submode#enter_with('switch-tab', 'n', '', '<C-w>n', 'gt')
call submode#map('switch-tab', 'n', '', 'n', 'gt')
call submode#map('switch-tab', 'n', '', '<C-w>n', 'gt')
call submode#enter_with('switch-tab', 'n', '', '<C-w>p', 'gT')
call submode#map('switch-tab', 'n', '', 'p', 'gT')
call submode#map('switch-tab', 'n', '', '<C-w>p', 'gT')

" Switch to or close a specific tab by number. Abort with Ctrl-C.
nnoremap <leader>t :<C-u>execute 'tabnext '..input('Switch to tab: ')<CR>
" TODO: prevent closing of current tab when pressing <Esc> in prompt
nnoremap <leader>T :<C-u>execute 'tabclose '..input('Close tab: ')<CR>

" Toggle to the last active tab (overwrites <C-w>o, see ':h CTRL-W_O')
nnoremap <C-w>o g<Tab>

" Go to the tab with a specific tab number
" nnoremap <Leader>1 1gt
" nnoremap <Leader>2 2gt
" nnoremap <Leader>3 3gt
" nnoremap <Leader>4 4gt
" nnoremap <Leader>5 5gt
" nnoremap <Leader>6 6gt
" nnoremap <Leader>7 7gt
" nnoremap <Leader>8 8gt
" nnoremap <Leader>9 9gt

" Move current tab one position to the right or left (does not wrap)
call submode#enter_with('move-tab', 'n', '', '<C-w>N', ':+tabmove<CR>')
call submode#map('move-tab', 'n', '', 'N', ':+tabmove<CR>')
call submode#map('move-tab', 'n', '', '<C-w>N', ':+tabmove<CR>')
call submode#enter_with('move-tab', 'n', '', '<C-w>P', ':-tabmove<CR>')
call submode#map('move-tab', 'n', '', 'P', ':-tabmove<CR>')
call submode#map('move-tab', 'n', '', '<C-w>P', ':-tabmove<CR>')

"=============================================================================="
"++Terminal mode
"=============================================================================="

" Open a terminal in a horizontal split window
nnoremap <leader>x :terminal<CR>

" Make Neovim terminal mode behave like Vim defaults
if has('nvim')
  " Open a terminal in a horizontal split window instead of in same window
  nnoremap <leader>x :split \| :terminal<CR>
  " Enter insert mode after opening terminal
  autocmd TermOpen * startinsert
  " Remove line numbers in insert mode and restore them when exiting
  autocmd TermEnter * setlocal nonumber
  autocmd TermLeave * setlocal number
  " Delete the terminal buffer when exiting the shell
  autocmd TermClose * :execute 'bdelete! '..expand('<abuf>')
else
endif

" Leave terminal mode (use 'i' for entering terminal mode)
" TODO: in Vim, there's a delay after pressing Esc
tnoremap <Esc> <C-\><C-n>

" Enable switching windows from terminal mode (exits terminal mode)
tnoremap <C-w>h <C-\><C-N><C-w>h
tnoremap <C-w>j <C-\><C-N><C-w>j
tnoremap <C-w>k <C-\><C-N><C-w>k
tnoremap <C-w>l <C-\><C-N><C-w>l

"=============================================================================="
"++UI elements
"=============================================================================="

" Status line
set statusline=%!MyStatusLine()
highlight StatusLine ctermbg=green ctermfg=black cterm=bold
highlight StatusLineNC ctermbg=65 ctermfg=black cterm=bold
" Vim has separate highlight groups for terminal mode
if !has('nvim')
  highlight StatusLineTerm ctermbg=green ctermfg=black cterm=bold
  highlight StatusLineTermNC ctermbg=65 ctermfg=black cterm=bold
endif

" Tab line
set showtabline=2
set tabline=%!MyTabLine()
highlight TabLine ctermbg=240 ctermfg=white cterm=bold
highlight TabLineSel ctermbg=blue ctermfg=white cterm=bold
highlight TabLineFill ctermbg=black cterm=bold
" Custom highlight groups
highlight TabLineBuf ctermbg=black ctermfg=white cterm=bold
highlight TabLineBufCurrent ctermbg=lightyellow ctermfg=black cterm=bold
highlight TabLineWinCurrent ctermbg=lightyellow ctermfg=black cterm=bold

" Cursor line
set cursorline
highlight LineNr ctermfg=yellow cterm=None
highlight CursorLine ctermbg=239 cterm=None
highlight CursorLineNr ctermbg=yellow ctermfg=black cterm=bold 

" Colour column
set colorcolumn=80
highlight ColorColumn ctermbg=235

" Visual mode
highlight Visual ctermbg=lightblue ctermfg=black cterm=none

" Search highlighing
highlight Search ctermbg=5 ctermfg=black

" Vertical split bar
set fillchars+=vert:\ 
highlight VertSplit ctermbg=254 cterm=none

" Auto-completion popup menu (wildmenu)
highlight Pmenu ctermfg=white ctermbg=blue
highlight PmenuSel ctermbg=5 ctermfg=black cterm=bold
highlight PmenuThumb ctermbg=darkblue
highlight PmenuSbar ctermbg=grey

" Custom status line.
" Notes:
"   - See ':h statusline'
" CAUTION:
"   Window-specific values (e.g. window number) must not be saved in a local
"   variable because they get overwritten by different function calls.
function! MyStatusLine()
  return '[%{winnr()}] %{MakeBufferMainIndicator(bufnr(), " ")}%< %{MakeBufferFileTypeIndicator(bufnr(), "", " ", 1)}%f %R %= [C=%c] [L=%l]#%L [%p%%] '
endfunction

" Custom tab line.
" Notes:
"   - See ':h setting-tabline'
" CAUTION:
"   Function body must not contain empty lines because of bug [2]. Fix has been
"   implemented and will probably be released in Neovim v0.10.
" Resources:
"   [1] https://github.com/mkitt/tabline.vim
"   [2] https://github.com/neovim/neovim/issues/24122
function! MyTabLine()
  let tabline = ''
  " Buffer list at beginning of tab line (only listed buffers)
  let buf_nr_listed = map(ListListedBuffers(), {_, buf -> buf.nr})
  let tabline ..= '%#TabLineBuf#[BUF] Σ:'..len(buf_nr_listed)..' '
  for buf_nr in buf_nr_listed
    let tabline ..= (buf_nr == bufnr() ? '%#TabLineBufCurrent#' : '')
    let tabline ..= MakeBufferMainIndicator(buf_nr)..' '
    let tabline ..= (buf_nr == bufnr() ? '%#TabLineBuf#' : '')
  endfor
  let tabline ..= '%#TabLineFill# '
  " Tab list (each one showing displayed buffers, including unlisted ones)
  for tab_nr in range(1, tabpagenr('$'))
    let is_current_tab = (tab_nr == tabpagenr())
    let bufs_tab = tabpagebuflist(tab_nr)
    let tab_highlight = is_current_tab ? '%#TabLineSel#' : '%#TabLine#'
    let tabline ..= tab_highlight..'['..tab_nr..'] Σ:'..len(bufs_tab)..' '
    for i in range(len(bufs_tab))
      let is_current_win = (i+1 == winnr())
      let tabline ..= (is_current_win && is_current_tab) ? '%#TabLineWinCurrent#' : ''
      let tabline ..= MakeBufferMainIndicator(bufs_tab[i])..' '
      let tabline ..= (is_current_win && is_current_tab) ? tab_highlight : ''
    endfor
    " One-column gap between tabs
    let tabline ..= '%#TabLineFill# '
  endfor
  return tabline
endfunction

"=============================================================================="
"++User functions
"=============================================================================="

" Convert Markdown top-level list items to second-level sections
function! MarkdownListToSections()
  %s/^- /## /
  %s/^  //
  g/^## /normal! O
  g/^## /normal! o
endfunction
