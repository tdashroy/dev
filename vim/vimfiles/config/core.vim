set encoding=utf-8
colorscheme codedark

""" sensible.vim below

" filetype commands. See :help :filetype-overview
if has('autocmd')
	" Turn on filetype detection
	filetype on
	" Turn on loading of plugin files for detected filetypes
	" These can be found in ftplugin/<type>.vim
	filetype plugin on
	" Turn on loading of indent files for detected filetypes
	" These can be found in indent/<type>.vim
	filetype indent on
endif

" Turn on syntax highlighting
if has('syntax') && !exists('g:syntax_on')
	syntax enable
endif

" Automatically copy the indent of the current line when creating a new line
set autoindent

" Backspace normally
set backspace=indent,eol,start

" Don't scan include files when using completion.
" Not really sure why you would want this to be honest, but
" I found another vimrc online that suggested it was less performant
" than scanning tags (unsure of what this is). Leaving it here until I notice I need it.
set complete-=i

" Making tab indenting smarter
set smarttab

" Don't consider numbers starting with 0 to be octal for CTRL_A (incrementing)
set nrformats-=octal

" Timeout after 100ms for key codes
set ttimeout
set ttimeoutlen=100

" Turn line numbers on by default
set nu
