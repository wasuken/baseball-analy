(in-package :cl-user)
(defpackage baseball-analy-test
  (:use :cl :prove :baseball-analy))
(in-package #:baseball-analy-test)

(defvar *test-file* "sample.csv")

(plan 2)
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

(subtest "CSV操作系テスト"
  (diag "csv一行ごとに検索をかける。")
  (like (baseball-analy:line-search "寺内 崇幸") "寺内 崇幸")
  (subtest "打率トップ10の選手レコードの選手名と打率を取得する。"
	(diag "入力した文字列と一致するCSVのヘッダが存在するかどうか")
	(diag "")
	(diag "すべて選手の打率を取得する")))

(finalize)
