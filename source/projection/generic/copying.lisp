;;; -*- mode: Lisp; Syntax: Common-Lisp; -*-
;;;
;;; Copyright (c) by the authors.
;;;
;;; See LICENCE for details.

(in-package :projectured)

;;;;;;
;;; Projection

(def projection copying ()
  ())

;;;;;;
;;; Construction

(def function make-projection/copying ()
  (make-projection 'copying))

;;;;;;
;;; Construction

(def macro copying ()
  '(make-projection/copying))

;;;;;;
;;; IO map

(def iomap iomap/copying ()
  ((slot-value-iomaps :type sequence)))

;;;;;;
;;; Forward mapper

(def forward-mapper copying ()
  (etypecase -printer-input-
    (number -reference-)
    (string -reference-)
    (sequence
     (pattern-case -reference-
       (((the ?type (elt (the sequence document) ?index)) . ?rest)
        (bind ((output-element (output-of (elt (child-iomaps-of -printer-iomap-) ?index))))
          (values `((the ,(document-type output-element) (elt (the sequence document) ,?index)))
                  ?rest
                  (elt (child-iomaps-of -printer-iomap-) ?index))))
       (?a -reference-)))
    (standard-object
     (pattern-case -reference-
       (((the ?type (?reader (the ?input-type document))) . ?rest)
        (bind ((class (class-of -printer-input-))
               (slots (remove-if (lambda (slot) (member (slot-definition-name slot) '(selection))) (class-slots class)))
               (slot-index (position ?reader slots :key (curry 'find-slot-reader class)))
               (slot-value-iomap (va (elt (slot-value-iomaps-of -printer-iomap-) slot-index))))
          ;; KLUDGE: workaround recursion for primitive types
          (if (typep (input-of slot-value-iomap) 'standard-object)
              (values (list (first -reference-)) ?rest slot-value-iomap)
              -reference-)))
       (?a -reference-)))))

;;;;;;
;;; Backward mapper

(def backward-mapper copying ()
  (etypecase -printer-input-
    (number -reference-)
    (string -reference-)
    (sequence
     (pattern-case -reference-
       (((the ?type (elt (the sequence document) ?index)) . ?rest)
        (bind ((input-element (input-of (elt (child-iomaps-of -printer-iomap-) ?index))))
          (values `((the ,(document-type input-element) (elt (the sequence document) ,?index)))
                  ?rest
                  (elt (child-iomaps-of -printer-iomap-) ?index))))
       (?a -reference-)))
    (standard-object
     (pattern-case -reference-
       (((the ?type (?reader (the ?input-type document))) . ?rest)
        (bind ((class (class-of -printer-input-))
               (slots (remove-if (lambda (slot) (member (slot-definition-name slot) '(selection))) (class-slots class)))
               (slot-index (position ?reader slots :key (curry 'find-slot-reader class)))
               (slot-value-iomap (va (elt (slot-value-iomaps-of -printer-iomap-) slot-index))))
          (values (list (first -reference-)) ?rest slot-value-iomap)))
       (?a -reference-)))))

;;;;;;
;;; Printer

(def printer copying ()
  (etypecase -input-
    ((and symbol (not null)) (make-iomap -projection- -recursion- -input- -input-reference- -input-))
    ((or number document/number) (make-iomap -projection- -recursion- -input- -input-reference- -input-))
    ((or string document/string) (make-iomap -projection- -recursion- -input- -input-reference- -input-))
    (pathname (make-iomap -projection- -recursion- -input- -input-reference- -input-))
    (style/color (make-iomap -projection- -recursion- -input- -input-reference- -input-))
    (style/font (make-iomap -projection- -recursion- -input- -input-reference- -input-))
    (sequence
     (bind ((element-iomaps (as (map-ll* (ll -input-) (lambda (element index)
                                                        (recurse-printer -recursion- (value-of element) `((elt (the sequence document) ,index)
                                                                                                          ,@(typed-reference (document-type -input-) -input-reference-)))))))
            (output-selection (as (print-selection (make-iomap/compound -projection- -recursion- -input- -input-reference- nil element-iomaps)
                                                   (selection-of -input-)
                                                   'forward-mapper/copying)))
            (output (as (etypecase -input-
                          (document/sequence ;; KLUDGE: typechecking fails in SBCL sequence/
                              (make-document/sequence (map-ll (va element-iomaps) 'output-of) :selection output-selection))
                          (sequence (map-ll (va element-iomaps) 'output-of))))))
       (make-iomap/compound -projection- -recursion- -input- -input-reference- output element-iomaps)))
    (standard-object
     (bind ((class (class-of -input-))
            (slots (remove-if (lambda (slot) (member (slot-definition-name slot) '(selection))) (class-slots class)))
            (slot-value-iomaps (as (iter (for slot :in slots)
                                         (collect (rebind (slot)
                                                    (as (when (slot-boundp-using-class class -input- slot)
                                                          (bind ((slot-reader (find-slot-reader class slot))
                                                                 (slot-value (slot-value-using-class class -input- slot)))
                                                            (recurse-printer -recursion- slot-value
                                                                             (if slot-reader
                                                                                 `((,slot-reader (the ,(document-type -input-) document))
                                                                                   ,@(typed-reference (document-type -input-) -input-reference-))
                                                                                 `((slot-value (the ,(document-type -input-) document) ',(slot-definition-name slot))
                                                                                   ,@(typed-reference (document-type -input-) -input-reference-))))))))))))
            (output-selection (as (print-selection (make-instance 'iomap/copying
                                                                  :projection -projection- :recursion -recursion-
                                                                  :input -input- :output nil
                                                                  :slot-value-iomaps slot-value-iomaps)
                                                   (selection-of -input-)
                                                   'forward-mapper/copying)))
            (output (as (prog1-bind clone (allocate-instance class)
                          (when (typep -input- 'document)
                            (setf (selection-of clone) output-selection #+nil(as (selection-of input))))
                          (iter (for slot :in slots)
                                (for slot-value-iomap :in (va slot-value-iomaps))
                                (rebind (slot-value-iomap)
                                  (setf (slot-value-using-class class clone slot)
                                        (if (typep slot 'computed-effective-slot-definition)
                                            (as (output-of (va slot-value-iomap)))
                                            (output-of (va slot-value-iomap))))))))))
       (make-instance 'iomap/copying
                      :projection -projection- :recursion -recursion-
                      :input -input- :output output
                      :slot-value-iomaps slot-value-iomaps)))))

;;;;;;
;;; Reader

(def reader copying ()
  (merge-commands (command/read-selection -recursion- -input- -printer-iomap- 'forward-mapper/copying 'backward-mapper/copying)
                  (command/read-backward -recursion- -input- -printer-iomap- 'backward-mapper/copying nil)
                  (make-nothing-command -gesture-)))
