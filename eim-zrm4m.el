;;; -*- coding: utf-8 -*-
;;; eim-zrm4m.el --- emacs chinese pinyin input method for eim

;; Copyright 2006 Ye Wenbin
;;
;; Author: wenbinye@163.com
;; Version: $Id: eim-zrm4m.el,v 1.3 2007/01/14 01:52:46 ywb Exp $
;; Keywords: 
;; X-URL: not distributed yet

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

;;; Commentary:

;;;_* Code:

(provide 'eim-zrm4m)
(eval-when-compile
  (require 'cl))
(require 'eim)
(require 'eim-extra)

(load-file "eim-zrm4m-chars2.el")
(load-file "ama-debug.el")

;;;_. variable declare

(defvar eim-zrm4m-load-hook nil)
(defvar eim-zrm4m-initialized nil)
(defvar eim-zrm4m-punctuation-list nil)
(defvar eim-zrm4m-package nil)
;;(defvar eim-zrm4m-char-table (make-vector 1511 nil))

(defvar eim-zrm4m-pos nil)
(defvar eim-zrm4m-pylist nil)

(defun eim-zrm4m-pre-insert-command ()
  (if (eim-string-emptyp eim-current-key)
      (member last-command-event eim-first-char)
    (member last-command-event eim-total-char)))

(defun eim-zrm4m-insert-command ()
  (interactive "*")
  ;;(message "%s" (current-buffer))
  (message "last command char = %S" last-command-event)
  (if (eim-zrm4m-pre-insert-command)
      (progn
        (setq eim-current-key (concat eim-current-key (char-to-string last-command-event)))
        (funcall eim-handle-function))
    (progn
      (message "current-key:%S" eim-current-key)
      (eim-append-string (eim-translate last-command-event))
      (eim-terminate-translation))))

(defun eim-zrm4m-get-choices (chs)
  (let ((alst (py-keypress chs))
        (olst nil))
    (setq olst (maplist #'(lambda (x) (nth 1 (car x)))
                        alst))
    ;;(print olst)
    (list olst)))
        
(provide 'eim-zrm4m)
(eval-when-compile
  (require 'cl))
(require 'eim)
(require 'eim-extra)

(load-file "eim-zrm4m-chars2.el")
(load-file "ama-debug.el")

;;;_. variable declare

(defvar eim-zrm4m-load-hook nil)
(defvar eim-zrm4m-initialized nil)
(defvar eim-zrm4m-punctuation-list nil)
(defvar eim-zrm4m-package nil)
;;(defvar eim-zrm4m-char-table (make-vector 1511 nil))

(defvar eim-zrm4m-pos nil)
(defvar eim-zrm4m-pylist nil)

(defun eim-zrm4m-get-choices (chs)
  (let ((alst (py-keypress chs))
        (olst nil))
    (setq olst (maplist #'(lambda (x) (nth 1 (car x)))
                        alst))
    (delete-dups olst)
    ;;(print olst)
    (list olst)))
        
(maplist #'(lambda (x) (nth 1 (car x)))
             '((a 1) (b 2)))
;;;_. handle function
(defun eim-zrm4m-handle-string ()
  (print eim-current-key)
  (let ((str eim-current-key))
    (setq eim-zrm4m-pos 0)
    (setq eim-current-choices (eim-zrm4m-get-choices str))
    ;;(list (delete-dups (eim-zrm4m-get-choices str))))

    (when  (car eim-current-choices)
      (setq eim-current-pos 1)
      (eim-zrm4m-format-page) t)
    (eim-show)
   ))

(defun eim-zrm4m-format-page ()
  "按当前位置，生成候选词条"
  (let* ((end (eim-page-end))
         (start (1- (eim-page-start)))
         (choices (car eim-current-choices))
         (choice (eim-subseq choices start end))
         (pos (1- (min eim-current-pos (length choices))))
         (i 0) rest)
    (setq eim-current-str (concat (substring eim-current-str 0 eim-zrm4m-pos)
                                  (eim-choice (nth pos choices)))
          rest (mapconcat (lambda (py)
                            (concat (car py) (cdr py)))
                          (nthcdr (length eim-current-str) eim-zrm4m-pylist)
                          "'"))
    (if (string< "" rest)
        (setq eim-current-str (concat eim-current-str rest)))
    (setq eim-guidance-str
          (format "%s[%d/%d]: %s"
                  (replace-regexp-in-string "-" " " eim-current-key)
                  (eim-current-page) (eim-total-page)
                  (mapconcat 'identity
                             (mapcar
                              (lambda (c)
                                (format "%d.%s " (setq i (1+ i))
                                        (if (consp c)
                                            (concat (car c) (cdr c))
                                          c)))
                              choice) " ")))
    (eim-show)))

;;;_. commands
(defun eim-zrm4m-select-current ()
  (interactive)
  (if (null (car eim-current-choices))  ; 如果没有选项，输入空格
      (progn 
        (setq eim-current-str (eim-translate last-command-event))
        (eim-terminate-translation))
    (let ((str (eim-choice (nth (1- eim-current-pos) (car eim-current-choices))))
          chpy pylist)
      (setq eim-current-str str)
      (eim-terminate-translation))))

(defun eim-zrm4m-number-select ()
  "如果没有可选项，插入数字，否则选择对应的词条"
  
  (interactive)
  (if (car eim-current-choices)
      (let ((index (- last-command-event ?1))
            (end (eim-page-end)))
        (if (> (+ index (eim-page-start)) end)
            (eim-show)
          (setq eim-current-pos (+ eim-current-pos index))
          (setq eim-current-str (concat (substring eim-current-str 0
                                                   eim-zrm4m-pos)
                                        (eim-choice
                                         (nth (1- eim-current-pos)
                                              (car eim-current-choices)))))
          (eim-zrm4m-select-current)))
    (eim-append-string (char-to-string last-command-event))
    (eim-terminate-translation)))

(defun eim-zrm4m-next-page (arg)
  (interactive "p")
  (if (= (length eim-current-key) 0)
      (progn
        (eim-append-string (eim-translate last-command-event))
        (eim-terminate-translation))
    (let ((new (+ eim-current-pos (* eim-page-length arg) 1)))
      (setq eim-current-pos (if (> new 0) new 1)
            eim-current-pos (eim-page-start))
      (eim-zrm4m-format-page))))

(defun eim-zrm4m-previous-page (arg)
  (interactive "p")
  (eim-zrm4m-next-page (- arg)))

(defun eim-zrm4m-quit-no-clear ()
  (interactive)
  (setq eim-current-str (replace-regexp-in-string "-" ""
                                                  eim-current-key))
  (eim-terminate-translation))

(defun eim-zrm4m-backward-kill-py ()
  (interactive)
  (string-match "['-][^'-]+$" eim-current-key)
  (setq eim-current-key
        (replace-match "" nil nil eim-current-key))
  (eim-zrm4m-handle-string))

;;;_. punctuation
(defun eim-zrm4m-translate (char)
  (eim-punc-translate eim-zrm4m-punctuation-list char))

(defun eim-zrm4m-activate-function ()
  (setq eim-do-completion nil)
  (setq eim-handle-function 'eim-zrm4m-handle-string)
  (setq eim-translate-function 'eim-zrm4m-translate)
  (make-local-variable 'eim-zrm4m-pylist)
  (make-local-variable 'eim-zrm4m-pos))

;;;_. eim-zrm4m-get
(defun eim-zrm4m-get (code)
  (let ((eim-current-package eim-zrm4m-package)
        words)
    (when (and (stringp code) (string< "" code))
      (dolist (buf (eim-buffer-list))
        (with-current-buffer (cdr (assoc "buffer" buf))
          (setq words (append words
                              (cdr
                               (eim-bisearch-word code
                                                  (point-min)
                                                  (point-max)))))))
      (delete-dups words))))

(defun eim-zrm4m-save-file ()
  "保存词库到文件中"
  (interactive)
  (let* ((eim-current-package eim-zrm4m-package)
         (buffer (car (eim-buffer-list))))
    (with-current-buffer (cdr (assoc "buffer" buffer))
      (save-restriction
        (widen)
        (write-region (point-min) (point-max) (cdr (assoc "file" buffer)))))))

;;;_. load it
(unless eim-zrm4m-initialized
  (setq eim-zrm4m-package eim-current-package)
  (setq eim-zrm4m-punctuation-list
        (eim-read-punctuation eim-zrm4m-package))
  (let ((eim-current-package eim-zrm4m-package))
    (let ((map (eim-mode-map))
          (i ?\ ))
    (while (< i 127)
      (define-key map (char-to-string i) 'eim-zrm4m-insert-command)
      (setq i (1+ i)))

      (define-key map " " 'eim-zrm4m-select-current)
      (define-key map "\C-n" 'eim-zrm4m-next-page)
      (define-key map "\C-p" 'eim-zrm4m-previous-page)
      (define-key map "\C-m" 'eim-zrm4m-quit-no-clear)
      (define-key map (kbd "M-DEL") 'eim-zrm4m-backward-kill-py)
      (dolist (i (number-sequence ?1 ?9))
        (define-key map (char-to-string i) 'eim-zrm4m-number-select)))
    (eim-set-active-function 'eim-zrm4m-activate-function))
  (run-hooks 'eim-zrm4m-load-hook)
  (setq eim-zrm4m-initialized t)
  (add-to-list 'kill-emacs-hook 'eim-zrm4m-save-file))

;;;_* py.el ends here

;;; Local Variables:
;;; allout-layout: (* 0 : )
;;; End:
