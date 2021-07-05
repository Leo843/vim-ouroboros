let test="use two databases instead of one"

" load plugin
set rtp+=.
source ./plugin/vim-ouroboros.vim

" setup initial state
"   create first database
let lines= [
      \ 'true false',
      \ 'begin end',
      \ 'one two three'
      \ ]
let db1='/tmp/ouroboros_test_db1'
call writefile(lines,db1)
"   create second database
let lines= [
      \ 'right left',
      \ 'insert remove'
      \ ]
let db2='/tmp/ouroboros_test_db2'
call writefile(lines,db2)
"   set path to databases
let g:ouroboros_db=[db1,db2]
"   set mapping
nmap <silent> , :call Ouroboros()<CR>
"   set test line
call setline(1, 'remove')
call cursor(1,1)

" perform operation
normal ,

" test the result
if getline('.') == "insert"
  exe 'silent !echo "' . test . ' => success"'
else
  exe 'silent !echo "' . test . ' => failure"'
endif

quit!
