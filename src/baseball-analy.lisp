(in-package #:baseball-analy)

(defun read-file-to-list (filepath)
  (let ((lines '()))
    (with-open-file (in filepath)
      (loop for line = (read-line in nil)
         while line
         do (setf lines (append lines (list line)))))
    lines))

(defun read-file-to-first-line (filepath)
  (car (read-file-to-list filepath)))

(defun range (begin end &optional (step 1))
  (cond ((<= begin end)
		 (cons begin (range (+ begin step) end step)))
		(t nil)))

(defun list-team-and-player (player)
  (mapcar #'(lambda (x) (cons x player))
		  (mapcar #'princ-to-string
				  ;; 10 is not found. 376
				  (subst 376 10 (range 1 12)))))
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
	(format out "~A" (create-csv-data node-tree))))

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
  (mapcan #'(lambda (x) (cdr (read-file-to-list x)))
		  (directory (concatenate 'string
								  "data/"
								  team "-" player
								  ".csv"))))

(defun line-search (search-q)
  (car (member-if #'(lambda (x) (ppcre:scan search-q x)) (list-player-info "*" "*"))))
