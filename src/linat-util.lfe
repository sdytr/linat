(defmodule linat-util
  (export all))

(defun get-version ()
  (lutil:get-app-version 'linat))

(defun get-versions ()
  (++ (lutil:get-versions)
      `(#(linat ,(get-version)))))

(defun arg->str
  ((arg) (when (is_integer arg))
   (arg->str (integer_to_list arg)))
  ((arg) (when (is_atom arg))
   (arg->str (atom_to_list arg)))
  ((arg) arg))

(defun ->atom
  ((x) (when (is_list x))
   (list_to_atom x))
  ((x) (when (is_integer x))
   (list_to_atom (integer_to_list x)))
  ((x) x))

(defun get-defined
  ;; undefined OS env values will match false
  (((cons 'false rest))
   (get-defined rest))
  ;; undefined INI values will match undefined
  (((cons 'undefined rest))
   (get-defined rest))
  (((cons match _))
   match))

(defun ->int
  ((str) (when (is_list str))
   (list_to_integer str))
  ((x)
   x))

(defun rdecons (list)
  "Reverse de-cons function: instead of head/tail, it returns
  all-but-last/last."
  (let ((`#(,all-but-last ,last) (lists:split (- (length list) 1) list)))
    (list all-but-last (car last))))

(defun rcar (list)
  "Returns the last element."
  (let ((`(,_ ,last) (rdecons list)))
    last))

(defun rcdr (list)
  "Returns all but the last element."
  (let ((`(,all-but-last ,_) (rdecons list)))
    all-but-last))