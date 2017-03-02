" Initialize vim-plug
call plug#begin()

" code-dark
Plug 'tomasiser/vim-code-dark'

" Powershell syntax support
Plug 'PProvost/vim-ps1'

" Lock in the plugin list.
call plug#end()

" Load all plugin configuration files
for file in split(glob(Dot('modules/plugins/*.vim')), '\n')
	execute 'source' file
endfor
