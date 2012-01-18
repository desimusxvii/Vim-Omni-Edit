" ============================================================================
" File:		oedit.vim
" Description: Opens files anywhere on the system for editing
" Author:	  David Zuercher <david.zerker@gmail.com>
" Licence:	 Vim license
" Website:	 ...
" Version:	 1.1
"
"			  Permission is hereby granted to use and distribute this code,
"			  with or without modifications, provided that this copyright
"			  notice is copied with it. Like anything else that's free,
"			  taglist.vim is provided *as is* and comes with no warranty of
"			  any kind, either expressed or implied. In no event will the
"			  copyright holder be liable for any damages resulting from the
"			  use of this software.
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
import vim, sys, random
from subprocess import *

def _vims_internal(num, parts):
	try:
		while True:
			parts.sort(key=lambda item: (item.startswith('-'), -len(item)))

			lines = []
			for part in parts:
				if not part.startswith('-'):
					if part.startswith('~'):
						part = "-i %s" % part[1:]
					p = Popen("locate -l 100 %s" % part, shell=True, stderr=PIPE, stdout=PIPE, stdin=PIPE)
					p.wait()
					lines = p.stdout.read().strip().split('\n')
					lines = filter(lambda s: not s.endswith('.svn'), lines)
					lines = filter(lambda s: not s.endswith('.swp'), lines)
					if len(lines) < 100:
						break
				else:
					print "Inclusive criteria is too general. Please be more specific!"
					# TODO.. get more input here..
					return

			for piece in parts:
				if piece.startswith('-'):
					lines = filter(lambda s: piece[1:] not in s, lines)
				elif piece.startswith('~'):
					lines = filter(lambda s: piece[1:].lower() in s.lower(), lines)
				else:
					lines = filter(lambda s: piece in s, lines)

			if len(lines) > 30:
				print "Too many matching files.. :"
				print "	", "\n	".join(random.sample(lines, 10))
				print "Please add more criteria:"

			elif len(lines) == 0:
				print "No matching files.."
				print "Please edit your criteria:"
			else:
				break

			new_criteria = vim.eval("input(':', '%s')" % " ".join(parts)).split()
			if new_criteria:
				parts = new_criteria
			else:
				return

		if len(lines) == 0:
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

		vim.command("tabnew %s" % selected.replace(' ', '\\ '))
	except Exception, e:
		print e

PYTHON

function! DoVims(...)
	python _vims_internal(vim.eval("a:0"), vim.eval("a:000"))
endfunction

command! -nargs=+ Edit call DoVims(<f-args>)

let g:loaded_oedit = 1
