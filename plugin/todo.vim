"AUTHOR:   Atsushi Mizoue <asionfb@gmail.com>
"WEBSITE:  https://github.com/AtsushiM/simple-todo.vim
"VERSION:  0.9
"LICENSE:  MIT

let g:simple_todo_PluginDir = expand('<sfile>:p:h:h').'/'
let g:simple_todo_TemplateDir = g:simple_todo_PluginDir.'template/'
let g:simple_todo_SubDir = g:simple_todo_PluginDir.'sub/'
let s:simple_todo_ToDoNo = 0
let s:simple_todo_ToDoOpen = 0

if !exists("g:simple_todo_DefaultConfigDir")
    let g:simple_todo_DefaultConfigDir = $HOME.'/.simple-todo/'
endif
if !exists("g:simple_todo_DefaultToDo")
    let g:simple_todo_DefaultToDo = '~ToDo~'
endif
if !exists("g:simple_todo_ToDoWindowSize")
    let g:simple_todo_ToDoWindowSize = 'topleft 50vs'
endif

" config
if !isdirectory(g:simple_todo_DefaultConfigDir)
    call mkdir(g:simple_todo_DefaultConfigDir)
endif
let s:simple_todo_DefaultToDo = g:simple_todo_DefaultConfigDir.g:simple_todo_DefaultToDo
if !filereadable(s:simple_todo_DefaultToDo)
    call system('cp '.g:simple_todo_TemplateDir.g:simple_todo_DefaultToDo.' '.s:simple_todo_DefaultToDo)
endif

function! s:ToDoOpen()
    exec g:simple_todo_ToDoWindowSize." ".g:simple_todo_DefaultConfigDir.g:simple_todo_DefaultToDo
    let s:simple_todo_ToDoOpen = 1
    let s:simple_todo_ToDoNo = bufnr('%')
endfunction
function! s:ToDoClose()
    let s:simple_todo_ToDoOpen = 0
    SToDoSort
    exec 'bw '.s:simple_todo_ToDoNo
    winc p
endfunction

function! s:ToDo()
    if s:simple_todo_ToDoOpen == 0
        call s:ToDoOpen()
    else
        call s:ToDoClose()
    endif
endfunction
function! s:CheckToDoStatus()
    let todo = getline('.')
    let i = matchlist(todo, '\v^([-~/])\s(.*)')
    let flg = 0
    if i != []
        let st = i[1]
        if st != '-' && st && '~' && st != '/'
            let flg = 1
        endif
    else
        let flg = 1
    endif

    if flg == 1
        let st = ''
        silent normal ^i- 
    endif

    silent normal ^ll

    return st
endfunction
function! s:ChangeToDoStatus()
    let st = <SID>CheckToDoStatus()

    if st == '-'
        let st = '~'
    elseif st == '~'
        let st = '/'
    else
        let st = '-'
    endif

    exec 'silent normal ^xxi'.st.' '
    silent normal ^ll
    silen w
endfunction
function! s:ToDoRemove()
    let file = g:simple_todo_DefaultConfigDir.g:simple_todo_DefaultToDo
    let todo = readfile(file)
    let ret = ''
    for e in todo
        let i = matchlist(e, '\v^(/)(.*)')
        if i == [] && e != ''
            let ret = ret.e.'\n'
        endif
    endfor

    call system('echo -e "'.ret.'" > '.file)
endfunction
function! ToDoSort()
    let file = g:simple_todo_DefaultConfigDir.g:simple_todo_DefaultToDo
    let todo = readfile(file)
    let ret_normal = ''
    let ret_action = ''
    let ret_end = ''
    for e in todo
        let i = matchlist(e, '\v^(.)\s(.*)')
        if i != []
            if i[1] == '-'
                let ret_normal = ret_normal.e.'\n'
            elseif i[1] == '~'
                let ret_action = ret_action.e.'\n'
            else
                let ret_end = ret_end.e.'\n'
            endif
        endif
    endfor

    " join
    let ret = ret_action.ret_normal.ret_end

    call system('echo -e "'.ret.'" > '.file)
endfunction

command! SToDo call s:ToDo()
command! SCheckToDoStatus call s:CheckToDoStatus()
command! SChangeToDoStatus call s:ChangeToDoStatus()
command! SToDoSort call ToDoSort()
command! SToDoRemove call s:ToDoRemove()

function! s:SetBufMapToDo()
    set cursorline
    inoremap <buffer><silent> <CR> <Esc>o- 
    inoremap <buffer><silent> <Esc> <Esc>:SCheckToDoStatus<CR>
    nnoremap <buffer><silent> o o<Esc>:SCheckToDoStatus<CR>a
    nnoremap <buffer><silent> O O<Esc>:SCheckToDoStatus<CR>a
    nnoremap <buffer><silent> <Space> :SChangeToDoStatus<CR>
    nnoremap <buffer><silent> <Tab> :SChangeToDoStatus<CR>
    nnoremap <buffer><silent> <C-C> :SChangeToDoStatus<CR>
    nnoremap <buffer><silent> q :call <SID>ToDoClose()<CR>
endfunction
exec 'au BufRead '.g:simple_todo_DefaultToDo.' call <SID>SetBufMapToDo()'
exec 'au BufRead '.g:simple_todo_DefaultToDo.' set filetype=stodo'
exec 'au BufWinLeave '.g:simple_todo_DefaultToDo.' call <SID>ToDoClose()'

function! s:VimLeaveToDo()
    SToDoRemove
    SToDoSort
endfunction
exec 'au VimLeave * call <SID>VimLeaveToDo()'
