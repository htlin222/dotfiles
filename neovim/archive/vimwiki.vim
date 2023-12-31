autocmd FileType vimwiki.markdown setlocal syntax=markdown
autocmd FileType vimwiki.markdown :syn off | syn on
hi VimwikiBold ctermfg=220 guifg=black ctermbg=235 guibg=#ffffaf cterm=bold gui=bold
let g:vimwiki_auto_header=0
let g:vimwiki_global_ext=0
let g:vimwiki_sync_branch = "main"
let g:zettel_default_mappings = 0

" wiki list {{{
let wiki_1 = {'path': '~/Documents/Medical', 'name': 'Medical',
                      \ 'links_space_char': '_',
                      \ 'syntax': 'markdown', 'ext': '.md'}
let wiki_2 = {'path': '/Users/htlin/Library/CloudStorage/GoogleDrive-ppoiu87@gmail.com/我的雲端硬碟/manual', 'name': 'Tech',
                      \ 'links_space_char': ' ',
                      \ 'syntax': 'markdown', 'ext': '.md'}
let wiki_3 = {'path': '~/blog/content/posts/', 'name': 'blog',
                      \ 'links_space_char': '_',
                      \ 'syntax': 'markdown', 'ext': '.md'}
let wiki_4 = {'path': '~/garden/content/', 'name': 'garden',
                      \ 'links_space_char': '_',
                      \ 'syntax': 'markdown', 'ext': '.md'}
let wiki_5 = {'path': '~/lizard-on-zotero/', 'name': 'zotero',
                      \ 'links_space_char': '_',
                      \ 'syntax': 'markdown', 'ext': '.Rmd'}
let wiki_6 = {'path': '/Volumes/GoogleDrive/我的雲端硬碟/manual', 'name': 'manual',
                      \ 'links_space_char': ' ',
                      \ 'syntax': 'markdown', 'ext': '.md'}
let wiki_7 = {'path': '~/Documents/Patients/', 'name': 'Patients',
                      \ 'links_space_char': '_',
                      \ 'syntax': 'markdown', 'ext': '.md'}
let g:vimwiki_list = [wiki_1,wiki_2,wiki_3,wiki_4,wiki_5,wiki_6,wiki_7]
" }}}
let g:nv_search_paths = ['~/Documents/Medical/','~/vimwiki']
let g:vimwiki_markdown_link_ext = 1
let g:vimwiki_CJK_length = 1

