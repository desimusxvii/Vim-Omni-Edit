Description
===========
Use pieces of what you remember from the path/name of any file to open it.

Why? 
---- 
Laziness of course. You remember part of the file name, and vaguely where
it is located. This plugin will get it open faster than anything else.

How?
----
The plugin uses the 'locate' command and a series of greps to narrow the results.

Examples
========
    :Edit ~template fas -driv css

	If your list of options yields a single result it will be opened in a new tab. Multiple
	results be shown in a list.

	~ : Starting a token with tilde will cause a case-insensitive match.
	- : Starting a token with minus will exclude results that match.
    
 
Known Limitations
=================

  * Won't find the backup sqlite db on Windows, but it *should* run if you pass
    in the db name with --input.  (I haven't tested it, though...)

  * Assumes encoding of texts is 'utf-8'...and there's no way to change it.
    
  * Does not try to recover texts with photos.  Just skips past them.

License
=======
Vim License.  Copyright 2011 David Zuercher.
