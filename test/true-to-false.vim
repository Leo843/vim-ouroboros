set rtp+=.
source ./plugin/vim-ouroboros.vim
nmap <silent> , :call Ouroboros()<CR>
normal itrue
normal ,
let line=getline('.')
if line == "false"
  exe 'silent !echo "test success"'
else
  exe 'silent !echo "test failure"'
endif
quit!
