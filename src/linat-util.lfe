(defmodule linat-util
  (export all))

(defun get-version ()
  (lutil:get-app-version 'linat))

(defun get-versions ()
  (++ (lutil:get-versions)
      `(#(linat ,(get-version)))))
