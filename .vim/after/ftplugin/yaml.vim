" Prevent indenting of lines when prepending comment chars with 'normal 0i#'
" See https://unix.stackexchange.com/a/609636/317243
autocmd BufEnter *.yaml,*.yml :set indentkeys-=0#
