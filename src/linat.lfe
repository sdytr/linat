(defmodule linat
  (behaviour gen_server)
  (behaviour application)
  (export all))

(defun server-name ()  'linat-api-process)
(defun callback-module () 'linat-cb)

;;; Setup for the client state

(defun start ()
  (start_link))

(defun start (type args)
  (let ((result (linat-sup:start_link)))
    (case result
      (`#(ok ,pid)
        result)
      (_
       #(error result)))))

(defun stop (state)
  'ok)

(defun start_link ()
  (start-deps)
  (gen_server:start_link
    `#(local ,(server-name))
    (callback-module)
    '()
    '()))

(defun start-deps ()
  (++ `(#(logjam ,(logjam:start)))
      (loauth:start)
      `(#(gproc ,(application:start 'gproc))
        #(econfig ,(econfig:start))
        #(linat ok))))

;;; API

(defun get-observation (id)
  "Get a single observation by its id."
  (gen_server:call (server-name) `#(obs get #(id ,id))))

(defun get-observations ()
  "Get all observations in the system."
  (gen_server:call (server-name) #(obs get ())))

(defun get-observations (opts)
  "Get the observations associated with the provided options. Valid options
  include #(username ...) or #(project ...) for getting all a user's or a
  project's observations."
  (gen_server:call (server-name) `#(obs get ,opts)))


;;; Utility API

(defun get-state ()
  (gen_server:call (server-name) #(state)))

(defun get-token ()
  (gen_server:call (server-name) #(token)))