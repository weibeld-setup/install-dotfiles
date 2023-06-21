" .vimrc file for Vim and Neovim
"
" This file is intended to have the same effect on Vim and Neovim and to be
" fully compatible with both. The config directory is assumed to be ~/.vim
" which is the default in Vim, but is explicitly configured for Neovim here.
"------------------------------------------------------------------------------"

"------------------------------------------------------------------------------"
" Vim and Neovim-only settings
"------------------------------------------------------------------------------"
if !has('nvim')

  " Disable vi-compatibility mode (default even in Vim, except when -u is used)
  set nocompatible

  " Enable incremental search with highlighting
  set incsearch
  set hlsearch
  nohlsearch

  " Display number and index of search results
  set shortmess-=S

  " Enable popup menu for command completion
  set wildmenu
  set wildoptions=pum,tagfile

  " Enable the Backspace key in insert mode
  set backspace=indent,eol,start

  " Always display the status line
  set laststatus=2

  " Same non-printable characters as in Neovim for ':set list'
  set listchars=tab:>\ ,trail:-,nbsp:+
else
  " Use ~/.vim as main config directory (this is the default in Vim)
  set runtimepath+=~/.vim
endif 

"------------------------------------------------------------------------------"
" Plugins (vim-plug)
"------------------------------------------------------------------------------"

" Neovim default for plugin directory is ~/.local/share/nvim/plugged
call plug#begin('~/.vim/plugged')

"------------------------------------------------------------------------------"
" vim-submode (https://github.com/kana/vim-submode)
"------------------------------------------------------------------------------"
" Create temporary custom modes with their own key mappings
" Notes:
"   - Due to a current design flaw [1], the concatenation of submode name
"     and LHS mapping must not exceed a certain limit in the submode#enter_with
"     and submode#map functions, otherwise the plugin fails. Read more in [2].
"   - It's sometimes  useful to include the enter mapping (submode#enter_with)
"     also in the submode itself (submode#map). This avoids confusion when
"     accidentially pressing the enter mapping when already in the submode. 
"     Thus, some submode mapping definitions have two submode#map commands.
" References:
"   [1] https://github.com/kana/vim-submode/issues/33
"   [2] https://github.com/kana/vim-submode/issues/33#issuecomment-1563675700
Plug 'kana/vim-submode'

"------------------------------------------------------------------------------"
" vim-table-mode (https://github.com/dhruvasagar/vim-table-mode)
"------------------------------------------------------------------------------"
" Automatically format Markdown tables
Plug 'dhruvasagar/vim-table-mode'
let g:table_mode_corner='|'

"------------------------------------------------------------------------------"
" wiki.vim (https://github.com/lervag/wiki.vim)
"------------------------------------------------------------------------------"
" Wiki functionality (alternative to vimwiki)
Plug 'lervag/wiki.vim'
" TODO: determine wiki root in a more sophisticated way with a function, e.g.
" with a flag file such as .wiki (see ':h g:wiki_root').
let g:wiki_root = '.'
" TODO: define mappings only when wiki.vim is enabled. It seems that wiki.vim
" is enabled for all the file types defined in g:wiki_filetypes (i.e. md files)
if exists("g:wiki_root")
  inoremap <C-n> <C-X><C-O>
endif
" Disable automatic link creation
let g:wiki_link_transform_on_follow = 0

let g:wiki_link_extension = '.md'
let g:wiki_link_target_type = 'md'
let g:wiki_filetypes = ['md', 'yaml']

" TODO: made obsolete by g:wiki_link_creation
" See https://github.com/lervag/wiki.vim/commit/62d63bcaad768717d9b6447e057e4d7a927ced99
let g:wiki_link_extension = 'md'

call plug#end()

"------------------------------------------------------------------------------"
" General settings
"------------------------------------------------------------------------------"

" Enable line numbers
set number

" Replace tabs by spaces
set expandtab

" Ensure line wrapping at word boundaries instead of anywhere in the word
set linebreak

" Disable code folding
set nofoldenable

" Disable swap files
set noswapfile

