let test="replace 'false' by 'true'"

" load plugin
set rtp+=.
source ./plugin/vim-ouroboros.vim
nmap <silent> , :call Ouroboros()<CR>

" setup initial state
normal ifalse

" perform operation
normal ,

" test the result
if getline('.') == "true"
  exe 'silent !echo "' . test . ' => success"'
else
  exe 'silent !echo "' . test . ' => failure"'
endif

quit!
