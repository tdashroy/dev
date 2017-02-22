" Make Vim more useful. This should always be your first configuration line.
set nocompatible

" Use this files directory as the base
let s:path = expand('<sfile>:p:h')

" Wraps paths to make them relative to this directory.
function! Dot(path)
	return fnameescape(s:path) . fnameescape(a:path)
endfunction

" Load all configuration modules.
for file in split(glob(Dot('modules/*.vim')), '\n')
	execute 'source ' . file
endfor
