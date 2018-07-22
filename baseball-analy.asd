;; (require \'asdf)

(in-package :cl-user)
(defpackage baseball-analy-asd
  (:use :cl :asdf))
(in-package :baseball-analy-asd)

(defsystem :baseball-analy
  :version "1.0.0"
  :author "wasu"
  :license "MIT"
  :components ((:file "package")
			   (:module "src" :components ((:file "baseball-analy")))))
