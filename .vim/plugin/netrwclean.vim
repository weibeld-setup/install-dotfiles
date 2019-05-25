" netrwclean.vim
"   Author: Charles E. Campbell
"   Date:   Oct 07, 2008
"   Version: 1b	ASTRO-ONLY
" ---------------------------------------------------------------------
"  Load Once: {{{1
if &cp || exists("g:loaded_netrwclean")
 finish
endif
let g:loaded_netrwclean= "v1b"
if v:version < 700
 echohl WarningMsg
 echo "***warning*** this version of netrwclean needs vim 7.0"
 echohl Normal
 finish
endif
let s:keepcpo= &cpo
set cpo&vim

" ---------------------------------------------------------------------
"  Public Interface: {{{1
com! -bang	NetrwClean	call netrwclean#NetrwClean(<bang>0)

" ---------------------------------------------------------------------
" netrwclean#NetrwClean: remove netrw {{{2
" supports :NetrwClean  -- remove netrw from first directory on runtimepath
"          :NetrwClean! -- remove netrw from all directories on runtimepath
fun! netrwclean#NetrwClean(sys)
"  call Dfunc("netrwclean#NetrwClean(sys=".a:sys.")")

  if !exists("g:netrw_use_errorwindow")
   let g:netrw_use_errorwindow= 1
  endif

  if a:sys
   let choice= confirm("Remove personal and system copies of netrw?","&Yes\n&No")
  else
   let choice= confirm("Remove personal copy of netrw?","&Yes\n&No")
  endif
"  call Decho("choice=".choice)
  let diddel= 0
  let diddir= ""

  if choice == 1
   for dir in split(&rtp,',')
    if filereadable(dir."/plugin/netrwPlugin.vim")
"     call Decho("removing netrw-related files from ".dir)
     if s:System("delete",dir."/plugin/netrwPlugin.vim")        |call netrwclean#ErrorMsg(1,"unable to remove ".dir."/plugin/netrwPlugin.vim",55)        |endif
     if s:System("delete",dir."/autoload/netrwFileHandlers.vim")|call netrwclean#ErrorMsg(1,"unable to remove ".dir."/autoload/netrwFileHandlers.vim",55)|endif
     if s:System("delete",dir."/autoload/netrwSettings.vim")    |call netrwclean#ErrorMsg(1,"unable to remove ".dir."/autoload/netrwSettings.vim",55)    |endif
     if s:System("delete",dir."/autoload/netrw.vim")            |call netrwclean#ErrorMsg(1,"unable to remove ".dir."/autoload/netrw.vim",55)            |endif
     if s:System("delete",dir."/syntax/netrw.vim")              |call netrwclean#ErrorMsg(1,"unable to remove ".dir."/syntax/netrw.vim",55)              |endif
     if s:System("delete",dir."/syntax/netrwlist.vim")          |call netrwclean#ErrorMsg(1,"unable to remove ".dir."/syntax/netrwlist.vim",55)          |endif
     let diddir= dir
     let diddel= diddel + 1
     if !a:sys|break|endif
    endif
   endfor
  endif

   echohl WarningMsg
  if diddel == 0
   echomsg "netrw is either not installed or not removable"
  elseif diddel == 1
   echomsg "removed one copy of netrw from <".diddir.">"
  else
   echomsg "removed ".diddel." copies of netrw"
  endif
   echohl None

"  call Dret("netrwclean#NetrwClean")
endfun

" ------------------------------------------------------------------------
" s:System: using Steve Hall's idea to insure that Windows paths stay {{{2
"              acceptable.  No effect on Unix paths.
"  Examples of use:  let result= s:System("system",path)
"                    let result= s:System("delete",path)
fun! s:System(cmd,path)
"  call Dfunc("s:System(cmd<".a:cmd."> path<".a:path.">)")

  if !exists("g:netrw_cygwin")
   if has("win32") || has("win95") || has("win64") || has("win16")
    if &shell =~ '\%(\<bash\>\|\<zsh\>\)\%(\.exe\)\=$'
     let g:netrw_cygwin= 1
    else
     let g:netrw_cygwin= 0
    endif
   else
    let g:netrw_cygwin= 0
   endif
  endif

  let path = a:path
  if !g:netrw_cygwin && (has("win32") || has("win95") || has("win64") || has("win16"))
   " system call prep
   " remove trailing slash (Win95)
   let path = substitute(path, '\(\\\|/\)$', '', 'g')
   " remove escaped spaces
   let path = substitute(path, '\ ', ' ', 'g')
   " convert slashes to backslashes
   let path = substitute(path, '/', '\', 'g')
   if exists("+shellslash")
    let sskeep= &shellslash
    setlocal noshellslash
    exe "let result= ".a:cmd."('".path."')"
    let &shellslash = sskeep
   else
    exe "let result= ".a:cmd."(".g:netrw_shq.path.g:netrw_shq.")"
   endif
  else
   exe "let result= ".a:cmd."('".path."')"
  endif

"  call Dret("s:System result<".result.">")
  return result
endfun

" ---------------------------------------------------------------------
" netrwclean#ErrorMsg: {{{2
"   0=note     = s:NOTE
"   1=warning  = s:WARNING
"   2=error    = s:ERROR
"  Sep 04, 2007 : max errnum currently is 55
fun! netrwclean#ErrorMsg(level,msg,errnum)
"  call Dfunc("netrwclean#ErrorMsg(level=".a:level." msg<".a:msg."> errnum=".a:errnum.") g:netrw_use_errorwindow=".g:netrw_use_errorwindow)

  if a:level == 1
   let level= "**warning** (netrw) "
  elseif a:level == 2
   let level= "**error** (netrw) "
  else
   let level= "**note** (netrw) "
  endif

  if g:netrw_use_errorwindow
   " (default) netrw creates a one-line window to show error/warning
   " messages (reliably displayed)

   " record current window number for NetrwRestorePosn()'s benefit
   let s:winBeforeErr= winnr()

   " getting messages out reliably is just plain difficult!
   " This attempt splits the current window, creating a one line window.
   if bufexists("NetrwMessage") && bufwinnr("NetrwMessage") > 0
    exe bufwinnr("NetrwMessage")."wincmd w"
    set ma noro
    call setline(line("$")+1,level.a:msg)
    $
   else
    bo 1split
    enew
    setlocal bt=nofile
    file NetrwMessage
    call setline(line("$"),level.a:msg)
   endif
   if &fo !~ '[ta]'
    syn clear
    syn match netrwMesgNote	"^\*\*note\*\*"
    syn match netrwMesgWarning	"^\*\*warning\*\*"
    syn match netrwMesgError	"^\*\*error\*\*"
    hi link netrwMesgWarning WarningMsg
    hi link netrwMesgError   Error
   endif
   setlocal noma ro bh=wipe

  else
   " (optional) netrw will show messages using echomsg.  Even if the
   " message doesn't appear, at least it'll be recallable via :messages
   redraw!
   if a:level == s:WARNING
    echohl WarningMsg
   elseif a:level == s:ERROR
    echohl Error
   endif
   echomsg level.a:msg
"   call Decho("echomsg ***netrw*** ".a:msg)
   echohl None
  endif

"  call Dret("netrwclean#ErrorMsg")
endfun

" ---------------------------------------------------------------------
"  Restore: {{{1
let &cpo= s:keepcpo
unlet s:keepcpo
" vim: ts=4 fdm=marker
