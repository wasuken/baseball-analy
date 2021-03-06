(in-package #:baseball-analy)
;;; ここからwebからデータ取得->csv保存まで
(defun list-team-and-player (player)
  (mapcar #'(lambda (x) (cons x player))
		  (mapcar #'princ-to-string
				  ;; 10 is not found. 376
				  (subst 376 10 (mylib:range 1 12)))))
;;; ref (http://d.hatena.ne.jp/masatoi/20170203/1486121334)
(defun node-text (node)
  (let ((text-list nil))
    (plump:traverse node
                    (lambda (node) (push (plump:text node) text-list))
                    :test #'plump:text-node-p)
    (apply #'concatenate 'string (nreverse text-list))))

(defun create-csv-data (page-node-tree)
  (format nil "~{~a~^~%~}"
		  (reverse (cdr (reverse (mapcar #'(lambda (x) (format nil "~{~a~^,~}"
															   (cdr (ppcre:split #\Newline (node-text x)))))
										 (coerce (clss:select "tr"
															  (clss:select ".NpbPlSt" page-node-tree)) 'list)))))))

(defun url-to-parse-tree (url)
  (plump:parse (dex:get url)))

(defun create-url (team player)
  (concatenate 'string
			   "https://baseball.yahoo.co.jp/npb/teams/"
			   team
			   "/memberlist?type="
			   player))

(defun create-baseball-page-parse-tree (team player)
  (url-to-parse-tree (create-url team player)))

(defun save-csv (filepath node-tree)
  (with-open-file (out filepath :direction :output :if-exists :supersede)
	(format out "~A" (ppcre:regex-replace-all "-"
											  (create-csv-data node-tree)
											  "0"))))

(defun create-all-team-player-csv (player)
  (mapcar #'(lambda (x)
			  (sleep 5)
			  (save-csv (concatenate 'string
									 "data/"
									 (car x) "-" (cdr x)
									 ".csv")
						(create-baseball-page-parse-tree (car x) (cdr x))))
		  (list-team-and-player player)))

(defun create-all-team-and-all-player-csv ()
  (remove-all-csv-data)
  (mapcar #'(lambda (x) (create-all-team-player-csv x)) '("b" "p"))
  (add-team-col-to-all-csv))

(defun remove-all-csv-data ()
  (mapcar #'delete-file (directory "data/*.*")))

;;; Add one column to the file
;;; value is all same.
(defun add-first-col-to-csv-file (header val filepath)
  (cond ((probe-file filepath)
		 (let* ((file-map (mylib:read-file-to-list filepath))
				(add-line (append (list (concatenate 'string header ","))
								  (loop repeat (1- (length file-map))
									 collect (concatenate 'string val ","))))
				(result-file-map (mapcar #'(lambda (x y)
											 (concatenate 'string x y))
										 add-line
										 file-map)))
		   (delete-file filepath)
		   (with-open-file (s filepath :direction :output)
			 (format s "~{~A~%~}" result-file-map))))))

(defparameter *team-number-to-name-list*
  '((1 . "巨人")
	(2 . "ヤクルト")
	(3 . "横浜")
	(4 . "中日")
	(5 . "阪神")
	(6 . "広島")
	(7 . "西武")
	(8 . "日ハム")
	(9 . "ロッテ")
	(11 . "オリックス")
	(12 . "福岡")
	(376 . "楽天")))

(defun get-team-name (number num-to-name-lst)
  (cdar (member-if #'(lambda (x) (= number (car x))) num-to-name-lst)))

(defun add-team-col-to-all-csv (&optional (team-string-p nil))
  (mapcar #'(lambda (x)
			  (let* ((file-attr-lst
					  (ppcre:split "-" (pathname-name (probe-file x))))
					 (val (if team-string-p
							  (get-team-name (car file-attr-lst) *team-number-to-name-list*)
							  (car file-attr-lst))))
				(add-first-col-to-csv-file "team" val x)))
		  (directory "data/*.*")))

;;;;;;;;;; From here csv operation

;;; can use wildcard
(defun list-player-info (team player)
  (let* ((body (mapcan #'(lambda (x) (cdr (mylib:read-file-to-list x)))
					   (directory (concatenate 'string
											   "data/"
											   team "-" player
											   ".csv")))))
	body))

(defun row-search (search-q)
  (remove-if-not #'(lambda (x) (ppcre:scan search-q x)) (list-player-info "*" "*")))

(defun col-search (player col-num)
  (let* ((header (mylib:read-file-to-first-line
				  (concatenate 'string "data/1-" player ".csv")))
		 (body (list-player-info "*" player)))
	(mapcar #'(lambda (x) (nth col-num (ppcre:split "," x)))
			(cons header body))))

(defun list-to-csv-file (list filepath)
  (let* ((csv-lines (mapcar #'(lambda (x)
								(reduce #'(lambda (y z)
											(format nil "~A,~A" y z))
										x))
							list))
		 (csv (reduce #'(lambda (x y) (format nil "~A~%~A" x y)) csv-lines)))
	(with-open-file (s filepath :direction :output)
	  (format s csv))))

;;; which way?????????
(defun multi-single-nth (list cols)
  (loop for c in cols
	 collect (nth c list)))

(defun col-select (cols list)
  (mapcar #'(lambda (x) (loop for c in cols collect (nth c x))) list))

;;; player   ... b or p
;;; sort-col ... sort col-number
;;; cols     ... col-numbers
;;; return   ... ソートされたcsvの結果が返ってくる
;; (sort-list-all-csv-data "b" 2  1 2 3 4 5)
(defmacro sort-list-all-csv-data (player sort-col &rest cols)
  `(sort (col-select ',cols
					 (mapcar #'(lambda (x) (ppcre:split "," x))
							 (list-player-info "*" ,player)))
		 #'(lambda (x y)
			 (> (read-from-string (nth ,sort-col x))
				(read-from-string (nth ,sort-col y))))))

(defun head-name-to-col-number (player &rest header-names)
  (let* ((header (ppcre:split "," (mylib:read-file-to-first-line
								   (concatenate 'string "data/1-" player ".csv")))))
	(mapcar #'(lambda (x)
				(position-if #'(lambda (y)
								 (string= y x))
							 header))
			header-names)))
;;; ここガバ
(defmacro head-name-to-col-numberlist (player header-names)
  `(head-name-to-col-number ,player ,@header-names))

(defmacro sort-list-all-csv-data-for-header-name
	(player sort-col &rest col-names)
  (let ((result `(head-name-to-col-number ,player)))
	(loop for x in col-names
	   do (setf result (append result (list x))))
	`(append '(,col-names) (sort-list-all-csv-data ,player
												,sort-col
												;; devil's action
												,@(eval result)))))
