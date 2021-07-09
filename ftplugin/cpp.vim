if !exists("g:loaded_ouroboros")
  finish
endif

if !exists("b:ouroboros_db")
  let b:ouroboros_db=[
        \ Ouroboros_get_root_dir() . '/db/cpp.db',
        \ Ouroboros_get_root_dir() . '/db/default.db'
        \ ]
endif
