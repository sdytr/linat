(defmodule linat-httpc
  (export all))

(include-lib "lhc/include/lhc-options.lfe")

(defun get-default-headers (token)
  `(#("Authorization" ,(++ "Bearer " token))
    #("User-Agent" ,(linat-cfg:user-agent))))

(defun make-uri (section format)
  (++ (linat-cfg:host)
      "/"
      (atom_to_list section)
      "."
      (atom_to_list format)))

(defun parse-json (args opts results)
  (ljson:decode
    (lhc:parse-results args opts results)))