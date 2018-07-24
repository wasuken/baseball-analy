(in-package #:baseball-analy)

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
;;; can use wildcard
(defun list-player-info (team player)
  (mapcan #'(lambda (x) (cdr (mylib:read-file-to-list x)))
		  (directory (concatenate 'string
								  "data/"
								  team "-" player
								  ".csv"))))

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

;; (mylib:take (sort  (mapcar #'list
;; 						   (cdr (col-search "b" 1))
;; 						   (cdr (col-search "b" 5))
;; 						   (cdr (col-search "b" 6))
;; 						   (cdr (col-search "b" 2)))
;; 				   #'(lambda (x y)
;; 					   (> (read-from-string (nth 1 x))
;; 						  (read-from-string (nth 1 y))))) 20)
