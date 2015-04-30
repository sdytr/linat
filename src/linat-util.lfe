(defmodule linat-util
  (export all))

(include-lib "linat/include/linat-options.lfe")

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
  "Reverse (car): returns the last element."
  (let ((`(,_ ,last) (rdecons list)))
    last))

(defun rcdr (list)
  "Reverse (cdr): returns all but the last element."
  (let ((`(,all-but-last ,_) (rdecons list)))
    all-but-last))

(defun tcar (tuple)
  "(car) for tuples."
  (car (tuple_to_list tuple)))

(defun tcdr (tuple)
  "(cdr) for tuples."
  (cdr (tuple_to_list tuple)))

(defun linat-rec->opts (linat-opts-record)
  "This is not a general function, rather it is intended only to be used with
  linat-opts records."
  (lists:zip
    (fields-linat-opts)
    (tcdr linat-opts-record)))

(defun opts->linat-rec (linat-opts)
  "This is *totally* cheating, creating the record using the internal
  Erlang data structure to represent it (tuple). This will break if
  Erlang ever changes its representation of records."
  `#(linat-opts
     ,@(lists:map
        (lambda (x) (proplists:get_value x linat-opts))
        (fields-linat-opts))))

(defun api-rec->opts (api-opts-record)
  "This is not a general function, rather it is intended only to be used with
  api-opts records."
  (lists:zip
    (fields-api-opts)
    (tcdr api-opts-record)))

(defun opts->api-rec (api-opts)
  "This is *totally* cheating, creating the record using the internal
  Erlang data structure to represent it (tuple). This will break if
  Erlang ever changes its representation of records."
  `#(api-opts
     ,@(lists:map
        (lambda (x) (proplists:get_value x api-opts))
        (fields-api-opts))))