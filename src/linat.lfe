(defmodule linat
  (export all))

(defun start ()
  (++ `(#(logjam ,(logjam:start)))
      (loauth:start)
      `(#(gproc ,(application:start 'gproc))
        #(econfig ,(econfig:start))
        #(linat ok))))
