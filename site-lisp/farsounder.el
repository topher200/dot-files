;;; farsounder.el --- FarSounder dev tools

(defgroup farsounder nil
  "Emacs stuff for FarSounder software development."
  :group 'programming)

(defun fs-insert-header ()
  "Insert FarSounder's standard header comment in the current buffer.
Works with C++ and python files."
  (interactive)
  (goto-char (point-min))
  (cond
   ((eq major-mode 'c++-mode)
    (insert "// TODO(evan) project name
// Copyright 2001-2010 FarSounder Inc.  All rights reserved.
// For internal use only. See NOTICE.txt for details.
//
// $LastChangedBy$
// $Date$
// $Rev$

"))
   ((eq major-mode 'python-mode)
    (insert "\"\"\"TODO(evan) add description
\"\"\"

__author__ = \"$LastChangedBy$\"
__date__ = \"$Date$\"
__version__ = \"$Rev$\"
__copyright__ = \"Copyright 2001-2009 FarSounder, Inc. All rights reserved.\"
__notice__ = \"For internal use only. See NOTICE.txt for details.\"

"))
   (t (message "Don't know what header to add."))))

(defun fs-lint ()
  "Run FarSounder linter based on the current prog mode."
  (interactive)
  (cond
   ((eq major-mode 'c++-mode) (set 'fs-linter "cpplint.py"))
   ((eq major-mode 'python-mode) (set 'fs-linter "pep8.py"))
   (t (message "Don't know which linter to use.")
      (set 'fs-linter nil)))
  (when fs-linter
    (compilation-start (concat fs-linter " \"" buffer-file-name "\"")
                       nil (lambda (mode) "*lint*"))))

(defun fs-notes ()
  "Open my FarSounder notes file."
  (interactive)
  (find-file "//providence/USERS/Evan.Lapisky/notes.org"))

(defun fs-wiki (page)
  "Open a page in the FarSounder wiki. Results are shown in a w3m
session or in the system's web browser depending on user input."
  (interactive "sOpen page: ")
  (if (y-or-n-p "Show results in emacs? ")
      (w3m (concat "http://pvd/wiki/moin.cgi/"
                   (replace-regexp-in-string " " "%20" page)))
    (browse-url (concat "http://pvd/fswiki/moin.cgi/"
                        (replace-regexp-in-string " " "%20"
                        page)))))

(provide 'farsounder)