augroup filetype_vimwiki
    autocmd!
    autocmd FileType vimwiki.markdown nnoremap <silent><CR> :VimwikiFollowLink<CR>
    autocmd FileType vimwiki.markdown nnoremap <silent><C-j> :VimwikiFollowLink<CR>
    autocmd FileType vimwiki.markdown nnoremap <silent><Right> :bp<CR>
    autocmd FileType vimwiki.markdown nnoremap <silent><Left> :bn<CR>
    autocmd FileType vimwiki.markdown xnoremap <silent><C-j> <Plug>(nvim-surround-visual)R
    autocmd FileType vimwiki.markdown xnoremap <silent><C-k> <Plug>(nvim-surround-visual)X
    autocmd FileType vimwiki.markdown xnoremap <silent><C-h> :VimwikiChangeSymbolTo *<CR>
    autocmd FileType vimwiki.markdown xnoremap <silent><C-l> :VimwikiChangeSymbolTo -<CR>
    autocmd FileType vimwiki.markdown xnoremap <silent><C-n> :VimwikiChangeSymbolTo 1.<CR>
    autocmd FileType vimwiki.markdown nnoremap <silent><C-k> :VimwikiGoBackLink<CR>
    autocmd FileType vimwiki.markdown nnoremap <silent><C-t> :VimwikiTabnewLink<CR>
    autocmd FileType vimwiki.markdown inoremap <silent>[[ [[<esc><Plug>ZettelSearchMap
    autocmd Filetype vimwiki silent! iunmap <buffer> <Tab>
    autocmd Filetype vimwiki silent! iunmap <buffer> <S-Tab>
    autocmd Filetype vimwiki silent! iunmap <buffer> <CR>
    autocmd FileType vimwiki.markdown nnoremap T <Plug>ZettelYankNameMap
    autocmd FileType vimwiki.markdown xnoremap z <Plug>ZettelNewSelectedMap
    autocmd FileType vimwiki.markdown nnoremap gZ <Plug>ZettelReplaceFileWithLink
    autocmd FileType vimwiki.markdown nnoremap <leader>wb :ZettelBackLinks<CR>
    autocmd FileType vimwiki.markdown nnoremap <leader>wv <Plug>VimwikiVSplitLink<CR>
    autocmd FileType vimwiki.markdown nnoremap <leader>wnt <Plug>VimwikiTabnewLink<CR>
    autocmd FileType vimwiki.markdown nnoremap <leader>wnz <Plug>ZettelNew<CR>
    autocmd FileType vimwiki.markdown nnoremap <leader>wni <Plug>ZettelInsertNote<CR>
    autocmd FileType vimwiki.markdown nnoremap <silent><leader>wf :call AppendWithFileName()<CR>p
    autocmd FileType vimwiki.markdown nnoremap <silent><leader>wk :call Remark()<CR>
    autocmd FileType vimwiki.markdown nnoremap <silent><leader>wp :call PandocCite()<CR>
    autocmd FileType vimwiki.markdown nnoremap <silent><leader>cp :call FileName()<CR>
    autocmd FileType vimwiki.markdown xnoremap <silent><leader>wx :call ReplaceSpace()<CR>
    autocmd FileType vimwiki.markdown nnoremap <silent>\8 I*<space><esc>
    autocmd FileType vimwiki.markdown nnoremap <silent><leader>8 I*<space><esc>
    autocmd FileType vimwiki.markdown nnoremap <silent>\- I-<space><esc>
    autocmd FileType vimwiki.markdown xnoremap <silent>\h I*<space><esc>
    autocmd FileType vimwiki.markdown xnoremap <silent>\- I-<space><esc>
    autocmd BufWritePost ~/Documents/Coding/* silent! !sh $DOTFILES/shellscripts/codesync.sh
augroup END

let g:zettel_format = "%raw_title"
let g:zettel_fzf_command = "rg --column --line-number --ignore-case --no-heading --color=always"
let g:zettel_link_format="[[%title]]"
let g:zettel_generated_index_title_level = 2
let g:zettel_backlinks_title = "Backlink："
let g:zettel_backlinks_title_level = 3
let g:zettel_generated_tags_title = "Tags"
let g:zettel_generated_tags_title_level = 3
" let g:zettel_options = [{"template" : "~/.dotfile/.config/nvim/snippets/template.tpl" , "disable_front_matter": 1 }]

" functions {{{
au BufNewFile ~/Documents/Medical/diary/*.md
      \ call append(0,[
      \ "# " . split(expand('%:r'),'/')[-1], "",
      \ "## 所有日記", "[目錄](/diary/_index.md)" ])
command! Diary VimwikiDiaryIndex
" I find both commands a little tedious, so I create a :Diary command to navigate to the index page, and an autocommand to generate links each time the diary index is open.
augroup vimwikigroup
    autocmd!
    " automatically update links on read diary
    autocmd BufRead,BufNewFile dairy.md VimwikiDiaryGenerateLinks
augroup end
let g:vimwiki_key_mappings = {
            \ 'all_maps': 1,
            \ 'global': 1,
            \ 'headers': 1,
            \ 'text_objs': 1,
            \ 'table_format': 1,
            \ 'table_mappings': 0,
            \ 'lists': 1,
            \ 'links': 1,
            \ 'html': 1,
            \ 'mouse': 0,
            \ }
