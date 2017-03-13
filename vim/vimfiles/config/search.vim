" Incremental search, highlights as you search
set incsearch
" Turn on hlsearch (uncomment below) to highlight all matches in a search
" set hlsearch
" Use <C-L> to clear the highlighting of :set hlsearch.
if maparg('<C-L>', 'n') ==# ''
	nnoremap <silent> <C-L> :nohlsearch<C-R>=has('diff')?'<Bar>diffupdate':''<CR><CR><C-L>
endif
