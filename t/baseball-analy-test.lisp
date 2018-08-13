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
		(fail "file size is too small")))
  (delete-file (probe-file *test-file*)))

(subtest "CSV操作系テスト"
  (diag "csv一行ごとに検索をかける。")
  (like (car (baseball-analy:row-search "寺内 崇幸")) "寺内 崇幸")
  (diag "背番号18番の選手一覧")
  (like (car (baseball-analy:row-search "^1,18,")) "^1,18,")
  (subtest "その他テスト"
	(diag "入力した文字列と一致するCSVのヘッダが存在するかどうか")
	(is (mylib:read-file-to-first-line "data/1-b.csv")
		"team,背番号↑,選手,打率,試合,打席,打数,安打,二塁打,三塁打,本塁打,塁打,打点,得点,三振,四球,死球,犠打,犠飛,盗塁,盗塁死,併殺打,出塁率,長打率,OPS,得点圏,失策"))
  (subtest "csv列追加テスト"
	(if (probe-file *test-file*)
		(delete-file (probe-file *test-file*)))
	(baseball-analy:save-csv *test-file*
							 (baseball-analy:create-baseball-page-parse-tree "1" "b"))
	(baseball-analy:add-first-col-to-csv-file "team" "1" *test-file*)
	(is (mylib:read-file-to-first-line *test-file*)
		"team,背番号↑,選手,打率,試合,打席,打数,安打,二塁打,三塁打,本塁打,塁打,打点,得点,三振,四球,死球,犠打,犠飛,盗塁,盗塁死,併殺打,出塁率,長打率,OPS,得点圏,失策")
	(delete-file (probe-file *test-file*))))

(finalize)
