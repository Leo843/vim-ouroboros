let test="use buffer databases instead of global databases"

" load plugin
set rtp+=.
source ./plugin/vim-ouroboros.vim

" setup initial state
"   create database
let lines= [
      \ 'true false',
      \ 'begin end',
      \ 'one two three'
      \ ]
let db='/tmp/ouroboros_test_db'
call writefile(lines,db)
"   set path to database
let g:ouroboros_db=[] " unset global database
let b:ouroboros_db=[db]
"   set mapping
nmap <silent> , :call Ouroboros()<CR>
"   set test line
call setline(1, 'one')
call cursor(1,1)

" perform operation
normal ,,,

" test the result
if getline('.') == "one"
  exe 'silent !echo "' . test . ' => success"'
else
  exe 'silent !echo "' . test . ' => failure"'
endif

quit!