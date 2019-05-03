au! BufNewFile,BufRead *.R,*.Rout,*.r,*.Rhistory,*.Rt,*.Rout.save,*.Rout.fail setf r
au! BufNewFile,BufRead *.java,*.js,*.gradle,*.md set tabstop=4 shiftwidth=4
autocmd FileType perl setlocal tabstop=4 shiftwidth=4
autocmd FileType javascript setlocal tabstop=2 shiftwidth=2
au BufNewFile,BufRead .bash* set ft=sh
au BufNewFile,BufRead *.groovy,Jenkinsfile set ft=groovy tabstop=4 shiftwidth=4
au BufNewFile,BufRead .bash* setf sh
au BufNewFile,BufRead *.tpl set ft=go
" au BufNewFile,BufRead *.tpl set ft=mustache