" Allow opening another buffer without saving the current buffer
set hidden

" Shell-like completion in wildmenu (complete to longest common match)
set wildmode=longest:full,full

" Number of lines to scroll with Ctrl-U and Ctrl-D (default is half the screen)
set scroll=2

" Minimum number of lines below or above the cursor when scrolling
set scrolloff=5

" Disable all auto-formatting of text (see :help fo-table)
set formatoptions=

" Use Bash instead of sh for default shell syntax (see :h ft-sh-syntax)
let g:is_bash=1

" Do not move cursor one position back when exiting insert mode
" autocmd InsertEnter * let CursorColumnI = col('.')
" autocmd CursorMovedI * let CursorColumnI = col('.')
" autocmd InsertLeave * if col('.') != CursorColumnI | call cursor(0, col('.')+1) | endif

"------------------------------------------------------------------------------"
" UI elements and colours
"------------------------------------------------------------------------------"

" Colour column
set colorcolumn=80
highlight ColorColumn ctermbg=235

" Cursor line
set cursorline
highlight LineNr ctermfg=yellow cterm=None
highlight CursorLine ctermbg=239 cterm=None
highlight CursorLineNr ctermbg=yellow ctermfg=black cterm=bold 

" Status line
set statusline=%!MyStatusLine()
highlight StatusLine ctermbg=green ctermfg=black cterm=bold
highlight StatusLineNC ctermbg=254 ctermfg=black cterm=bold

" Tab line
set showtabline=2
set tabline=%!MyTabLine()
highlight TabLine ctermbg=darkgray ctermfg=white cterm=bold
highlight TabLineSel ctermbg=lightblue ctermfg=black cterm=bold
highlight TabLineFill ctermbg=black cterm=none cterm=bold

" Auto-completion popup menu (wildmenu)
highlight Pmenu ctermfg=white ctermbg=blue
highlight PmenuSel ctermbg=5 ctermfg=black cterm=bold
highlight PmenuThumb ctermbg=darkblue
highlight PmenuSbar ctermbg=grey

" Search highlighing
highlight Search ctermbg=5 ctermfg=black

" Visual mode
highlight Visual ctermbg=yellow ctermfg=black cterm=none

" Vertical split bar
set fillchars+=vert:\ 
highlight VertSplit ctermbg=254 cterm=none

"------------------------------------------------------------------------------"
" Mappings
"------------------------------------------------------------------------------"

" Leader key
let mapleader = "\<Space>"

" Quick navigation in normal mode
nnoremap <C-j> 5j
nnoremap <C-k> 5k
nnoremap <C-h> 20h
nnoremap <C-l> 20l
nnoremap J 10j
nnoremap K 10k

" Quick navigation in visual mode
vnoremap <C-j> 5j
vnoremap <C-k> 5k
vnoremap J 10j
vnoremap K 10k

" Navigate up and down through wrapped lines like through real lines
nnoremap j gj
nnoremap k gk

" Miscellaneous mappings
nnoremap <leader>w :w<CR>
nnoremap <leader>W :wa<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>Q :tabclose<CR>
nnoremap <leader>z :qa<CR>
nnoremap <leader>Z :qa!<CR>
nnoremap <leader>n :set number!<CR>
nnoremap <leader>, :nohlsearch<CR>
nnoremap <leader>G :set spell!<CR>
nnoremap <leader>A ggVG
nnoremap <leader>b :bdelete<CR>
nnoremap <leader>B :bdelete!<CR>
nnoremap <leader>l :ls<CR>
nnoremap <leader>d :pwd<CR>
nnoremap <leader>f :echo @%<CR>
nnoremap <leader>p :echo expand('%:p')<CR>
nnoremap <leader>j :echo 'B=' . bufnr()<CR>
nnoremap <leader>i :echo 'W=' . winnr()<CR>
nnoremap <leader>I :echo 'T=' . tabpagenr()<CR>
nnoremap <leader>v :source ~/.vimrc<CR>

" Yank to system clipboard
vnoremap Y "*y

