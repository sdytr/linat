(defmodule linat-httpc
  (export all))

(include-lib "linat/include/linat-options.lfe")

(defun make-headers (opts)
  (get-default-headers opts))

(defun make-opts-headers (rec)
  (make-headers (linat-util:rec->opts rec)))

(defun make-rec-headers (opts)
  (linat-util:opts->rec (make-headers opts)))

(defun get-default-headers (opts)
  `(#("Authorization" ,(++ "Bearer " (proplists:get_value 'token opts)))
    #("User-Agent" ,(linat-cfg:user-agent))))

(defun make-uri
  ((section opts) (when (is_atom section))
   (make-uri (atom_to_list section) opts))
  ((section opts)
   (++ (linat-cfg:host) ; should move to linat-opts record
       section
       (make-extension opts))))

(defun make-extension (opts)
  (++ "." (atom_to_list (get-format opts))))

(defun get-format
  ((opts) (when (is_tuple opts))
   (get-format (linat-util:api-rec->opts opts)))
  ((opts)
    (proplists:get_value
      'format
      opts
      (proplists:get_value 'format (linat:get-state)))))

(defun parse-results
  ((args opts result) (when (is_list opts))
   (parse-results args (linat-util:opts->api-rec opts) result))
  ((args opts `#(ok #(,sts ,hdrs ,bdy)))
   (dispatch-parse (api-opts-format opts) sts hdrs bdy))
  ((_ _ (= `#(error ,_) err))
   err)
  ((_ _ all)
   all))

(defun dispatch-parse
  (('json status headers body)
    `#(ok ,(parse-json body)))
  (('csv status headers body)
    (parse-csv body))
  ((_ status headers body)
   `#(ok ,(list status headers body))))

(defun parse-json (results)
  (ljson:decode results))

(defun parse-csv (results)
  (car (io_lib:format "~ts" `(,results))))

