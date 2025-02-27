if exists('loaded_nerd_comments')
    finish
endif
if v:version < 700
    echoerr "NERDCommenter: this plugin requires vim >= 7. DOWNLOAD IT! You'll thank me later!"
    finish
endif
let loaded_nerd_comments = 1

" Function: s:InitVariable() function
" This function is used to initialise a given variable to a given value. The
" variable is only initialised if it does not exist prior
"
" Args:
"   -var: the name of the var to be initialised
"   -value: the value to initialise var to
"
" Returns:
"   0
function s:InitVariable(var, value)
    if !exists(a:var)
        execute 'let ' . a:var . ' = ' . string(a:value)
    endif
endfunction

" Section: variable initialization
call s:InitVariable('g:NERDAllowAnyVisualDelims', 1)
call s:InitVariable('g:NERDBlockComIgnoreEmpty', 0)
call s:InitVariable('g:NERDCommentWholeLinesInVMode', 0)
call s:InitVariable('g:NERDCommentEmptyLines', 0)
call s:InitVariable('g:NERDCompactSexyComs', 0)
call s:InitVariable('g:NERDCreateDefaultMappings', 1)
call s:InitVariable('g:NERDDefaultNesting', 1)
call s:InitVariable('g:NERDMenuMode', 3)
call s:InitVariable('g:NERDLPlace', '[>')
call s:InitVariable('g:NERDUsePlaceHolders', 1)
call s:InitVariable('g:NERDRemoveAltComs', 1)
call s:InitVariable('g:NERDRemoveExtraSpaces', 0)
call s:InitVariable('g:NERDRPlace', '<]')
call s:InitVariable('g:NERDSpaceDelims', 0)
call s:InitVariable('g:NERDDefaultAlign', 'none')
call s:InitVariable('g:NERDTrimTrailingWhitespace', 0)
call s:InitVariable('g:NERDToggleCheckAllLines', 0)
call s:InitVariable('g:NERDDisableTabsInBlockComm', 0)
call s:InitVariable('g:NERDSuppressWarnings', 0)

" Section: Comment mapping and menu item setup
" ===========================================================================

" Create menu items for the specified modes.  If a:combo is not empty, then
" also define mappings and show a:combo in the menu items.
function! s:CreateMaps(modes, target, desc, combo)
    " Build up a map command like
    " 'noremap <silent> <Plug>NERDCommenterComment :call nerdcommenter#Comment("n", "Comment")'
    let plug = '<Plug>NERDCommenter' . a:target
    let plug_start = 'noremap <silent> ' . plug . ' :call nerdcommenter#Comment("'
    let plug_end = '", "' . a:target . '")<CR>'
    " Build up a menu command like
    " 'menu <silent> comment.Comment<Tab>\\cc <Plug>NERDCommenterComment'
    let menuRoot = get(['', 'comment', '&comment', '&Plugin.&comment', '&Plugin.Nerd\ &Commenter'],
                \ g:NERDMenuMode, '')
    let menu_command = 'menu <silent> ' . menuRoot . '.' . escape(a:desc, ' ')
    if strlen(a:combo)
        let leader = exists('g:mapleader') ? g:mapleader : '\'
        let menu_command .= '<Tab>' . escape(leader, '\') . a:combo
    endif
    let menu_command .= ' ' . (strlen(a:combo) ? plug : a:target)
    " Execute the commands built above for each requested mode.
    for mode in (a:modes ==# '') ? [''] : split(a:modes, '\zs')
        if strlen(a:combo)
            execute mode . plug_start . mode . plug_end
            if g:NERDCreateDefaultMappings && !hasmapto(plug, mode)
                execute mode . 'map <leader>' . a:combo . ' ' . plug
            endif
        endif
        " Check if the user wants the menu to be displayed.
        if g:NERDMenuMode !=# 0
            execute mode . menu_command
        endif
    endfor
endfunction


call s:CreateMaps('nx', 'Invert',     'Invert', 'ci')


" Shim functions so old code gets passed through to the autoload functions
function! NERDComment(mode, type) range
    if !g:NERDSuppressWarnings
        echom 'Function NERDComment() has been deprecated, please use nerdcommenter#Comment() instead'
    endif
	if a:firstline != a:lastline
		echoerr "Sorry! We can't pass a range through this deprecation shim, please update your code."
		return v:false
	endif
    return nerdcommenter#Comment(a:mode, a:type)
endfunction

function! NERDCommentIsLineCommented(lineNo)
    if !g:NERDSuppressWarnings
        echom 'Function NERDCommentIsLineCommented() has been deprecated, please use nerdcommenter#IsLineCommented() instead'
    endif
    return nerdcommenter#IsLineCommented(a:lineNo)
endfunction

function! NERDCommentIsCharCommented(line, col)
    if !g:NERDSuppressWarnings
        echom 'Function NERDCommentIsCharCommented() has been deprecated, please use nerdcommenter#IsCharCommented() instead'
    endif
    return nerdcommenter#IsCharCommented(a:line, a:col)
endfunction

inoremap <silent> <Plug>NERDCommenterInsert <Space><BS><Esc>:call nerdcommenter#Comment('i', "insert")<CR>

" switch to/from alternative delimiters (does not use wrapper function)
nnoremap <Plug>NERDCommenterAltDelims :call nerdcommenter#SwitchToAlternativeDelimiters(1)<CR>
