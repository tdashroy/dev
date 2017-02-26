set encoding=utf-8

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
" This is preferred to syntax on
if has('syntax') && !exists('g:syntax_on')
	syntax enable
endif

" Automatically copy the indent of the current line when creating a new line
set autoindent

" backspace normally
set backspace=indent,eol,start
