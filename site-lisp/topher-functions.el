(defun kill-special-buffers ()
  "Kills all special buffers that were generated by emacs (*Messages*, etc.)"
  (interactive)
  (save-excursion
    (dolist(buffer (buffer-list))
      (set-buffer buffer)
      (if (string-match "^\\*" (buffer-name buffer))
					(progn
						(message (concat "Killing buffer: " (buffer-name buffer)))
						(kill-buffer buffer))))))

(defun check-syntax ()
  "Checks the syntax for the current language best way it knows how"
  (interactive)
  (cond
   ((eq major-mode 'c++-mode) (compile compile-command))
   ((eq major-mode 'python-mode)
    (python-check (concat "pycheckers.bat " buffer-file-name)))
   (t (message "Don't know which checker to use."))))

;; Toggle sticky window dedication
(defun toggle-sticky-window ()
  "Toggle whether the current active window is stickied or not.
  Taken from http://stackoverflow.com/questions/43765/pin-emacs-buffers-to-windows-for-cscope/65992#65992
  "
  (interactive)
  (message 
   (if (let
           (window (get-buffer-window (current-buffer)))
         (set-window-dedicated-p window 
                                 (not (window-dedicated-p window))))
       "Window '%s' is stickied!"
     "Window '%s' is un-stickied")
   (current-buffer)))

;; When no lines are selected, comment-dwim will comment out the line (instead
;; of commenting at the end).
;; Taken from http://www.emacswiki.org/emacs/CommentingCode
(defun comment-dwim-line (&optional arg)
  "Replacement for the comment-dwim command.
        If no region is selected and current line is not blank and we are not at the end of the line,
        then comment current line.
        Replaces default behaviour of comment-dwim, when it inserts comment at the end of the line."
  (interactive "*P")
  (comment-normalize-vars)
  (if (and (not (region-active-p)) (not (looking-at "[ \t]*$")))
      (comment-or-uncomment-region (line-beginning-position) (line-end-position))
    (comment-dwim arg)))
(global-set-key "\M-;" 'comment-dwim-line)

(provide 'topher-functions)