" Macro recording and replaying
nnoremap @ q
nnoremap q <Nop>
nnoremap + @

" Allow inserting new lines and deleting characters from normal mode
" TODO: this interferes with wiki.vim which uses these to follow links
"nnoremap <CR> o<Esc>
"nnoremap <BS> i<BS><Esc>l

" Remap q[:/?] commands (to open the command-line window, see ':help q:') to
" h[:/?] to prevent mistyping ':q' (quit) as 'q:'.
nnoremap q: <Nop>
nnoremap q/ <Nop>
nnoremap q? <Nop>
nnoremap H: q/
nnoremap H/ q/
nnoremap H? q?

" Highlight/replace word under cursor. The difference between s|r and S|R is
" that s|r defines a word as 'word' and S|R as 'WORD' (e.g. '[foo]-bar' vs.
" '[foo-bar]'.). See ':h word', ':h WORD', ':h c_CTRL-R_CTRL-W').
nnoremap <leader>s :%s/<C-r><C-w>//gn<CR><C-o>
nnoremap <leader>S :%s/<C-r><C-a>//gn<CR><C-o>
nnoremap <leader>r :%s/\<<C-r><C-w>\>//g<left><left>
nnoremap <leader>R :%s/\<<C-r><C-a>\>//g<left><left>

" Disable default mappings
nnoremap <Left> <Nop>
inoremap <Left> <Nop>
vnoremap <Left> <Nop>
nnoremap <Right> <Nop>
inoremap <Right> <Nop>
vnoremap <Right> <Nop>
nnoremap <Up> <Nop>
inoremap <Up> <Nop>
vnoremap <Up> <Nop>
nnoremap <Down> <Nop>
inoremap <Down> <Nop>
vnoremap <Down> <Nop>
nnoremap ZZ <Nop>

"------------------------------------------------------------------------------"
" Tabs, windows, and buffers
"------------------------------------------------------------------------------"

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

"------------------------------------------------------------------------------"
" Tabs
"------------------------------------------------------------------------------"

" Create a new tab at the end of the tabline
nnoremap <C-w>c :$tabnew<CR>

" Go to next and previous tab (wraps at last and first tab)
call submode#enter_with('switch-tab', 'n', '', '<C-w>n', 'gt')
call submode#map('switch-tab', 'n', '', 'n', 'gt')
call submode#map('switch-tab', 'n', '', '<C-w>n', 'gt')
call submode#enter_with('switch-tab', 'n', '', '<C-w>p', 'gT')
call submode#map('switch-tab', 'n', '', 'p', 'gT')
call submode#map('switch-tab', 'n', '', '<C-w>p', 'gT')

" Go to the tab with a specific tab number
nnoremap <C-w>1 1gt
nnoremap <C-w>2 2gt
nnoremap <C-w>3 3gt
nnoremap <C-w>4 4gt
nnoremap <C-w>5 5gt
nnoremap <C-w>6 6gt
nnoremap <C-w>7 7gt
nnoremap <C-w>8 8gt
nnoremap <C-w>9 9gt

" Toggle to the last active tab
nnoremap <C-w>t g<Tab>

" Move current tab one position to the right or left (does not wrap)
call submode#enter_with('move-tab', 'n', '', '<C-w>N', ':+tabmove<CR>')
call submode#map('move-tab', 'n', '', 'N', ':+tabmove<CR>')
call submode#map('move-tab', 'n', '', '<C-w>N', ':+tabmove<CR>')
call submode#enter_with('move-tab', 'n', '', '<C-w>P', ':-tabmove<CR>')
call submode#map('move-tab', 'n', '', 'P', ':-tabmove<CR>')
call submode#map('move-tab', 'n', '', '<C-w>P', ':-tabmove<CR>')

"------------------------------------------------------------------------------"
" Windows
"------------------------------------------------------------------------------"

" Create a new window to the right (vertical split) or below (horizontal split)
nnoremap <C-w>, <C-w>v
nnoremap <C-w>- <C-w>s

" This has the effect of moving the cursor the new window after splitting
set splitbelow
set splitright

