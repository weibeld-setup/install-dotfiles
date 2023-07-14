" .vimrc file for Vim and Neovim
"
" This file is intended to have the same effect on Vim and Neovim and to be
" fully compatible with both. The config directory is assumed to be ~/.vim
" which is the default in Vim, but is explicitly configured for Neovim here.
"------------------------------------------------------------------------------"

"=============================================================================="
"  __     _____ __  __    ___   _ _____ _____     _____ __  __ 
"  \ \   / /_ _|  \/  |  / / \ | | ____/ _ \ \   / /_ _|  \/  |
"   \ \ / / | || |\/| | / /|  \| |  _|| | | \ \ / / | || |\/| |
"    \ V /  | || |  | |/ / | |\  | |__| |_| |\ V /  | || |  | |
"     \_/  |___|_|  |_/_/  |_| \_|_____\___/  \_/  |___|_|  |_|
"                                                            
"=============================================================================="
" Vim/Neovim

" General settings for Vim only (most of these are default in Neovim
if !has('nvim')

  " Disable vi-compatibility mode (also default in Vim, except when -u is used)
  set nocompatible

  " Enable incremental search with highlighting
  set incsearch
  set hlsearch
  nohlsearch

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

" General settings for Neovim only 
else
  " Use ~/.vim as main config directory (this is the default in Vim)
  set runtimepath+=~/.vim

endif 


"=============================================================================="
"   ____  _    _   _  ____ ___ _   _ ____  
"  |  _ \| |  | | | |/ ___|_ _| \ | / ___| 
"  | |_) | |  | | | | |  _ | ||  \| \___ \ 
"  |  __/| |__| |_| | |_| || || |\  |___) |
"  |_|   |_____\___/ \____|___|_| \_|____/ 
"                                         
"=============================================================================="
" Plugins

function! SourceConfig(name)
  execute 'source ~/.vim/config/'..a:name
endfunction

" Neovim default for plugin directory is ~/.local/share/nvim/plugged
call plug#begin('~/.vim/plugged')

" vim-submode (https://github.com/kana/vim-submode)
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

" vim-table-mode (https://github.com/dhruvasagar/vim-table-mode)
Plug 'dhruvasagar/vim-table-mode'
call SourceConfig('vim-table-mode.vim')


"wiki.vim (https://github.com/lervag/wiki.vim)
Plug 'lervag/wiki.vim'
call SourceConfig('wiki.vim')

call plug#end()


"=============================================================================="
"    ____ _____ _   _ _____ ____      _    _     
"   / ___| ____| \ | | ____|  _ \    / \  | |    
"  | |  _|  _| |  \| |  _| | |_) |  / _ \ | |    
"  | |_| | |___| |\  | |___|  _ <  / ___ \| |___ 
"   \____|_____|_| \_|_____|_| \_\/_/   \_\_____|
"                                                
"=============================================================================="
" General

set number
set expandtab
set linebreak
set nofoldenable
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


"=============================================================================="
"   __  __    _    ____  ____ ___ _   _  ____ ____  
"  |  \/  |  / \  |  _ \|  _ \_ _| \ | |/ ___/ ___| 
"  | |\/| | / _ \ | |_) | |_) | ||  \| | |  _\___ \ 
"  | |  | |/ ___ \|  __/|  __/| || |\  | |_| |___) |
"  |_|  |_/_/   \_\_|   |_|  |___|_| \_|\____|____/ 
"                                                   
"=============================================================================="
" Mappings

" Leader key
let mapleader = "\<Space>"

" Leader key mappings
nnoremap <leader>w :w<CR>
nnoremap <leader>W :wa<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>Q :qa<CR>
nnoremap <leader>c :tabclose<CR>
nnoremap <leader>z :q!<CR>
nnoremap <leader>Z :qa!<CR>
nnoremap <leader>n :set number!<CR>
nnoremap <leader>, :nohlsearch<CR>
nnoremap <leader>G :set spell!<CR>
nnoremap <leader>d :bdelete<CR>
nnoremap <leader>D :bdelete!<CR>
nnoremap <leader>l :ls<CR>
nnoremap <leader>L :ls!<CR>
nnoremap <leader>p :pwd<CR>
nnoremap <leader>f :echo @%<CR>
nnoremap <leader>F :echo expand('%:p')<CR>
nnoremap <leader>i :echo 'B=' . bufnr() . ', W=' . winnr() . ', T=' . tabpagenr()<CR>
nnoremap <leader>v :source ~/.vimrc<CR>
nnoremap <leader>V :edit ~/.vimrc<CR>
nnoremap <leader>r :redir 
nnoremap <leader>R :redir END<CR>

