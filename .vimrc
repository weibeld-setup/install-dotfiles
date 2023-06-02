" .vimrc file for Vim and Neovim
"
" This file is intended to have the same effect on Vim and Neovim and to be
" fully compatible with both. The config directory is assumed to be ~/.vim
" which is the default in Vim, but is explicitly configured for Neovim here.
"------------------------------------------------------------------------------"

"------------------------------------------------------------------------------"
" Vim-only settings
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

"------------------------------------------------------------------------------"
" Neovim-only settings
"------------------------------------------------------------------------------"
else
  " Use ~/.vim as main config directory (this is the default in Vim)
  set runtimepath+=~/.vim
endif

"------------------------------------------------------------------------------"
" vim-plug (plugins)
"------------------------------------------------------------------------------"

" ~/.vim/plugged as vim-plug dir (Neovim default: ~/.local/share/nvim/plugged)
call plug#begin('~/.vim/plugged')

"------------------------------------------------------------------------------"
" Plugin: vim-submode
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
" Plugin: vim-table-mode
"------------------------------------------------------------------------------"

" Automatically format Markdown tables
Plug 'dhruvasagar/vim-table-mode'
let g:table_mode_corner='|'

call plug#end()

"------------------------------------------------------------------------------"
" General settings
"------------------------------------------------------------------------------"

" Enable line numbers
set number

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
" Items from left to right:
"   1. Current working directory
"   2. File name
"   3. Buffer number
"   4. Modified indicator
"   5. Read-only indicator
"   6. Help page indicator (whether the buffer is a help page)
"   7. Current column
"   8. Current line and total number of lines
"   9. Percentage of current line through file
set statusline=[%{getcwd()}]\ [%f]\ [B=%n]\ %m\ %r\ %h\ %=[C\=%c]\ [L\=%l/%L]\ [%p%%]
highlight StatusLine ctermbg=green ctermfg=black cterm=bold
highlight StatusLineNC ctermbg=254 ctermfg=black cterm=bold

" Tabline
set showtabline=2
set tabline=%!MyTabline()
highlight TabLine ctermbg=black ctermfg=white cterm=bold
highlight TabLineSel ctermbg=green ctermfg=black cterm=bold
highlight TabLineFill ctermbg=black cterm=none

" Auto-completion popup menu (wildmenu)
highlight Pmenu ctermfg=white ctermbg=blue
highlight PmenuSel ctermbg=5 ctermfg=black cterm=bold
highlight PmenuThumb ctermbg=darkblue
highlight PmenuSbar ctermbg=grey

" Search highlighing
highlight Search ctermbg=5 ctermfg=black

" Visual mode
highlight Visual ctermbg=lightblue ctermfg=black

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
nnoremap <leader>q :q<CR>
nnoremap <leader>Q :qa<CR>
nnoremap <leader>Z :qa!<CR>
nnoremap <leader>b :bdelete<CR>
nnoremap <leader>B :bdelete!<CR>
nnoremap <leader>l :ls<CR>
nnoremap <leader>n :set number!<CR>
nnoremap <leader>, :nohlsearch<CR>
nnoremap ZZ <Nop>

" Macro recording and replaying
nnoremap @ q
nnoremap q <Nop>
nnoremap + @

" Allow inserting new lines and deleting characters from normal mode
nnoremap <CR> o<Esc>
nnoremap <BS> i<BS><Esc>l

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

"------------------------------------------------------------------------------"
" Tabs, windows, and buffers
"------------------------------------------------------------------------------"

" Notes: a Vim tab contains one or more windows. A window displays exactly one
" buffer. A buffer may be displayed in zero or more windows at the same time.
" An instance of Vim may contain one or more tabs. Window IDs are relative to
" the tab that contains these windows. However, buffer IDs are global across
" all tabs and windows. Vim tabs are similar to windows in tmux and Vim windows
" are similar to panes in tmux.
" References:
"   [1] :h window
"   [2] :h tab-pages

" Create a new tab at the end of the tabline
nnoremap <C-w>c :$tabnew<CR>

" Cycle to next tab
call submode#enter_with('switch-tab', 'n', '', '<C-w>n', 'gt')
call submode#map('switch-tab', 'n', '', 'n', 'gt')
call submode#map('switch-tab', 'n', '', '<C-w>n', 'gt')

