let test="replace 'true' by 'false'"

" load plugin
set rtp+=.
source ./plugin/vim-ouroboros.vim
nmap <silent> , :call Ouroboros()<CR>

" setup initial state
call setline(1, 'true')
call cursor(1,1)

" perform operation
normal ,

" test the result
if getline('.') == "false"
  exe 'silent !echo "' . test . ' => success"'
else
  exe 'silent !echo "' . test . ' => failure"'
endif

quit!
