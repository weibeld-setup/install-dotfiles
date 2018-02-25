au! BufNewFile,BufRead *.R,*.Rout,*.r,*.Rhistory,*.Rt,*.Rout.save,*.Rout.fail setf r
au! BufNewFile,BufRead *.txt setf markdown.pandoc | set tabstop=4 shiftwidth=4
au! BufNewFile,BufRead *.java,*.js,*.gradle,*.md set tabstop=4 shiftwidth=4
au! BufNewFile,BufRead .bash* set filetype=sh
autocmd FileType perl setlocal tabstop=4 shiftwidth=4
autocmd FileType javascript setlocal tabstop=2 shiftwidth=2
