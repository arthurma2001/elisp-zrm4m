(setq load-path
           (append (list nil "/vd0/home/ama/emacs/zrm4m/xp/"
                           "/usr/local/share/emacs"
                         )
           load-path))
(load-file "eim.el")
;;(load-file "eim-zrm4m-chars.el")
;;(load-file "eim-zrm4m-chars2.el")
;;(load-file "ama-zrm4m-test005.el")

(load-file "zrm4m-data.el")
(build-pydata-init)
;;(defun py-keypress (chars0)
;;eim-zrm4m-char-table

;;(add-to-list 'load-path "~/emacs/viogus-eim-5994240")
;;(autoload 'eim-use-package "eim" "Another emacs input method")
;; Tooltip 暂时还不好用
;;(setq eim-use-tooltip nil)

(defun ama-setup-zrm4m ()
  (register-input-method
   "eim-zrm4m" "euc-cn" 'eim-use-package
   "自然" "汉字自然输入法" "tmp_zrm4m.txt")
  ;; 科学会学 "zrm4m.txt")
  

  ;(register-input-method
  ; "eim-wb" "euc-cn" 'eim-use-package
  ; "五笔" "汉字五笔输入法" "wb.txt")

  (register-input-method
   "拼音" "汉字拼音输入法" "py.txt")
;;   "eim-py" "euc-cn" 'eim-use-package

  ;; 用 ; 暂时输入英文
  ;(require 'eim-extra)
  ;(global-set-key ";" 'eim-insert-ascii)
  
  ;;(eim-input-method)
  ;;(list-input-methods)
  ;;(activate-input-method 'chinese-ziranma)
  ;;(activate-input-method 'eim-py)
  
  (setq input-method-use-echo-area t) ;;nil)
  ;(setq unread-command-events nil)
  ;(setq unread-post-input-method-events nil)
  
  ;;(activate-input-method 'eim-py)
  (activate-input-method 'eim-zrm4m)
)

(defun ama-test001 ()
  ;;(concat eim-first-char)
  (member 117 eim-first-char)
  (member 117 eim-total-char)
)
;;(ama-test001)

(ama-setup-zrm4m)
;;(char-to-string 117)
(member 117 eim-first-char)
(concat eim-first-char)
;; ;;白鹿源