" Go to window to left/right/below/above (does not wrap)
call submode#enter_with('switch-win', 'n', '', '<C-w>h', '<C-w>h')
call submode#map('switch-win', 'n', '', 'h', '<C-w>h')
call submode#map('switch-win', 'n', '', '<C-w>h', '<C-w>h')
call submode#enter_with('switch-win', 'n', '', '<C-w>l', '<C-w>l')
call submode#map('switch-win', 'n', '', 'l', '<C-w>l')
call submode#map('switch-win', 'n', '', '<C-w>l', '<C-w>l')
call submode#enter_with('switch-win', 'n', '', '<C-w>j', '<C-w>j')
call submode#map('switch-win', 'n', '', 'j', '<C-w>j')
call submode#map('switch-win', 'n', '', '<C-w>j', '<C-w>j')
call submode#enter_with('switch-win', 'n', '', '<C-w>k', '<C-w>k')
call submode#map('switch-win', 'n', '', 'k', '<C-w>k')
call submode#map('switch-win', 'n', '', '<C-w>k', '<C-w>k')

" Go to the window with a specific window number (local to tab)
nnoremap <Leader>1 :1wincmd w<CR>
nnoremap <Leader>2 :2wincmd w<CR>
nnoremap <Leader>3 :3wincmd w<CR>
nnoremap <Leader>4 :4wincmd w<CR>
nnoremap <Leader>5 :5wincmd w<CR>
nnoremap <Leader>6 :6wincmd w<CR>
nnoremap <Leader>7 :7wincmd w<CR>
nnoremap <Leader>8 :8wincmd w<CR>
nnoremap <Leader>9 :9wincmd w<CR>

" Toggle to the last active window
nnoremap <C-w>w <C-w>p

" Disable moving windows to avoid confusion
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
call submode#enter_with('resize-win', 'n', '', '<C-w>K', '3<C-w>+')
call submode#map('resize-win', 'n', '', 'K', '3<C-w>+')
call submode#enter_with('resize-win', 'n', '', '<C-w>J', '3<C-w>-')
call submode#map('resize-win', 'n', '', 'J', '3<C-w>-')

"------------------------------------------------------------------------------"
" Buffers
"------------------------------------------------------------------------------"

" Cycle through buffers (in current window)
nnoremap <C-n> :bnext<CR>
nnoremap <C-p> :bprevious<CR>

"------------------------------------------------------------------------------"
" Functions
"------------------------------------------------------------------------------"

" Create statusline string (see ':h statusline')
function! MyStatusLine()
  let num_buf = len(getbufinfo({'buflisted':1}))
  return ' [W=%{winnr()}]#%{winnr("$")} [B=%n]#' . num_buf . ' %<%f %m %r %= [C=%c] [L=%l]#%L [%p%%] '
endfunction

" Create tabline string. Each tab label contains:
"   1. Tab number (starting from 1)
"   2. A token for each window in the tab including the following:
"     1. Window number (relative to tab, starting from 1)
"     2. Buffer ID of the buffer in the window
"     3. Modification indicator showing whether the buffer has unsaved changes
" References:
"   [1] :h setting-tabline
"   [2] https://github.com/mkitt/tabline.vim/blob/master/plugin/tabline.vim
function! MyTabLine()
  let tabline = ''
  for tab_id in range(1, tabpagenr('$'))

    " List of buffer IDs in the windows of this tab
    let win_buf_list = tabpagebuflist(tab_id)

    " Token per window containing window number, buffer ID, and mod indicator
    let win_str = ''
    for i in range(len(win_buf_list))
      let buf_id = get(win_buf_list, i)
      let win_str .= ' ' . (i + 1) . '[B=' . buf_id . (getbufvar(buf_id, "&mod") ? '*' : '') . ']'
    endfor

    " Construct tabline string portion for this tab
    let tabline .= (tab_id  == tabpagenr() ? '%#TabLineSel#' : '%#TabLine#') . ' T=' . tab_id . '' . win_str . ' %#TabLineFill# '
  endfor
  return tabline . '%#TabLineFill#'
endfunction
