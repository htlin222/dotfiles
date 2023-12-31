" autocmd VimLeave * mksession! ./.vim_auto_session.vim
" autocmd VimEnter * source ~/.vim_auto_session.vim
"
" augroup numbertoggle
"     au!
"     au BufEnter, FocusGained * set relativenumber
"     " au BufLeave,FocusLost * set norelativenumber
" augroup END
" augroup line
"     au!
"     autocmd InsertEnter * silent execute '!ffplay -v 0 -nodisp -autoexit ~/.config/nvim/lua/custom/media/enter.wav &'
"     au InsertLeave * highlight CursorLine ctermbg=none
" augroup END

" augroup AutoSaveOnExit
"     autocmd!
"     autocmd BufLeave * if expand('%:t') != 'plugins.lua' && !&readonly | silent! write | endif
" augroup END
" augroup SFx
"   au BufWritePost * silent execute '!ffplay -v 0 -nodisp -autoexit ~/.config/nvim/lua/custom/media/save.wav &'
" augroup END
