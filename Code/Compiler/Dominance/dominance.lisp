(in-package #:sicl-compiler-dominance)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Utilities.

;;; This function is not actually used in the function for computing
;;; dominators.
(defun depth-first-search-preorder (start-node successor-fun)
  (let ((table (make-hash-table :test #'eq))
	(result '()))
    (labels ((traverse (node)
	       (unless (gethash node table)
		 (setf (gethash node table) t)
		 (loop for succ in (funcall successor-fun node)
		       do (traverse succ))
		 (push node result))))
      (traverse start-node))
    result))

(defun count-nodes (start-node successor-fun)
  (length (depth-first-search-preorder start-node successor-fun)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Compute the immediate dominator of each node in an arbitrary
;;; flowgraph.
;;;
;;; This function is a very close implementation of the algorithm by
;;; Thomas Lengauer and Robert Endre Tarjan, as described in their
;;; paper "A Fast Algorithm for Finding Dominators in a Flowgraph",
;;; published in ACM Transactions on Programming Languages and
;;; Systems, Vol 1, No 1, July 1979, pages 121-141.
;;;
;;; It is close in that I even duplicated quirks such as using numbers
;;; instead of objects in some cases, and starting numbering by 1.  I
;;; also used the variable names of the paper, which makes the code a
;;; bit harder to follow by itself, but easier to verify against the
;;; paper.
;;;
;;; Although advertised as working on flowgraphs (i.e. a graph where
;;; the nodes are basic blocks), it works for any types of graph with
;;; similar characteristics, and in particular for flowchars (i.e., w
;;; graph where the nodes are individual instructions).  All that we
;;; require is that the nodes in the graph can be compared using EQ,
;;; and that a function is supplied that returns a list of successors
;;; for each node in the graph.
;;;
;;; We have tested this implementation on randomly generated graphs by
;;; comparing it to the result of a trivial algorithm for computing
;;; dominators (see below).

(defun immediate-dominators (start-node successor-fun)
  (let* ((pred (make-hash-table :test #'eq))
	 (parent (make-hash-table :test #'eq))
	 (vertex (make-array (count-nodes start-node successor-fun)))
	 (semi (make-hash-table :test #'eq))
	 (dom (make-hash-table :test #'eq))
	 (bucket (make-hash-table :test #'eq))
	 (label (make-hash-table :test #'eq))
	 (ancestor (make-hash-table :test #'eq))
	 (n 0))
    (flet ((successors (node)
	     (funcall successor-fun node))
	   (pred (node)
	     (gethash node pred))
	   ((setf pred) (new-pred node)
	     (setf (gethash node pred) new-pred))
	   (parent (node)
	     (gethash node parent))
	   ((setf parent) (new-parent node)
	     (setf (gethash node parent) new-parent))
	   (vertex (i)
	     (aref vertex (1- i)))
	   ((setf vertex) (new-vertex i)
	     (setf (aref vertex (1- i)) new-vertex))
	   (semi-default (node)
	     (gethash node semi 0))
	   (semi (node)
	     (multiple-value-bind (value present-p)
		 (gethash node semi)
	       (assert present-p)
	       value))
	   ((setf semi) (new-semi node)
	     (setf (gethash node semi) new-semi))
	   (dom (node)
	     (gethash node dom))
	   ((setf dom) (new-dom node)
	     (setf (gethash node dom) new-dom))
	   (bucket (node)
	     (gethash node bucket))
	   ((setf bucket) (new-bucket node)
	     (setf (gethash node bucket) new-bucket))
	   (label (node)
	     (multiple-value-bind (value present-p)
		 (gethash node label)
	       (assert present-p)
	       value))
	   ((setf label) (new-label node)
	     (setf (gethash node label) new-label))
	   (ancestor (node)
	     (multiple-value-bind (value present-p)
		 (gethash node ancestor)
	       (assert present-p)
	       value))
	   ((setf ancestor) (new-ancestor node)
	     (setf (gethash node ancestor) new-ancestor)))
      ;; Step 1
      (labels ((dfs (v)
		 (setf (semi v) (incf n))
		 (setf (vertex n) v)
		 (loop for w in (successors v)
		       do (when (zerop (semi-default w))
			    (setf (parent w) v)
			    (dfs w))
			  (push v (pred w)))))
	(dfs start-node))
      (labels ((evaluate (v)
		 (if (null (ancestor v))
		     v
		     (progn (compress v)
			    (label v))))
	       (compress (v)
		 (unless (null (ancestor (ancestor v)))
		   (compress (ancestor v))
		   (when (< (semi (label (ancestor v))) (semi (label v)))
		     (setf (label v) (label (ancestor v))))
		   (setf (ancestor v) (ancestor (ancestor v)))))
	       (link (v w)
		 (setf (ancestor w) v)))
	;; Step 2 and 3
	(loop for i from 1 to n
	      for v = (vertex i)
	      do (setf (ancestor v) nil)
		 (setf (label v) v))
	(loop for i downfrom n to 2
	      for w = (vertex i)
	      do (loop for v in (pred w)
		       for u = (evaluate v)
		       do (when (< (semi u) (semi w))
			    (setf (semi w) (semi u))))
		 (push w (bucket (vertex (semi w))))
		 (link (parent w) w)
		 (loop for v in (bucket (parent w))
		       do (setf (bucket (parent w))
				(remove v (bucket (parent w)) :test #'eq))
			  (let ((u (evaluate v)))
			    (setf (dom v)
				  (if (< (semi u) (semi v))
				      u
				      (parent w))))))
	(loop for i from 2 to n
	      for w = (vertex i)
	      do (unless (eq (dom w) (vertex (semi w)))
		   (setf (dom w) (dom (dom w))))))
      dom)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Compute the complete dominance tree.  
;;;
;;; We represent the complete dominance tree as a hash table with the
;;; nodes of the flowgraph as keys.  The value for a particular node
;;; is a list starting with the node itself, then the immediate
;;; dominator of the node, then the immediate dominator of the
;;; immediate dominator of the node, etc.  The last element of the
;;; list is always the root node of the flowgraph.
;;;
;;; By representing it this way, we can use the dominance tree to
;;; return all insteresting dominance relations.  By itself, a value
;;; in the table is a set of all dominators of a node.  The CADR of
;;; that list is the IMMEDIATE dominator of a node, The CDR of the
;;; list is the set of all STRICT dominators of the node. 

;;; From the point of view of client code, this function returns an
;;; opaque object to be used as an argument to the three dominator
;;; functions below.
(defun dominance-tree (start-node successor-fun)
  (let ((immediate-dominators (immediate-dominators start-node successor-fun))
	(dominators (make-hash-table :test #'eq)))
    (setf (gethash start-node dominators) (list start-node))
    (labels ((find-dominator-tree (node)
	       (or (gethash node dominators)
		   (setf (gethash node dominators)
			 (cons node (find-dominator-tree
				     (gethash node immediate-dominators)))))))
      (loop for node being each hash-key of immediate-dominators
	    do (find-dominator-tree node)))
    dominators))

(defun dominators (dominance-tree node)
  (gethash node dominance-tree))

(defun immediate-dominator (dominance-tree node)
  (cadr (gethash node dominance-tree)))

(defun strict-dominators (dominance-tree node)
  (cdr (gethash node dominance-tree)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Dominance frontiers.

(defun children (dominance-tree)
  (let ((result (make-hash-table :test #'eq)))
    (loop for node being each hash-key of dominance-tree
	  do (let ((idom (immediate-dominator dominance-tree node)))
	       (unless (null idom)
		 (push node (gethash idom result)))))
    result))
	       
;;; Given a flow chart or a flow graph, compute the dominance frontier
;;; for each node.  To client code, the object returned is opaque, and
;;; can be used to pass to the function DOMINANCE-FRONTIER.
(defun dominance-frontiers (start-node successor-fun)
  (let* ((dominance-tree (dominance-tree start-node successor-fun))
	 (children (children dominance-tree))
	 (result (make-hash-table :test #'eq)))
    (flet ((children (node)
	     (gethash node children))
	   (successors (node)
	     (funcall successor-fun node))
	   (df (node)
	     (gethash node result))
	   ((setf df) (new-df node)
	     (setf (gethash node result) new-df)))
      (labels
	  ((traverse (x)
	     (mapc #'traverse (children x))
	     (loop for y in (successors x)
		   do (unless (eq (immediate-dominator dominance-tree y)
				  x)
			(pushnew y (df x) :test #'eq)))
	     (loop for z in (children x)
		   do (loop for y in (df z)
			    do (unless (eq (immediate-dominator dominance-tree y)
					   x)
				 (pushnew y (df x) :test #'eq))))))
	(traverse start-node)))
    result))

(defun dominance-frontier (dominance-frontiers node)
  (gethash node dominance-frontiers))
