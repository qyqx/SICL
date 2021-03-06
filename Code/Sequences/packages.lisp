(defpackage #:sicl-sequences-common
    (:use #:cl)
  (:export #:name-mixin
	   #:name
	   #:in-sequence
	   #:end-index
	   #:must-be-nonnegative-integer
	   #:must-be-sequence
	   #:must-be-cons
	   #:must-be-list
	   #:must-be-proper-list
	   #:both-test-and-test-not-given
	   #:warn-both-test-and-test-not-given
	   #:invalid-sequence-index-type
	   #:invalid-start-index-type
	   #:invalid-end-index-type
	   #:invalid-sequence-index
	   #:invalid-bounding-index
	   #:invalid-start-index
	   #:invalid-end-index
	   #:end-less-than-start))

;;; The symbols that are shadowed from the COMMON-LISP package
;;; are also symbols that we want to export.  To avoid repeating 
;;; that list of symbols, we use the reader macros #= and ##. 
;;; It is interesting to note that we would normally write 
;;; (:shadow <string1> <string2> ...), but in order to put a 
;;; reader label on the list (<string1> <string2> ...) we need to
;;; express that as (:shadow . (<string1> <string2> ...)) instead. 
(defpackage #:sicl-sequences
    (:use #:cl #:sicl-sequences-common)
  (:shadow . #1=(#:find #:find-if #:find-if-not
                 #:position #:position-if #:position-if-not
                 #:length #:subseq
                 #:reduce
                 #:fill
		 #:remove #:remove-if #:remove-if-not
		 #:delete #:delete-if #:delete-if-not
		 #:count #:count-if #:count-if-not
		 #:substitute #:substitute-if #:substitute-if-not
		 #:nsubstitute #:nsubstitute-if #:nsubstitute-if-not
		 #:copy-seq #:elt
		 #:merge #:sort
		 #:mismatch
		 #:reverse #:nreverse
		 #:map #:map-into))
  (:export . #1#))

;;; In the test package, we want to import all symbols of the
;;; COMMON-LISP package, except the ones that were shadowed in
;;; the package that we are testing.  We do that by programatically
;;; getting the list of those symbols using the function 
;;; package-shadowing symbols.  But since defpackage doesn't evaluate
;;; the symbols in the :shadowing-import-from list, we need to 
;;; have the reader produce that list, hence the use of the #. reader
;;; macro and again of the consing dot followed by a list. 
(defpackage #:sicl-sequences-test
    (:shadowing-import-from #:sicl-sequences .
                            #.(package-shadowing-symbols '#:sicl-sequences))
    (:use #:sicl-sequences #:cl #:lisp-unit))

;;; The `tiny' package is identical to the ordinary sequences package,
;;; but it needs a different name because they might be both
;;; loaded into an image, for instance when we test functions
;;; in the ordinary package against functions in the `tiny' package. 
(defpackage #:sicl-sequences-tiny
    (:use #:cl #:sicl-sequences-common)
  (:shadow . #1=(#:find #:find-if #:find-if-not
                 #:position #:position-if #:position-if-not
                 #:length #:subseq
                 #:reduce
                 #:fill
		 #:remove #:remove-if #:remove-if-not
		 #:delete #:delete-if #:delete-if-not
		 #:count #:count-if #:count-if-not
		 #:substitute #:substitute-if #:substitute-if-not
		 #:nsubstitute #:nsubstitute-if #:nsubstitute-if-not
		 #:copy-seq #:elt
		 #:merge #:sort
		 #:mismatch
		 #:reverse #:nreverse
		 #:map #:map-into))
  (:export . #1#))

