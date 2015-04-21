;;;; Provide simple wrappers around the various ways in which one can obtain
;;;; configuration data.
;;;;
;;;; The code below assumes the following order of lookup:
;;;;  * First look in the system ENV
;;;;  * Then a standard config file
;;;;  * Failing that, use the value defined in this module
;;;;
(defmodule linat-cfg
  (export all))

(include-lib "lutil/include/compose.lfe")

;;; Default configuration values, used as a last resort

(defun host () "https://www.inaturalist.org")
(defun request-timeout () (* 10 1000)) ; in milliseconds
(defun config-file () "~/.inat/lfe.ini")
(defun config-id () 'linat-ini)
(defun config-section () "REST API")
(defun get-log-level ()
  (->> (lcfg-log:get-local-logging)
       (proplists:get_value 'options)
       (proplists:get_value 'lager_console_backend)))
(defun user-agent () (++ "LFE iNaturalist REST Client (lhc/Erlang)/"
                         (linat-util:get-version)
                         " (+http://github.com/"
                         (proplists:get_value 'github (lcfg-proj:get-repos))
                         ")"))

;;; General config functions

(defun get-host ()
  (linat-util:get-defined
    (list (os:getenv "INAT_HOST")
          (get-ini-value 'host)
          (host))))

(defun get-app-id ()
  (linat-util:get-defined
    (list (os:getenv "INAT_APP_ID")
          (get-ini-value 'api)
          'undefined)))

(defun get-secret ()
  (linat-util:get-defined
    (list (os:getenv "INAT_SECRET")
          (get-ini-value 'default-currency)
          'undefined)))

(defun get-user ()
  (linat-util:get-defined
    (list (os:getenv "INAT_USER")
          (get-ini-value 'user)
          'undefined)))

(defun get-pass ()
  (linat-util:get-defined
    (list (os:getenv "INAT_PASS")
          (get-ini-value 'pass)
          'undefined)))

(defun get-request-timeout ()
  (linat-util:get-defined
    (list (linat-util:->int (os:getenv "INAT_REQUEST_TIMEOUT"))
          (linat-util:->int (get-ini-value 'timeout))
          (request-timeout))))

;;; Config INI

(defun open-cfg-file ()
  (open-cfg-file (config-file)))

(defun open-cfg-file (filename)
  (econfig:register_config
    (config-id)
    (list (lutil-file:expand-home-dir filename))
    (list 'autoreload)))

(defun get-ini-value (key)
  (get-ini-value (config-section) key))

(defun get-ini-value (section key)
  (econfig:get_value (config-id) section key))
