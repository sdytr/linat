(defmodule linat
  (export all))

(defun start ()
  (++ (loauth:start)
      `(#(gproc ,(application:start 'gproc))
        #(econfig ,(econfig:start))
        #(linat ok))))
