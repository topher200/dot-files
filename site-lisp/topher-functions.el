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
    (python-check (concat "pychecker --stdlib " buffer-file-name)))
   (t (message "Don't know which checker to use."))))


(provide 'topher-functions)
