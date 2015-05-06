(defmodule linat-cb
  (export all))

(include-lib "linat/include/linat-options.lfe")

(defun init (args)
  `#(ok ,(make-linat-opts
           return 'all
           format 'json
           token (parse-token (linat-auth:get-token))
           callback #'linat-httpc:parse-results/3)))

(defun parse-token
  ((`#(ok ,token))
   token)
  ((error)
   #(bad-token error)))

(defun handle_call
  ((`#(obs get ,opts) caller state)
   `#(reply ,(linat-obs:get (linat-util:opts->api-rec opts))
            ,state))
  ((#(state) caller state)
   `#(reply ,(linat-util:linat-rec->opts state) ,state))
  ((#(token) caller state)
   `#(reply ,(linat-opts-token state) ,state))
  ((x caller state)
   #(reply #(error "No callback defined for that yet."))))

(defun terminate (reason state)
  `#(ok (#(reason ,reason) #(state ,state))))