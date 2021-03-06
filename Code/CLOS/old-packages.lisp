;; (defpackage #:sicl-clos-slot-definition
;;   (:shadow
;;    #:standard-class
;;    #:funcallable-standard-class)
;;   (:use #:common-lisp #:sicl-code-utilities)
;;   (:export
;;    #:slot-definition
;;    #:direct-slot-definition
;;    #:effective-slot-definition
;;    #:standard--slot-definition
;;    #:standard-direct-slot-definition
;;    #:standard-effective-slot-definition
;;    #:slot-definition-name
;;    #:slot-definition-allocation
;;    #:slot-definition-type
;;    #:slot-definition-initargs
;;    #:slot-definition-initform
;;    #:slot-definition-initfunction
;;    #:slot-definition-readers
;;    #:slot-definition-writers
;;    #:slot-definition-location
;;    #:make-direct-slot-definition
;;    #:make-effective-slot-definition
;;    #:compute-effective-slot-definition))

;; (defpackage #:sicl-clos-classes
;;   (:shadow
;;    #:class #:standard-class #:built-in-class #:structure-class
;;    #:standard-object #:function
;;    #:generic-function #:standard-generic-function
;;    #:method #:standard-method
;;    #:method-combination
;;    #:method-qualifiers #:find-class
;;    #:defclass
;;    #:class-name #:class-of)
;;   (:use #:common-lisp
;; 	#:sicl-code-utilities
;; 	#:sicl-clos-slot-definition))

;; (defpackage #:sicl-clos-generic-functions
;;   (:shadow
;;    #:generic-function #:standard-generic-function
;;    #:defgeneric #:ensure-generic-function
;;    #:method #:standard-method
;;    #:make-method #:add-method #:call-method #:find-method #:call-next-method
;;    #:method-qualifiers #:compute-applicable-methods #:next-method-p
;;    #:invalid-method-error
;;    #:no-applicable-method #:no-next-method #:remove-method #:defmethod
;;    #:initialize-instance #:shared-initialize #:reinitialize-instance
;;    #:make-instances-obsolete
;;    #:update-instance-for-different-class
;;    #:update-instance-for-redefined-class)
;;   (:use #:common-lisp
;; 	#:sicl-code-utilities
;; 	#:sicl-clos-slot-definition))

(defpackage #:sicl-clos
  (:shadow
   ;; MOP classes
   #:class #:standard-class #:built-in-class #:structure-class
   #:standard-object #:function
   #:generic-function #:standard-generic-function
   #:method #:standard-method
   #:method-combination
   #:slot-definition
   #:direct-slot-definition
   #:effective-slot-definition
   #:standard--slot-definition
   #:standard-direct-slot-definition
   #:standard-effective-slot-definition
   ;; Functions related to slot definitions.
   #:slot-definition-name
   #:slot-definition-allocation
   #:slot-definition-type
   #:slot-definition-initargs
   #:slot-definition-initform
   #:slot-definition-initfunction
   #:slot-definition-readers
   #:slot-definition-writers
   #:slot-definition-location
   #:make-direct-slot-definition
   #:make-effective-slot-definition
   #:compute-effective-slot-definition
   ;;
   #:defclass #:find-class
   #:class-name #:class-of
   #:allocate-instance #:make-instance
   #:initialize-instance #:shared-initialize #:reinitialize-instance
   #:make-instances-obsolete
   #:update-instance-for-different-class
   #:update-instance-for-redefined-class
   #:method #:standard-method
   #:make-method #:add-method #:call-method #:find-method #:call-next-method
   #:method-qualifiers #:compute-applicable-methods #:next-method-p
   #:invalid-method-error
   #:no-applicable-method #:no-next-method #:remove-method #:defmethod
   #:method-combination #:define-method-combination #:method-combination-error
   #:make-instance
   ;; Generic functions.
   #:generic-function #:standard-generic-function
   #:defgeneric #:ensure-generic-function
   #:slot-value #:slot-missing #:slot-boundp #:slot-makunbound
   #:print-object #:describe-object #:documentation)
  (:use #:common-lisp
	#:sicl-code-utilities
	#:sicl-additional-conditions)
  (:export))
