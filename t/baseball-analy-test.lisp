(in-package :cl-user)
(defpackage baseball-analy-test
  (:use :cl :prove :baseball-analy))
(in-package #:baseball-analy-test)

(defvar *test-file* "sample.csv")

(plan 1)
(subtest "単体のcsvファイルの保存テスト"
  (if (probe-file *test-file*)
	  (delete-file (probe-file *test-file*)))
  (baseball-analy:save-csv *test-file*
						   (baseball-analy:create-baseball-page-parse-tree "1" "b"))
  (isnt nil (probe-file *test-file*))
  (with-open-file (in *test-file* :direction :input)
	(if (< 1000 (file-length in))
		(ok "Probably not empty")
		(fail "file size is too small"))))
(delete-file (probe-file *test-file*))


(finalize)
