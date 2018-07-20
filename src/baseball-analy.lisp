(in-package #:baseball-analy)

(defun read-file-to-list (filepath)
  (let ((lines '()))
    (with-open-file (in filepath)
      (loop for line = (read-line in nil)
         while line
         do (setf lines (append lines (list line)))))
    lines))
;;; ahokusa
(defun read-file-to-first-line (filepath)
  (car (read-file-to-list filepath)))

;;; CSVの作成
;;; 完全にコピペ(http://d.hatena.ne.jp/masatoi/20170203/1486121334)
(defun node-text (node)
  (let ((text-list nil))
    (plump:traverse node
                    (lambda (node) (push (plump:text node) text-list))
                    :test #'plump:text-node-p)
    (apply #'concatenate 'string (nreverse text-list))))

(defun create-csv-data (page-node-tree)
  (format nil "~{~a~^~%~}"
		  (mapcar #'(lambda (x) (format nil "~{~a~^,~}"
										(cdr (ppcre:split #\Newline (node-text x)))))
				  (coerce (clss:select "tr"
									   (clss:select ".NpbPlSt" page-node-tree)) 'list))))

(defun url-to-parse-tree (url)
  (plump:parse (dex:get url)))
;;; teamは1~12
;;; playerはp(pitcher)とb(batter)
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
	(print (create-csv-data node-tree) out)))
