let s:thisplugin = expand('<sfile>:p:h:h')
let s:qargpattern = '\v\s*(\S+)%(\s+(.*))?$'


""
" Installs this plugin. The maktaba library must be available: either make sure
" it's on your runtimepath or put it in the same directory as glaive and source
" the glaive bootstrap file. (If you source the bootstrap file, there is no need
" to call this function.)
function! glaive#Install() abort
  let l:glaive = maktaba#plugin#GetOrInstall(s:thisplugin)
  call l:glaive.Load('commands')
endfunction


""
" Given {qargs} (a quoted string given to the @command(Glaive) command, as
" generated by |<q-args>|), returns the plugin name and the configuration
" string.
" @throws BadValue if {qargs} has no plugin name.
function! glaive#SplitPluginNameFromOperations(qargs) abort
  let l:match = matchlist(a:qargs, s:qargpattern)
  if empty(l:match)
    throw maktaba#error#BadValue('Plugin missing in "%s"', a:qargs)
  endif
  return [l:match[1], l:match[2]]
endfunction


""
" Applies Glaive operations for {plugin} as described in {operations}.
" See @command(Glaive).
" @throws BadValue when the parsing of {operations} goes south.
" @throws WrongType when invalid flag operations are requested.
" @throws NotFound when a {operations} references a non-existent flag.
function! glaive#Configure(plugin, text) abort
  try
    let l:settings = maktaba#setting#ParseAll(maktaba#string#Strip(a:text))
  catch /ERROR(BadValue):/
    let [l:type, l:msg] = maktaba#error#Split(v:exception)
    let l:qualifier = 'Error parsing Glaive settings for %s: %s'
    throw maktaba#error#Message(l:type, l:qualifier, a:plugin.name, l:msg)
  endtry
  for l:setting in l:settings
    call l:setting.Apply(a:plugin)
  endfor
endfunction