" Navigation by multiple lines/columns in normal and visual mode
nnoremap <C-j> 5j
nnoremap <C-k> 5k
nnoremap <C-h> 20h
nnoremap <C-l> 20l
nnoremap J 10j
nnoremap K 10k
vnoremap <C-j> 5j
vnoremap <C-k> 5k
vnoremap J 10j
vnoremap K 10k

" Treat wrapped lines like hard lines when navigating up/down
nnoremap j gj
nnoremap k gk

" Remap command-line window commands to prevent mistyping :q (see ':h cmdwin')
nnoremap q: <Nop>
nnoremap q/ <Nop>
nnoremap q? <Nop>
nnoremap H: q:
nnoremap H/ q/
nnoremap H? q?

" Entering Ex mode
nnoremap E gQ

" Allow inserting new lines from normal mode
"nnoremap <CR> o<Esc>
"nnoremap <BS> i<BS><Esc>l

" Omni-completion trigger (https://vim.fandom.com/wiki/Omni_completion)
inoremap <C-n> <C-X><C-O>

" Macro recording and replaying
nnoremap @ q
nnoremap q <Nop>
nnoremap + @

" Search and replace the word under cursor
" For WORD instead of word (see ':h WORD'), use <C-a> instead of <C-w>
nnoremap <leader>s :%s/<C-r><C-w>//gn<CR>n
nnoremap <leader>S :%s/\<<C-r><C-w>\>//g<left><left>

" Disable various default mappings
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

" Yank to system clipboard
vnoremap Y "*y

"------------------------------------------------------------------------------"
"   ____         __  __               
"  | __ ) _   _ / _|/ _| ___ _ __ ___ 
"  |  _ \| | | | |_| |_ / _ \ '__/ __|
"  | |_) | |_| |  _|  _|  __/ |  \__ \
"  |____/ \__,_|_| |_|  \___|_|  |___/
"                                    
"------------------------------------------------------------------------------"
" Buffers

" TODO: create some mappings for opening new buffers (e.g. new empty buffer,
" new empty buffer in split window, etc.).

nnoremap <leader>b :call OpenBuffer(input('BUF: ', '', 'buffer'))<CR>
nnoremap <leader>B :call DeleteBuffers(input('DELETE BUF: '))<CR>

" Switch to next and previous buffer (only listed buffers)
nnoremap <C-n> :bnext<CR>
nnoremap <C-p> :bprevious<CR>

" Toggle previously open buffer
nnoremap <C-w>b :b#<CR>

"------------------------------------------------------------------------------"
"  __        ___           _                   
"  \ \      / (_)_ __   __| | _____      _____ 
"   \ \ /\ / /| | '_ \ / _` |/ _ \ \ /\ / / __|
"    \ V  V / | | | | | (_| | (_) \ V  V /\__ \
"     \_/\_/  |_|_| |_|\__,_|\___/ \_/\_/ |___/
"                                              
"------------------------------------------------------------------------------"
" Windows

" Create a new window to the right (vertical split) or below (horizontal split)
nnoremap <C-w>, <C-w>v
nnoremap <C-w>- <C-w>s

" This has the effect of moving the cursor to the new window after splitting
set splitbelow
set splitright

" Switch to or close a specific window by number. Abort with Ctrl-C.
" Vim compat: only :[count]wincmd {arg}, not :wincmd [count] {arg}
nnoremap <leader>a :<C-u>execute input('Switch to window: ')..'wincmd w'<CR>
" TODO: prevent closing of current window when typing <Esc> in prompt
nnoremap <leader>A :<C-u>execute 'close '..input('Close window: ')<CR>

" Toggle to the last active window
nnoremap <C-w><w> <C-w>p
nnoremap <C-w><space> <C-w>p

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

"------------------------------------------------------------------------------"
"   _____     _         
"  |_   _|_ _| |__  ___ 
"    | |/ _` | '_ \/ __|
"    | | (_| | |_) \__ \
"    |_|\__,_|_.__/|___/
"
"------------------------------------------------------------------------------"
" Tabs

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

