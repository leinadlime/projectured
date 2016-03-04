;;; -*- mode: Lisp; Syntax: Common-Lisp; -*-
;;;
;;; Copyright (c) by the authors.
;;;
;;; See LICENCE for details.

(in-package :projectured)

;;;;;;
;;; Projection

(def projection primitive/boolean->text/text ()
  ())

(def projection primitive/number->text/text ()
  ())

(def projection primitive/string->text/text ()
  ())

;;;;;;
;;; Construction

(def function make-projection/primitive/boolean->text/text ()
  (make-projection 'primitive/boolean->text/text))

(def function make-projection/primitive/number->text/text ()
  (make-projection 'primitive/number->text/text))

(def function make-projection/primitive/string->text/text ()
  (make-projection 'primitive/string->text/text))

;;;;;;
;;; Construction

(def macro primitive/boolean->text/text ()
  `(make-projection/primitive/boolean->text/text))

(def macro primitive/number->text/text ()
  `(make-projection/primitive/number->text/text))

(def macro primitive/string->text/text ()
  `(make-projection/primitive/string->text/text))

;;;;;;
;;; Forward mapper

(def forward-mapper primitive/number->text/text ()
  (pattern-case -reference-
    (((the primitive/number document))
     '((the string document)))
    (((the number (value-of (the primitive/number document)))
      (the string (write-to-string (the number document)))
      (the string (subseq (the string document) ?start-index ?end-index)))
     `((the text/text (text/subseq (the text/text document) ,?start-index ,?end-index))))
    (((the string (printer-output (the primitive/number document) ?projection ?recursion)) . ?rest)
     (when (eq -projection- ?projection)
       ?rest))))

;;;;;;
;;; Backward mapper

(def backward-mapper primitive/number->text/text ()
  (pattern-case -reference-
    (((the string document))
     '((the primitive/number document)))
    (((the text/text (text/subseq (the text/text document) ?start-index ?end-index)))
     `((the number (value-of (the primitive/number document)))
       (the string (write-to-string (the number document)))
       (the string (subseq (the string document) ,?start-index ,?end-index))))
    (?a
     (append `((the string (printer-output (the primitive/number document) ,-projection- ,-recursion-))) -reference-))))

;;;;;;
;;; Printer

(def printer primitive/boolean->text/text ()
  (bind ((output-selection (as (print-selection (make-iomap -projection- -recursion- -input- -input-reference- nil)
                                                (get-selection -input-)
                                                'forward-mapper/primitive/boolean->text/text)))
         (output (as (text/text (:selection output-selection)
                       (text/string (if (value-of -input-) "true" "false"))))))
    (make-iomap -projection- -recursion- -input- -input-reference- output)))

(def printer primitive/number->text/text ()
  (bind ((output-selection (as (print-selection (make-iomap -projection- -recursion- -input- -input-reference- nil)
                                                (get-selection -input-)
                                                'forward-mapper/primitive/number->text/text)))
         (output (as (text/text (:selection output-selection)
                       (text/string (write-to-string (value-of -input-)))))))
    (make-iomap -projection- -recursion- -input- -input-reference- output)))

(def printer primitive/string->text/text ()
  (bind ((output-selection (as (print-selection (make-iomap -projection- -recursion- -input- -input-reference- nil)
                                                (get-selection -input-)
                                                'forward-mapper/primitive/number->text/text)))
         (output (as (text/text (:selection output-selection)
                       (text/string (value-of -input-))))))
    (make-iomap -projection- -recursion- -input- -input-reference- output)))

;;;;;;
;;; Reader

(def reader primitive/boolean->text/text ()
  (merge-commands (command/read-backward -recursion- -input- -printer-iomap- 'backward-mapper/primitive/boolean->text/text nil)
                  (make-nothing-command -gesture-)))

(def reader primitive/number->text/text ()
  (bind ((operation-mapper (lambda (operation selection child-selection child-iomap)
                             (declare (ignore child-selection child-iomap))
                             (typecase operation
                               (operation/text/replace-range
                                (pattern-case selection
                                  (((the number (value-of (the primitive/number document)))
                                    (the string (write-to-string (the number document)))
                                    (the string (subseq (the string document) ?start-index ?end-index)))
                                   (when (every 'digit-char-p (replacement-of operation))
                                     (make-operation/number/replace-range -printer-input- selection (replacement-of operation))))
                                  (((the number (printer-output (the primitive/number document) ?projection ?recursion)) . ?rest)
                                   (when (every 'digit-char-p (replacement-of operation))
                                     (make-operation/number/replace-range -printer-input-
                                                                          '((the number (value-of (the primitive/number document)))
                                                                            (the string (write-to-string (the number document)))
                                                                            (the string (subseq (the string document) 0 0)))
                                                                          (replacement-of operation))))))))))
    (merge-commands (command/read-backward -recursion- -input- -printer-iomap- 'backward-mapper/primitive/number->text/text operation-mapper)
                    (make-nothing-command -gesture-))))

(def reader primitive/string->text/text ()
  (merge-commands (command/read-backward -recursion- -input- -printer-iomap- 'backward-mapper/primitive/string->text/text nil)
                  (make-nothing-command -gesture-)))
