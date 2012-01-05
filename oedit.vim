" ============================================================================
" File:        oedit.vim
" Description: Opens files anywhere on the system for editing
" Author:      David Zuercher <david.zerker@gmail.com>
" Licence:     Vim license
" Website:     ...
" Version:     1.0
"
" Original taglist copyright notice:
"              Permission is hereby granted to use and distribute this code,
"              with or without modifications, provided that this copyright
"              notice is copied with it. Like anything else that's free,
"              taglist.vim is provided *as is* and comes with no warranty of
"              any kind, either expressed or implied. In no event will the
"              copyright holder be liable for any damages resulting from the
"              use of this software.
" ============================================================================

if &cp || exists('g:loaded_oedit')
    finish
endif

" Initialization {{{1

" Basic init {{{2

if v:version < 700
    echomsg 'OEdit: Vim version is too old, OEdit requires at least 7.0'
    finish
endif

if !exists("b:did_python_init")
    let b:did_python_init = 0

    if !has('python')
        " the oedit.vim plugin requires Vim to be compiled with +python
        echomsg 'OEdit: Python required!'
        finish
    endif
endif

python << PYTHON
import vim, sys
from subprocess import *

def _vims_internal(num, parts):
    try:
        parts.sort(key=lambda item: (item.startswith('-'), -len(item)))

        first = parts[0]

        if len(first) < 3:
            print "The first token is too short! Gimme something to work with!"
            return

        if first.startswith('~'):
            first = "-i %s" % first[1:]
        elif first.startswith('-'):
            print "The first token can not be exclusionary!"
            return

        extra = ""
        for piece in parts[1:]:
            if piece.startswith('-'):
                extra += " | grep -v %s " % piece[1:]
            elif piece.startswith('~'):
                extra += " | grep -i %s " % piece[1:]
            else:
                extra += " | grep %s " % piece

        p = Popen("locate %s %s" % (first, extra), shell=True, stderr=PIPE, stdout=PIPE, stdin=PIPE)
        p.wait()
        lines = p.stdout.read().strip().split('\n')
        lines = filter(lambda s: not s.endswith('.swp'), lines)

        if len(lines) > 30:
            print "Too many results.. here's a preview:"
            print "    ", "\n    ".join(lines[:30])
            return

        if len(lines[0]) == 0:
            print "No candidate files found for '%s' " % " ".join(parts)
            return

        selected = ""

        if len(lines) == 1:
            selected = lines[0]

        else:
            print "Which one would you like to edit?"
            for i, line in enumerate(lines):
                print "   %s %s" % (i, line)

            num = vim.eval("input(':')")
            if num.isdigit() and int(num) < len(lines):
                selected = lines[int(num)]
            else:
                return

        vim.command("tabnew %s" % selected)
    except Exception, e:
        print e

PYTHON

function! DoVims(...)
    python _vims_internal(vim.eval("a:0"), vim.eval("a:000"))
endfunction

command! -nargs=+ Edit call DoVims(<f-args>)

let g:loaded_oedit = 1
