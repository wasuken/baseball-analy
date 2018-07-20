(in-package :cl-user)
(defpackage baseball-analy-test
  (:use :cl :prove :baseball-analy))
(in-package #:baseball-analy-test)

(plan 1)
(subtest "get-and-save-csv"
  (if (probe-file "sample.csv")
	  (delete-file (probe-file "sample.csv")))
  (baseball-analy:save-csv "sample.csv"
						   (baseball-analy:create-baseball-page-parse-tree "1" "b"))
  (isnt nil (probe-file "sample.csv"))
  (with-open-file (in "sample.csv" :direction :input)
	(if (< 1000 (file-length in))
		(ok "Probably not empty")
		(fail "file size is too small"))))

(delete-file (probe-file "sample.csv"))
(finalize)
