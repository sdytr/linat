(defmodule linat-obs
  (export all))

(include-lib "linat/include/linat-options.lfe")

(defun get
  (((= (match-api-opts id obs-id) opts)) (when (=/= obs-id 'undefined))
   (get-by-id (integer_to_list obs-id) (linat-util:api-rec->opts opts)))
  (((= (match-api-opts username user) opts)) (when (=/= user 'undefined))
   (get-by-id user (linat-util:api-rec->opts opts)))
  (((= (match-api-opts project proj) opts)) (when (=/= proj 'undefined))
   (get-by-project (integer_to_list proj) (linat-util:api-rec->opts opts)))
  ((opts)
   (lager:debug (MODULE)
                'get/1
                "options ~p~n"
                (list (linat-util:api-rec->opts opts)))
   (get-all (linat-util:api-rec->opts opts))))

(defun get-all (api-opts)
  (let ((linat-opts (linat:get-state)))
    (logjam:debug (MODULE)
                  'get-all/1
                  "api-opts: ~p~nlinat-opts: ~p~n"
                  (list api-opts linat-opts))
    (lhc:get (linat-httpc:make-uri "/observations" api-opts)
             (linat-httpc:make-headers linat-opts)
             linat-opts)))

(defun get-by-id (obs-id api-opts)
  (let ((linat-opts (linat:get-state)))
    (lhc:get (linat-httpc:make-uri
               (++ "/observations/" obs-id)
               api-opts)
             (linat-httpc:make-headers linat-opts)
             linat-opts)))

(defun get-by-project (proj-id api-opts)
  (let ((linat-opts (linat:get-state)))
    (lhc:get (linat-httpc:make-uri
               (++ "/observations/project" proj-id)
               api-opts)
             (linat-httpc:make-headers linat-opts)
             linat-opts)))