;;;; Note: this code was derived from some conversations on the LFE
;;;; mail list about inheriting records.
(include-lib "lhc/include/lhc-options.lfe")

(eval-when-compile
  ;; This next function doesn't actually work yet -- not sure
  ;; how to quote functions
  (defun get-parent-fields-and-values ()
    (lists:map #'tuple_to_list/1
               (lists:zip
                 (fields-lhc-opts)
                 (cdr (tuple_to_list (make-lhc-opts))))))

  (defun get-parent-fields ()
    (fields-lhc-opts))

  ;; end eval-when-compile
  )

(defmacro inherit-record ()
  `(defrecord linat-opts
     token
     (format 'json)
     (log-level 'error)
     (endpoint 'true)
     ,@(get-parent-fields)))

(inherit-record)

(defrecord api-opts
  id
  username
  project
  format)
