function Echo(str)
  call writefile([a:str],'test.out','a')
  " exe 'silent !echo "' . escape(a:str,'!') . '"'
endfunction

