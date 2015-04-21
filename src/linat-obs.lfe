(defmodule linat-obs
  (export all))

(defun get (options)
  (lhc:get (linat-httpc:make-uri 'observations 'json)
           (linat-httpc:get-default-headers
             (proplists:get_value 'token options))
           `(#(callback ,#'linat-httpc:parse-json/3))))