" Cycle to previous tab
call submode#enter_with('switch-tab', 'n', '', '<C-w>p', 'gT')
call submode#map('switch-tab', 'n', '', 'p', 'gT')
call submode#map('switch-tab', 'n', '', '<C-w>p', 'gT')

" Move current tab to the right (does not cycle)
call submode#enter_with('move-tab', 'n', '', '<C-w>N', ':+tabmove<CR>')
call submode#map('move-tab', 'n', '', 'N', ':+tabmove<CR>')
call submode#map('move-tab', 'n', '', '<C-w>N', ':+tabmove<CR>')

" Move curent tab to the left (does not cycle)
call submode#enter_with('move-tab', 'n', '', '<C-w>P', ':-tabmove<CR>')
call submode#map('move-tab', 'n', '', 'P', ':-tabmove<CR>')
call submode#map('move-tab', 'n', '', '<C-w>P', ':-tabmove<CR>')

" Go to last active tab and window (toggle)
nnoremap g<Tab> g<Tab>
nnoremap <Tab> <C-w>p

" Close current tag and window
nnoremap <C-w>Q :tabclose<CR>
nnoremap <C-w>q :quit<CR>

" Create a new window to the right (vertical split) or below (horizontal split)
nnoremap <C-w>, <C-w>v
nnoremap <C-w>- <C-w>s

" This has the effect of moving the cursor the new window after splitting
set splitbelow
set splitright

" Disable moving of windows to avoid confusion
nnoremap <C-w>H <Nop>
nnoremap <C-w>J <Nop>
nnoremap <C-w>K <Nop>
nnoremap <C-w>L <Nop>

" Increase horizontal size of current window
call submode#enter_with('resize-win', 'n', '', '<C-w>H', '10<C-w>>')
call submode#map('resize-win', 'n', '', 'H', '10<C-w>>')

" Decrease horizontal size of current window
call submode#enter_with('resize-win', 'n', '', '<C-w>L', '10<C-w><')
call submode#map('resize-win', 'n', '', 'L', '10<C-w><')

" Increase vertical size of current window
call submode#enter_with('resize-win', 'n', '', '<C-w>K', '3<C-w>+')
call submode#map('resize-win', 'n', '', 'K', '3<C-w>+')

" Decrease vertical size of current window
call submode#enter_with('resize-win', 'n', '', '<C-w>J', '3<C-w>-')
call submode#map('resize-win', 'n', '', 'J', '3<C-w>-')

" Cycle through buffers (in current window)
nnoremap <C-n> :bnext<CR>
nnoremap <C-p> :bprevious<CR>

"------------------------------------------------------------------------------"
" Functions
"------------------------------------------------------------------------------"

" Custom tabline. This function returns and dynamic tabline string that can be
" assigned to the 'tabline' option. Each tab label includes the following:
"   1. Tab index (starting from 1)
"   2. Number of windows in the tab
"   3. Modification indicator for each window that has unsaved changes
"   4. Name of the buffer in the currently active window of the tab
" References:
"   [1] :h setting-tabline
"   [2] https://github.com/mkitt/tabline.vim/blob/master/plugin/tabline.vim
function! MyTabline()
  let tabline = ''
  for tab_id in range(1, tabpagenr('$'))

    " List of this tab's windows with associated buffer IDs
    " Note: array indices represent window IDs, values represent buffer IDs
    let win_buf_list = tabpagebuflist(tab_id)

    " Number of windows in this tab
    let num_win = len(win_buf_list)

    " Name of the buffer in the currently active window of this tab
    let cur_buf_id = win_buf_list[tabpagewinnr(tab_id)-1]
    let cur_buf_name = fnamemodify(bufname(cur_buf_id), ':t')
    let cur_buf_name = (cur_buf_name == '' ? '[No Name]' : cur_buf_name)

    " Modification indicator for each window that contains unsaved changes
    let mods = ''
    for buf_id in uniq(sort(copy(win_buf_list)))
      if getbufvar(buf_id, "&mod")
        let mods .= '*'
      endif
    endfor

    " Construct tabline string portion for this tab
    let style = (tab_id  == tabpagenr() ? '%#TabLineSel#' : '%#TabLine#')
    let tabline .=  style . ' ' . tab_id . ' [#' . num_win . mods . '] ' . cur_buf_name . ' '

  endfor
  return tabline . '%#TabLineFill#'
endfunction
