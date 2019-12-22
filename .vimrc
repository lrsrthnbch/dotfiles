set number

let g:vimtex_view_method = 'mupdf'

call plug#begin('~/.vim/plugged')

Plug 'arcticicestudio/nord-vim'
Plug 'lervag/vimtex'

call plug#end()

colorscheme nord

let @m = "Documents/md_template.txt^["
