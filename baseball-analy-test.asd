;; (require \'asdf)
 
 (in-package :cl-user)
 (defpackage baseball-analy-test-asd
 (:use :cl :asdf))
 (in-package :baseball-analy-test-asd)
 
 (defsystem baseball-analy-test
 :depends-on (:baseball-analy)
 :version "1.0.0"
 :author "wasu"
 :license "MIT"
 :components ((:module "t" :components ((:file "baseball-analy-test"))))
 :perform (test-op :after (op c)
 (funcall (intern #.(string :run) :prove) c)))

