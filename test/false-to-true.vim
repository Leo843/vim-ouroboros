set rtp+=.
source ./plugin/vim-ouroboros.vim
nmap <silent> , :call Ouroboros()<CR>
normal ifalse
normal ,
let line=getline('.')
if line == "true"
  exe 'silent !echo "test success"'
else
  exe 'silent !echo "test failure"'
endif
quit!
