(defmodule linat-auth
  (export all))

(include-lib "loauth/include/loauth.lfe")

(defun token-path () "/oauth/token")

(defun get-token ()
  (linat:start)
  (loauth:get-token
    (linat-cfg:get-user)
    (linat-cfg:get-pass)
    (make-state)))

(defun make-state ()
  (make-loauth-data
    token-uri (++ (linat-cfg:get-host) (token-path))
    client-id (linat-cfg:get-app-id)
    client-secret (linat-cfg:get-secret)))
