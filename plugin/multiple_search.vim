if exists("g:loaded_multiple_search")
  finish
endif
let g:loaded_loaded_multiple_search = 1

augroup multiple_search_augroup
	au WinNew * lua require'multiple_search'.update_matches({})
augroup END

" matchadd: pattern
" matchdelete: group
" next_matchgroup: backward
" next_match: flags

command -nargs=1 MultipleSearch lua require'multiple_search'.matchadd(<args>)
command -nargs=? MultipleSearchDeleteGroup lua luaeval("require'multiple_search'.matchdelete({group = (_A ~= '' and tonumber(_A) or nil)})", '<args>')
command -nargs=0 MultipleSearchNext lua require'multiple_search'.next_match({})
command -nargs=0 MultipleSearchNextBack lua require'multiple_search'.next_match({flags = 'b'})
command -nargs=0 MultipleSearchNextGroup lua require'multiple_search'.next_matchgroup({})
command -nargs=0 MultipleSearchNextGroupBack lua require'multiple_search'.next_match({backward = true})
