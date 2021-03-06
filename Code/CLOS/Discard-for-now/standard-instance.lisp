(in-package #:sicl-clos)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; We follow the AMOP and define functions to allocate
;;; class instances and slot storage.  For now, these
;;; functions create other Common Lisp objects such as 
;;; structures and arrays.  In a real implementation, 
;;; these functions might use lower-level mechanisms
;;; to allocate these entities.

(defstruct standard-instance class slots)

(defun allocate-standard-instance (class slot-storage)
  (make-standard-instance :class class
			  :slots slot-storage))

(defun allocate-slot-storage (size initial-value)
  (make-array size :initial-element initial-value))

(defun slot-contents (slot-storage location)
  (aref slot-storage location))

(defun (setf slot-contents) (new-value slot-storage location)
  (setf (aref slot-storage location) new-value))

