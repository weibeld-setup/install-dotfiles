" Enable wiki.vim for all Markdown and YAML files
let g:wiki_filetypes = ['md', 'yaml']

" TODO: set this to the directory of the file
let g:wiki_root = '.'

" Disable automatic link creation
let g:wiki_link_transform_on_follow = 0

" Define custom mappings (disable defaults)
let g:wiki_mappings_use_defaults = 'none'
let g:wiki_mappings_local = {
  \ '<plug>(wiki-link-next)' : '<Tab>',
  \ '<plug>(wiki-link-prev)' : '<S-Tab>',
  \ '<plug>(wiki-link-follow)' : '<C-]>',
  \ '<plug>(wiki-link-return)' : '<BS>',
  \ }

" TODO: made obsolete by g:wiki_link_creation
" See https://github.com/lervag/wiki.vim/commit/62d63bcaad768717d9b6447e057e4d7a927ced99
"let g:wiki_link_extension = 'md'
