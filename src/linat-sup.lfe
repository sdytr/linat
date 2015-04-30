(defmodule linat-sup
  (behaviour supervisor)
  (export all))

(defun server-name ()
  'linat-supervisor)

(defun start_link ()
  (supervisor:start_link
    `#(local ,(server-name)) (MODULE) '()))

(defun init (args)
  (let* ((server #(,(linat:server-bame)
                   #(linat-server start_link ())
                   permanent
                   2000
                   worker
                   ,(linat:server-name)))
         (children `(,server))
         (restart-strategy #(one_for_one 3 1)))
    `#(ok #(restart-strategy ,children))))
