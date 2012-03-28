"AUTHOR:   Atsushi Mizoue <asionfb@gmail.com>
"WEBSITE:  https://github.com/AtsushiM/simple-todo.vim
"VERSION:  0.9
"LICENSE:  MIT

let g:simple_todo_PluginDir = expand('<sfile>:p:h:h').'/'
let g:simple_todo_TemplateDir = g:simple_todo_PluginDir.'template/'

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

command! SToDo call stodo#ToDo()
command! SCheckToDoStatus call stodo#CheckToDoStatus()
command! SChangeToDoStatus call stodo#ChangeToDoStatus()
command! SToDoSort call stodo#ToDoSort()
command! SToDoRemove call stodo#ToDoRemove()
exec 'au BufRead '.g:simple_todo_DefaultToDo.' call stodo#SetBufMapToDo()'
exec 'au BufRead '.g:simple_todo_DefaultToDo.' set filetype=stodo'
exec 'au BufWinLeave '.g:simple_todo_DefaultToDo.' call stodo#ToDoClose()'
exec 'au VimLeave * call stodo#VimLeaveToDo()'
