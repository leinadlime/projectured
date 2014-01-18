;;; -*- mode: Lisp; Syntax: Common-Lisp; -*-
;;;
;;; Copyright (c) 2009 by the authors.
;;;
;;; See LICENCE for details.

(in-package :projectured)

;;;;;;
;;; Projection

(def projection word-wrapping ()
  ((wrap-width :type number)))

;;;;;;
;;; Construction

(def (function e) make-projection/word-wrapping (&key wrap-width)
  (make-projection 'word-wrapping :wrap-width wrap-width))

;;;;;;
;;; Construction

(def (macro e) word-wrapping (&key wrap-width)
  `(make-projection/word-wrapping :wrap-width ,wrap-width))

;;;;;;
;;; IO map

(def iomap iomap/word-wrapping (iomap)
  ((newline-insertion-indices :type sequence)))

;;;;;;
;;; Printer

(def printer word-wrapping (projection recursion input input-reference)
  (declare (ignore input-reference))
  (bind ((newline-insertion-indices nil)
         (elements (iter (with x = 0)
                         (with output-character-index = 0)
                         (with elements = (elements-of input))
                         (with wrap-width = (wrap-width-of projection))
                         (for (values start-element-index start-character-index)
                              :initially (values 0 0)
                              :then (text/find input end-element-index end-character-index (lambda (c) (not (whitespace? c)))))
                         (for whitespace-elements = (unless (first-iteration-p)
                                                      (elements-of (text/substring input end-element-index end-character-index start-element-index start-character-index))))
                         (for whitespace-width = (iter (with sum = 0) (for element :in-sequence whitespace-elements)
                                                       (typecase element
                                                         (text/string
                                                          (when (find #\NewLine (content-of element))
                                                            (setf x 0)
                                                            (setf sum 0))
                                                          (incf sum (2d-x (measure-text (content-of element) (font-of element)))))
                                                         (t
                                                          ;; KLUDGE:
                                                          (incf sum 100)))
                                                       (finally (return sum))))
                         (incf x whitespace-width)
                         (incf output-character-index (text/length (make-text/text whitespace-elements)))
                         ;; TODO: just append the vector
                         (appending (coerce whitespace-elements 'list))
                         (until (and (= start-element-index (length elements))
                                     (= start-character-index 0)))
                         (for (values end-element-index end-character-index) = (text/find input start-element-index start-character-index 'whitespace?))
                         (for word-elements = (elements-of (text/substring input start-element-index start-character-index end-element-index end-character-index)))
                         (for word-width = (iter (for element :in-sequence word-elements)
                                                 (summing
                                                  (typecase element
                                                    (text/string (2d-x (measure-text (content-of element) (font-of element))))
                                                    ;; KLUDGE:
                                                    (t 100)))))
                         (incf x word-width)
                         (when (> x wrap-width)
                           (setf x word-width)
                           (push output-character-index newline-insertion-indices)
                           (incf output-character-index)
                           (collect (make-text/string (string #\NewLine) :font *font/default* :font-color *color/default*)))
                         (incf output-character-index (text/length (make-text/text word-elements)))
                         ;; TODO: just append the vector
                         (appending (coerce word-elements 'list))
                         (until (and (= end-element-index (length elements))
                                     (= end-character-index 0)))))
         (output-selection (pattern-case (selection-of input)
                             (((the sequence-position (text/pos (the text/text document) ?character-index)))
                              (bind ((newline-count (count-if (lambda (index) (< index ?character-index)) newline-insertion-indices)))
                                `((the sequence-position (text/pos (the text/text document) ,(+ ?character-index newline-count))))))))
         (output (make-text/text elements :selection output-selection)))
    (make-iomap 'iomap/word-wrapping
                :projection projection :recursion recursion
                :input input :output output
                :newline-insertion-indices (nreverse newline-insertion-indices))))

;;;;;;
;;; Reader

(def reader word-wrapping (projection recursion projection-iomap gesture-queue operation)
  (declare (ignore projection recursion gesture-queue))
  (labels ((recurse (operation)
             (typecase operation
               (operation/quit operation)
               (operation/replace-selection
                (make-operation/replace-selection (input-of projection-iomap)
                                                  (pattern-case (selection-of operation)
                                                    (((the sequence-position (text/pos (the text/text document) ?character-index)))
                                                     (bind ((newline-count (count-if (lambda (index) (< index ?character-index)) (newline-insertion-indices-of projection-iomap))))
                                                       `((the sequence-position (text/pos (the text/text document) ,(- ?character-index newline-count)))))))))
               (operation/sequence/replace-element-range
                (make-operation/sequence/replace-element-range (input-of projection-iomap)
                                                               (pattern-case (target-of operation)
                                                                 (((the sequence-position (text/pos (the text/text document) ?character-index)))
                                                                  (bind ((newline-count (count-if (lambda (index) (< index ?character-index)) (newline-insertion-indices-of projection-iomap))))
                                                                    `((the sequence-position (text/pos (the text/text document) ,(- ?character-index newline-count)))))))
                                                               (replacement-of operation)))
               (operation/compound
                (bind ((operations (mapcar #'recurse (elements-of operation))))
                  (unless (some 'null operations)
                    (make-operation/compound operations)))))))
    (recurse operation)))