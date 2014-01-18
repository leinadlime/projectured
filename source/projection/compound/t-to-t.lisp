;;; -*- mode: Lisp; Syntax: Common-Lisp; -*-
;;;
;;; Copyright (c) 2009 by the authors.
;;;
;;; See LICENCE for details.

(in-package :projectured)

;;;;;;
;;; Widget

(def (function e) make-projection/widget->graphics ()
  (type-dispatching
    (widget/label (make-projection/widget/label->graphics/canvas))
    (widget/tooltip (make-projection/widget/tooltip->graphics/canvas))
    (widget/menu (make-projection/widget/menu->graphics/canvas))
    (widget/menu-item (make-projection/widget/menu-item->graphics/canvas))
    (widget/shell (make-projection/widget/shell->graphics/canvas))
    (widget/composite (make-projection/widget/composite->graphics/canvas))
    (widget/split-pane (make-projection/widget/split-pane->graphics/canvas))
    (widget/tabbed-pane (make-projection/widget/tabbed-pane->graphics/canvas))
    (widget/scroll-pane (make-projection/widget/scroll-pane->graphics/canvas))))

(def (macro e) widget->graphics ()
  '(make-projection/widget->graphics))

;;;;;;
;;; Book

(def (function e) make-projection/book->tree ()
  (type-dispatching
    (book/book (make-projection/book/book->tree/node))
    (book/chapter (make-projection/book/chapter->tree/node))))

(def (macro e) book->tree ()
  '(make-projection/book->tree))

;;;;;;
;;; Text

(def (function e) make-projection/text->tree ()
  (type-dispatching
    (string (make-projection/string->tree/leaf))
    (text/string (make-projection/text/string->tree/leaf))
    (text/text (make-projection/text/text->tree/node))))

(def (macro e) text->tree ()
  '(make-projection/text->tree))

;;;;;;
;;; Tree

(def (function e) make-projection/tree->text ()
  (type-dispatching
    (tree/leaf (tree/leaf->text/text))
    (tree/node (tree/node->text/text))))

(def (macro e) tree->text ()
  `(make-projection/tree->text))

;;;;;;
;;; Graph

(def (function e) make-projection/graph->tree ()
  (type-dispatching
    ))

(def (macro e) graph->tree ()
  '(make-projection/graph->tree))

;;;;;;
;;; Statae machine

(def (function e) make-projection/state-machine->tree ()
  (type-dispatching
    (state-machine/state-machine (make-projection/state-machine/state-machine->tree/node))
    (state-machine/state (make-projection/state-machine/state->tree/node))
    (state-machine/transition (make-projection/state-machine/transition->tree/node))))

(def (macro e) state-machine->tree ()
  '(make-projection/state-machine->tree))

;;;;;;
;;; List

(def (function e) make-projection/list->text ()
  (make-projection/list/list->text))

(def (macro e) list->text ()
  '(make-projection/list->text))

;;;;;;
;;; Table

(def (function e) make-projection/table->text ()
  (make-projection/table/table->text))

(def (macro e) table->text ()
  '(make-projection/table->text))

;;;;;;
;;; Inspector

(def (function e) make-projection/inspector->table ()
  (type-dispatching
    (inspector/object (make-projection/inspector/object->table/table))
    (inspector/object-slot (make-projection/inspector/object-slot->table/row))))

(def (macro e) inspector->table ()
  '(make-projection/inspector->table))

;;;;;;
;;; T

(def (function e) make-projection/t->table ()
  (type-dispatching
    (null (make-projection/t/null->text/text))
    (number (make-projection/t/number->text/text))
    (string (make-projection/t/string->text/text))
    (symbol (make-projection/t/symbol->text/text))
    (sequence (make-projection/t/sequence->table/table))
    (hash-table (make-projection/t/hash-table->table/table))
    (function (make-projection/t/function->table/table))
    ((or structure-object standard-object) (make-projection/t/object->table/table))))

(def (macro e) t->table ()
  '(make-projection/t->table))

;;;;;;
;;; XML

(def (function e) make-projection/xml->tree ()
  (type-dispatching
    (xml/text (make-projection/xml/text->tree/leaf))
    (xml/attribute (make-projection/xml/attribute->tree/node))
    (xml/element (make-projection/xml/element->tree/node))))

(def (macro e) xml->tree ()
  '(make-projection/xml->tree))

;;;;;;
;;; JSON

(def (function e) make-projection/json->tree ()
  (type-dispatching
    (json/nothing (make-projection/json/nothing->tree/leaf))
    (json/null (make-projection/json/null->tree/leaf))
    (json/boolean (make-projection/json/boolean->tree/leaf))
    (json/number (make-projection/json/number->tree/leaf))
    (json/string (make-projection/json/string->tree/leaf))
    (json/array (make-projection/json/array->tree/node))
    (json/object-entry (make-projection/json/object-entry->tree/node))
    (json/object (make-projection/json/object->tree/node))))

(def (macro e) json->tree ()
  '(make-projection/json->tree))

;;;;;;
;;; File system

(def (function e) make-projection/file-system->tree ()
  (type-dispatching
    (file-system/file (make-projection/file-system/file->tree/leaf))
    (file-system/directory (make-projection/file-system/directory->tree/node))))

(def (macro e) file-system->tree ()
  '(make-projection/file-system->tree))

;;;;;;
;;; Java

(def (function e) make-projection/java->tree ()
  (type-dispatching
    (java/statement/block (make-projection/java/statement/block->tree/node))
    (java/statement/if (make-projection/java/statement/if->tree/node))
    (java/statement/return (make-projection/java/statement/return->tree/node))
    (java/expression/variable-reference (make-projection/java/expression/variable-reference->string))
    (java/expression/method-invocation (make-projection/java/expression/method-invocation->tree/node))
    (java/expression/infix-operator (make-projection/java/expression/infix-operator->tree/node))
    (java/literal/null (make-projection/java/literal/null->string))
    (java/literal/number (make-projection/java/literal/number->string))
    (java/literal/character (make-projection/java/literal/character->string))
    (java/literal/string (make-projection/java/literal/string->string))
    (java/declaration/method (make-projection/java/declaration/method->tree/node))
    (java/declaration/argument (make-projection/java/declaration/argument->tree/node))
    (java/declaration/qualifier (make-projection/java/declaration/qualifier->string))
    (java/declaration/type (make-projection/java/declaration/type->string))))

(def (macro e) java->tree ()
  '(make-projection/java->tree))

;;;;;;
;;; Javascript

(def (function e) make-projection/javascript->tree ()
  (type-dispatching
    (javascript/statement/block (make-projection/javascript/statement/block->tree/node))
    (javascript/statement/top-level (make-projection/javascript/statement/top-level->tree/node))
    (javascript/expression/variable-reference (make-projection/javascript/expression/variable-reference->tree/leaf))
    (javascript/expression/property-access (make-projection/javascript/expression/property-access->tree/node))
    (javascript/expression/constructor-invocation (make-projection/javascript/expression/constructor-invocation->tree/node))
    (javascript/expression/method-invocation (make-projection/javascript/expression/method-invocation->tree/node))
    (javascript/literal/string (make-projection/javascript/literal/string->tree/leaf))
    (javascript/declaration/variable (make-projection/javascript/declaration/variable->tree/node))
    (javascript/declaration/function (make-projection/javascript/declaration/function->tree/node))))

(def (macro e) javascript->tree ()
  '(make-projection/javascript->tree))

;;;;;;
;;; Lisp form

(def (function e) make-projection/lisp-form->tree ()
  (type-dispatching
    (lisp-form/comment (make-projection/lisp-form/comment->string))
    (lisp-form/number (make-projection/lisp-form/number->string))
    (lisp-form/symbol (make-projection/lisp-form/symbol->string))
    (lisp-form/string (make-projection/lisp-form/string->string))
    (lisp-form/list (make-projection/lisp-form/list->tree/node))
    (lisp-form/object (make-projection/lisp-form/object->string))
    (lisp-form/top-level (make-projection/lisp-form/top-level->tree/node))))

(def (macro e) lisp-form->tree ()
  '(make-projection/lisp-form->tree))

;;;;;;
;;; Common lisp

(def (function e) make-projection/common-lisp->lisp-form ()
  (type-dispatching
    (common-lisp/constant (make-projection/common-lisp/constant-form->lisp-form/string))
    (common-lisp/variable-reference (make-projection/common-lisp/variable-reference-form->lisp-form/string))
    (common-lisp/if (make-projection/common-lisp/if-form->lisp-form/list))
    (common-lisp/the (make-projection/common-lisp/the-form->lisp-form/list))
    (common-lisp/progn (make-projection/common-lisp/progn-form->lisp-form/list))
    (common-lisp/lexical-variable-binding (make-projection/common-lisp/lexical-variable-binding-form->lisp-form/list))
    (common-lisp/let (make-projection/common-lisp/let-form->lisp-form/list))
    (common-lisp/application (make-projection/common-lisp/application-form->lisp-form/list))
    (common-lisp/function-definition (make-projection/common-lisp/function-definition-form->lisp-form/list))
    (common-lisp/lambda-function (make-projection/common-lisp/lambda-function-form->lisp-form/list))
    (common-lisp/function-argument (make-projection/common-lisp/function-argument-form->lisp-form/string))
    (common-lisp/comment (make-projection/common-lisp/comment->lisp-form/comment))
    (common-lisp/top-level (make-projection/common-lisp/top-level->lisp-form/top-level))))

(def (macro e) common-lisp->lisp-form ()
  '(make-projection/common-lisp->lisp-form))