"------------------------------------------------------------------------------"
"   _____                   _             _                       _      
"  |_   _|__ _ __ _ __ ___ (_)_ __   __ _| |  _ __ ___   ___   __| | ___ 
"    | |/ _ \ '__| '_ ` _ \| | '_ \ / _` | | | '_ ` _ \ / _ \ / _` |/ _ \
"    | |  __/ |  | | | | | | | | | | (_| | | | | | | | | (_) | (_| |  __/
"    |_|\___|_|  |_| |_| |_|_|_| |_|\__,_|_| |_| |_| |_|\___/ \__,_|\___|
" 
"------------------------------------------------------------------------------"
" Terminal mode

" Open a terminal in a horizontal split window
nnoremap <leader>x :terminal<CR>

" Make Neovim terminal mode behave like Vim defaults
if has('nvim')
  " Open a terminal in a horizontal split window
  nnoremap <leader>x :split \| :terminal<CR>
  " Enter insert mode after opening terminal
  autocmd TermOpen * startinsert
  " Remove line numbers in insert mode and restore them when existing
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
"   _   _ ___    ______ ___  _     ___  _   _ ____  ____  
"  | | | |_ _|  / / ___/ _ \| |   / _ \| | | |  _ \/ ___| 
"  | | | || |  / / |  | | | | |  | | | | | | | |_) \___ \ 
"  | |_| || | / /| |__| |_| | |__| |_| | |_| |  _ < ___) |
"   \___/|___/_/  \____\___/|_____\___/ \___/|_| \_\____/ 
"  
"=============================================================================="
" UI/Colours

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
" From ':h window':
"   A buffer is the in-memory text of a file.
"   A window is a viewport on a buffer.
"   A tab page is a collection of windows.


"=============================================================================="
"   _____ _   _ _   _  ____ _____ ___ ___  _   _ ____  
"  |  ___| | | | \ | |/ ___|_   _|_ _/ _ \| \ | / ___| 
"  | |_  | | | |  \| | |     | |  | | | | |  \| \___ \ 
"  |  _| | |_| | |\  | |___  | |  | | |_| | |\  |___) |
"  |_|    \___/|_| \_|\____| |_| |___\___/|_| \_|____/ 
"
"=============================================================================="
" Functions


"=============================================================================="
"   _   _ ___        _                           _       
"  | | | |_ _|   ___| | ___ _ __ ___   ___ _ __ | |_ ___ 
"  | | | || |   / _ \ |/ _ \ '_ ` _ \ / _ \ '_ \| __/ __|
"  | |_| || |  |  __/ |  __/ | | | | |  __/ | | | |_\__ \
"   \___/|___|  \___|_|\___|_| |_| |_|\___|_| |_|\__|___/
"                                                       
"=============================================================================="
" UI elements

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

" Custom status line.
" Notes:
"   - See ':h statusline'
" CAUTION:
"   Window-specific values (e.g. window number) must not be saved in a local
"   variable because they get overwritten by different function calls.
function! MyStatusLine()
  return '[%{winnr()}] %{MakeBufferMainIndicator(bufnr(), " ")}%< %{MakeBufferFileTypeIndicator(bufnr(), "", " ", 1)}%f %R %= [C=%c] [L=%l]#%L [%p%%] '
endfunction

"------------------------------------------------------------------------------"
"   ____         __   __         _          ___        _     
"  | __ ) _   _ / _| / /_      _(_)_ __    / / |_ __ _| |__  
"  |  _ \| | | | |_ / /\ \ /\ / / | '_ \  / /| __/ _` | '_ \ 
"  | |_) | |_| |  _/ /  \ V  V /| | | | |/ / | || (_| | |_) |
"  |____/ \__,_|_|/_/    \_/\_/ |_|_| |_/_/   \__\__,_|_.__/ 
"                                                            
"------------------------------------------------------------------------------"
" Buf/win/tab

"------------------------------------------------------------------------------"
" Helpers
"------------------------------------------------------------------------------"

" Extract custom buffer info from a bufinfo() response.
" Args:
"   bufinfo: the result of an arbitrary call to the bufinfo() function
" Returns:
"   A list with selected information about buffers passed as argument.
" Notes:
"   - Terminal buffers can only be deleted with :bd! (see [1,2]): For this
"     reason, they are indicated separately in the extracted information.
"   - For an overview of buffer types, see ':h buftype'.
" Resources:
"   [1] https://github.com/neovim/neovim/issues/4683
"   [2] https://github.com/neovim/neovim/pull/15402
function! _ExtractBufInfo(bufinfo)
  let res = []
  for b in a:bufinfo
    let buf_nr = b.bufnr
    let buf_type = getbufvar(buf_nr, '&buftype')
    let buf_file_type = getbufvar(buf_nr, '&filetype')
    let res = add(res, {
        \ 'nr': buf_nr,
        \ 'name': b.name,
        \ 'listed': b.listed,
        \ 'loaded': b.loaded,
        \ 'modified': b.changed,
        \ 'normal': buf_type == '',
        \ 'terminal': buf_type == 'terminal',
        \ 'filetype': buf_file_type
      \ })
  endfor
  return res
endfunction

" Extract custom windows info from a getwininfo() response.
" Args:
"   wininfo: the result of an arbitrary call to the getwininfo() function
" Returns:
"   A list with selected information about the windows passed as argument.
function! _ExtractWinInfo(wininfo)
  let res = []
  for w in a:wininfo
    let res = add(res, {
        \ 'id': w.winid,
        \ 'nr': w.winnr,
        \ 'tab': w.tabnr,
        \ 'buf': w.bufnr
      \ })
  endfor
  return res
endfunction

" Extract custom tab info from a gettabinfo() response.
" Args:
"   tabinfo: the result of an arbitrary call to the gettabinfo() function
" Returns:
"   A list with selected information about the tabs passed as argument.
function! _ExtractTabInfo(tabinfo)
  let res = []
  for t in a:tabinfo
    let res = add(res, {
        \ 'nr': t.tabnr,
        \ 'wins': t.windows,
      \ })
  endfor
  return res
endfunction

"------------------------------------------------------------------------------"
" Get
"------------------------------------------------------------------------------"

" Return info about a specific buffer.
" Args:
"   buf: a buffer number or name
" Returns:
"   Dictionary
" Notes:
"   - If the buffer is not found, an empty string is returned.
"   - Finds listed, loaded, and unloaded buffers.
function! GetBuffer(buf)
  let bufinfo = getbufinfo(a:buf)
  return len(bufinfo) > 0 ? _ExtractBufInfo(bufinfo)[0] : ''
endfunction

" Return selected info about the specified window.
" Args:
"   win_id: ID of a window
" Notes:
"   - If the window is not found, an empty string is returned
function! GetWindowByID(win_id)
  let wininfo = getwininfo(a:win_id)
  return !empty(wininfo) ? _ExtractWinInfo(wininfo)[0] : ''
endfunction

" Return selected info about the specified window in the specified tab.
" Args:
"   win_nr: number of a window in the specified tab
"   tab_nr: number of a tab (optional: current tab is used if omitted)
" Notes:
"   - If the tab_nr argument is omitted, the current tab is used.
"   - If the window is not found, an empty string is returned
function! GetWindowByNumber(win_nr, tab_nr = '')
  let tab_nr = empty(a:tab_nr) ? tabpagenr() : a:tab_nr
  let wininfo = getwininfo(win_getid(a:win_nr, tab_nr))
  return !empty(wininfo) ? _ExtractWinInfo(wininfo)[0] : ''
endfunction

" Return selected info about the specified tab.
" Args:
"   tab_nr: number of a tab
" Notes:
"   - If the specified tab does not exist, and empty string is returned.
function! GetTab(tab_nr)
  let tabinfo = gettabinfo(a:tab_nr)
  return !empty(tabinfo) ? _ExtractTabInfo(tabinfo)[0] : ''
endfunction

"------------------------------------------------------------------------------"
" List
"------------------------------------------------------------------------------"

" Return list with info about all buffers.
function! ListBuffers()
  return _ExtractBufInfo(getbufinfo())
endfunction

" Return list with info about listed buffers.
function! ListListedBuffers()
  return _ExtractBufInfo(getbufinfo({'buflisted': 1}))
endfunction

" Return list with info about loaded buffers.
function! ListLoadedBuffers()
  return _ExtractBufInfo(getbufinfo({'bufloaded': 1}))
endfunction

" Return list with info about unloaded buffers.
function! ListUnloadedBuffers()
  return filter(_ExtractBufInfo(getbufinfo()), {_, buf -> !buf.loaded})
endfunction

" Return list with info about modified buffers.
" Note:
"   In Neovim, terminal buffers are always in the modified state and can't be 
"   saved, thus they are removed from the results.
function! ListModifiedBuffers()
  return filter(_ExtractBufInfo(getbufinfo({'bufmodified': 1})), {_, buf -> !buf.terminal})
endfunction

" Return selected info about all windows.
function! ListWindows()
  return _ExtractWinInfo(getwininfo())
endfunction

" Return selected info about all windows in the specified tab.
" Args:
"   tab_nr: number of a tab
" Notes:
"   - If the tab_nr argument is omitted, the current tab is used.
"   - If the specified tab does not exist, an empty string is returned.
function! ListWindowsInTab(tab_nr = '')
  let tab_nr = empty(a:tab_nr) ? tabpagenr() : a:tab_nr
  let wins = filter(_ExtractWinInfo(getwininfo()), {_, win -> win.tab == tab_nr})
  return empty(wins) ? '' : wins
endfunction

" Return selected info about all tabs.
function! ListTabs()
  return _ExtractTabInfo(gettabinfo())
endfunction

"------------------------------------------------------------------------------"
" Check existence
"------------------------------------------------------------------------------"

" Check wether the specified buffer exists.
" Args:
"   buf: a buffer number or name
function! IsBuffer(buf)
  return !empty(GetBuffer(a:buf))
endfunction

" Check wether the specified buffer exists and is a listed buffer.
" Args:
"   buf: a buffer number or name
function! IsListedBuffer(buf)
  let buf = GetBuffer(a:buf)
  return !empty(buf) && buf.listed
endfunction

" Check wether the specified buffer exists and is a loaded buffer.
" Args:
"   buf: a buffer number or name
function! IsLoadedBuffer(buf)
  let buf = GetBuffer(a:buf)
  return !empty(buf) && buf.loaded
endfunction

" Check wether the specified buffer exists and is an unloaded buffer.
" Args:
"   buf: a buffer number or name
function! IsUnloadedBuffer(buf)
  let buf = GetBuffer(a:buf)
  return !empty(buf) && !buf.loaded
endfunction

" Check wether the specified buffer exists and is modified.
" Args:
"   buf: a buffer number or name
function! IsModifiedBuffer(buf)
  let buf = GetBuffer(a:buf)
  return !empty(buf) && buf.modified
endfunction

" Check whether a window with the specified ID exists.
" Args:
"   win_id: ID of a window
function! IsWindowID(win_id)
  return !empty(GetWindowByID(a:win_id))
endfunction

" Check whether a window with the specified number exists in the specified tab.
" Args:
"   win_nr: number of a window in the specified tab
"   tab_nr: number of the tab to check (optional: current tab used if omitted)
" Notes:
"   - If the tab_nr argument is omitted, the current tab is used.
function! IsWindowNumber(win_nr, tab_nr = '')
  let tab_nr = empty(a:tab_nr) ? tabpagenr() : a:tab_nr
  return !empty(GetWindowByNumber(a:win_nr, tab_nr))
endfunction

" Check whether the tab with the specified number exists.
" Args:
"   tab_nr: number of a tab
function! IsTab(tab_nr)
  return !empty(GetTab(a:tab_nr))
endfunction

"------------------------------------------------------------------------------"
" Open/switch
"------------------------------------------------------------------------------"

" Open the specified buffer in the current window.
" Args:
"   buf: number or name of a buffer
" Notes:
"   - Any buffer that's printed by 'ls!' can be opened, this includes listed,
"     loaded, and unloaded buffers
function! OpenBuffer(buf)
  if empty(a:buf)
    echo
  elseif !IsBuffer(a:buf)
    redraw
    echo "Error: buffer '"..a:buf.."' does not exist"
  else
    execute 'buffer '..a:buf
  endif
endfunction

" Switch to the window with the specified ID.
" Args:
"   win_id: ID of a window
" Notes:
"   - If the target window is in another tab, then the tab is also switched.
function! SwitchToWindowByID(win_id)
  if empty(a:win_id)
    echo
  elseif !IsWindowID(a:win_id)
    redraw
    echo "Error: window with ID '"..a:win_id.."' does not exist"
  else
    call win_gotoid(a:win_id)
  endif
endfunction

" Switch to the window with the specified number in the specified tab.
" Args:
"   win_nr: number of a window in the specified tab
"   tab_nr: number of a tab (optional: current tab is used if omitted)
" Notes:
"  - If the tab_nr argument is omitted, then the current tab is used
function! SwitchToWindowByNumber(win_nr, tab_nr = '')
  let tab_nr = empty(a:tab_nr) ? tabpagenr() : a:tab_nr
  if empty(a:win_nr)
    echo
  elseif !IsWindowNumber(a:win_nr, tab_nr)
    redraw
    echo "Error: window with number '"..a:win_nr.."' in tab '"..tab_nr.."' does not exist"
  else
    let win = GetWindowByNumber(a:win_nr, tab_nr)
    call win_gotoid(win.id)
  endif
endfunction

" Switch to the specified tab.
" Args:
"   tab_nr: number of a tab
" Notes:
"   - This switches to the currently active window in the specified tab
function! SwitchToTab(tab_nr)
  if empty(a:tab_nr)
    echo
  elseif !IsTab(a:tab_nr)
    redraw
    echo "Error: tab '"..a:tab_nr.."' does not exist"
  else
    execute 'tabnext '..a:tab_nr
  endif
endfunction

"------------------------------------------------------------------------------"
" Delete
"------------------------------------------------------------------------------"

" TODO: function to delete a list of windows in the current tab by window number

" TODO: function to delete a list of windows by window ID

" TODO: function to delete a list of tabs

" Delete the specified buffers.
" Args:
"   str: a string specifying one or more whitespace-separated buffer IDs or
"        names. IDs and names may be freely mixed.
" Notes:
"   - If a supplied buffer does not exist, it is silently ignored.
"   - The function is idempotent, i.e. specifying a buffer multiple times in
"     the input has the same effect as specifying it a single time.
" TODO: only loaded buffers can be deleted (unloaded buffers can't)
" TODO: correctly split buffer names with spaces (escaped with '\' )
function! DeleteBuffers(str)
  let i = 0
  for buf in sort(split(a:str))
    if IsLoadedBuffer(buf)
      execute 'bdelete '..buf
      let i += 1
    endif
  endfor
  redraw
  redrawtabline
  echo MakePluralisedMessage('Deleted %n %w', i, 'buffer', 'buffers')
endfunction

"------------------------------------------------------------------------------#
"   ____  _           _             
"  |  _ \(_)___ _ __ | | __ _ _   _ 
"  | | | | / __| '_ \| |/ _` | | | |
"  | |_| | \__ \ |_) | | (_| | |_| |
"  |____/|_|___/ .__/|_|\__,_|\__, |
"              |_|            |___/
" 
"------------------------------------------------------------------------------#
" Display

" TODO: display function to list all windows in all tabs with IDs (similar to :ls, :tabs). See :windo, :tabdo

" Make indicator showing number, type, and modified state of a specific buffer.
" Args:
"   buf: number or name of a buffer
"   sep: separator between buffer number and type/modification indicator
" Notes:
"   - If the buffer is not found, an empty string is returned.
function! MakeBufferMainIndicator(buf, sep = '')
  let buf = GetBuffer(a:buf)
  return !empty(buf) ? buf.nr..a:sep..(buf.normal ? (buf.modified ? '🔴' : '🟢') : (buf.terminal ? '🟣':  '⚪️')) : ''
endfunction

" Make indicator showing file type of specified buffer.
" Args:
"   buf:     number or name of a buffer
"   prefix:  string to prepend to the file type (optional)
"   postfix: string to append to the file type (optional)
"   allcaps: wether to format the file type with all-caps or not (optional)
" Notes:
"   - If the buffer is not found, an empty string is returned.
"   - If the buffer has no file type, an empty string is returned.
function! MakeBufferFileTypeIndicator(buf, prefix = '', postfix = '', allcaps = 0)
  let buf = GetBuffer(a:buf)
  return !empty(buf) && !empty(buf.filetype) ? a:prefix..(a:allcaps ? toupper(buf.filetype) : buf.filetype)..a:postfix : ''
endfunction

"------------------------------------------------------------------------------#
"   _____         _                                       _             
"  |_   _|____  _| |_   _ __  _ __ ___   ___ ___  ___ ___(_)_ __   __ _ 
"    | |/ _ \ \/ / __| | '_ \| '__/ _ \ / __/ _ \/ __/ __| | '_ \ / _` |
"    | |  __/>  <| |_  | |_) | | | (_) | (_|  __/\__ \__ \ | | | | (_| |
"    |_|\___/_/\_\\__| | .__/|_|  \___/ \___\___||___/___/_|_| |_|\__, |
"                      |_|                                        |___/ 
" 
"------------------------------------------------------------------------------#
" Text processing

" Format a message with the correct pluralised form of a word.
" Args:
"   msg:      message containing %n and %w placeholders for number and word
"   n:        number
"   singular: singular form of the word
"   plural:   plural form of the word
" Example:
"   MakePluralisedMessage('Deleted %n %w', 3, 'buffer', 'buffers')
"   ==> 'Deleted 3 buffers '
function! MakePluralisedMessage(msg, n, singular, plural)
  return substitute(substitute(a:msg, '%w', (a:n == 1 ? a:singular : a:plural), 'g'), '%n', a:n, 'g')
endfunction
