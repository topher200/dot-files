;; path update
(add-to-list 'load-path (expand-file-name "~/.emacs.d/site-lisp"))

;; Variables configured via 'customize' interface
(setq custom-file "~/.emacs.d/custom.el")
(load custom-file)

(require 'package)
(setq package-archives
      '(("elpa" . "http://tromey.com/elpa/")
        ("melpa" . "http://melpa.milkbox.net/packages/")
        ("marmalade" . "https://marmalade-repo.org/packages/")))
;; add required packages here
(setq required-packages
      '(flx-ido
        evil
        evil-numbers
        projectile
        ace-jump-mode
        dos
        coffee-mode))
(defun install-missing-packages ()
  "Install all required packages that haven't been installed."
  (interactive)
  (mapc (lambda (package)
          (unless (package-installed-p package)
            (package-install package)))
        required-packages)
  (message "Installed all missing packages!"))
(package-initialize)

;; gui settings
(setq inhibit-startup-message t)
(if (fboundp 'menu-bar-mode) (menu-bar-mode -1))
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(set-default 'truncate-lines t) ;; stop word wrap
(setq visible-bell t) ;; stop viper-mode from making noise
(setq column-number-mode t) ;; show column number in mode bar
(blink-cursor-mode 0) ;; turn off blinking cursor
(fringe-mode '(0 . 0))  ; == minimal (not sure why 'minimal doesn't work)
(show-paren-mode 1) ;; hilight matching parens

;; window keybindings
(global-set-key (kbd "M-0") 'delete-window)
(global-set-key (kbd "M-1") 'delete-other-windows)
(global-set-key (kbd "M-s") 'split-window-horizontally)
(global-set-key (kbd "M-v") 'split-window-vertically)
(global-set-key (kbd "M-=") 'balance-windows)

;; programming keybindings
(global-set-key (kbd "C-s") 'save-buffer)
(global-set-key(kbd "<f6>") 'fs-lint)
(global-set-key(kbd "<f7>") 'check-syntax)

;; misc settings
(setq-default backup-inhibited t) ;; no backups
(setq auto-save-default nil) ;; no autosave
(global-auto-revert-mode 1) ;; revert unmodified buffers that changed on disk
(fset 'yes-or-no-p 'y-or-n-p) ;; make all yes/no questions y/n
(desktop-save-mode 1) ;; restore emacs state on startup
(setq-default indent-tabs-mode nil) ;; use spaces, never tabs for indenting
(setq x-select-enable-clipboard t) ;; copy/paste uses X's clipboard
(setq window-combination-resize t) ;; resize windows on window split/close

;; colors
(require 'color-theme)
(color-theme-initialize)
(setq color-theme-is-global t)
(color-theme-greiner2)

;; fonts
(defun my-font () (interactive)
  ;; failing my-font() silently if the font isn't installed
  (condition-case nil
      (set-default-font
       "-outline-Crisp-normal-r-normal-normal-16-120-96-96-c-*-iso8859-1")
    (error
     (message "Topher: init.el failed to load font. It probably isn't installed")
     (set-face-attribute 'default nil :height 100)
     nil)))
(my-font)
(global-font-lock-mode t)
(setq font-lock-maximum-decoration t)
(setq case-fold-search t)
(setq current-language-environment "Latin-1")

;; color changes required for linux M-x shell
(autoload 'ansi-color-for-comint-mode-on "ansi-color" nil t)

(add-hook 'shell-mode-hook
          '(lambda () (interactive)
             'ansi-color-for-comint-mode-on
             (local-set-key [up] 'comint-previous-input)
             (local-set-key [down] 'comint-next-input)))

;; uniquify
(require 'uniquify)
(setq uniquify-buffer-name-style 'reverse)
(setq uniquify-separator "|")

;; use ido mode
(require 'ido)
(ido-mode t)
(ido-everywhere t)
(setq ido-enable-flex-matching t) ;; enable fuzzy matching
(setq ido-default-buffer-method 'selected-window)
(setq ido-max-directory-size 1000000)  ;; remove [Too Big] warning for C-x C-f

;; use flx fuzzy matching for ido mode
(require 'flx-ido)
(flx-ido-mode t)
(setq ido-use-faces nil)

;; use smex mode (ido for M-x)
(require 'smex)
(smex-initialize)
(global-set-key (kbd "M-x") 'smex)

;; use projectile mode (project-wide file finding and tools)
(projectile-global-mode)
(global-set-key (kbd "C-x f") 'projectile-find-file-in-known-projects)

;; provide keep-end mode (keeps cursor at end of buffer)
(require 'keep-end)

;; org-mode settings
(setq org-hide-leading-stars t)

;; use goto-last-change. loading before evil so it maps it
(require 'goto-last-change)

;; startup with evil (viper-mode updated)
(setq-default evil-shift-width 2)
(require 'evil)  
(evil-mode 1)
(define-key evil-normal-state-map (kbd "<tab>") 'compilation-next-error)
(define-key evil-normal-state-map (kbd "C-S-o") 'evil-jump-forward)
(define-key evil-normal-state-map (kbd "Y") "y$")

(defadvice
    evil-search-forward
    (after evil-search-forward-recenter activate)
    (recenter))
(ad-activate 'evil-search-forward)

(defadvice
    evil-search-next
    (after evil-search-next-recenter activate)
    (recenter))
(ad-activate 'evil-search-next)

(defadvice
    evil-search-previous
    (after evil-search-previous-recenter activate)
    (recenter))
(ad-activate 'evil-search-previous)

(require 'evil-numbers)
(global-set-key (kbd "C-c =") 'evil-numbers/inc-at-pt)
(global-set-key (kbd "C-c -") 'evil-numbers/dec-at-pt)

;; use grin-mode
(require 'grin)

;; set up tags support
(require 'etags-select)
(global-set-key (kbd "M-.") 'etags-select-find-tag)
(global-set-key (kbd "M-?") 'etags-select-find-tag-at-point)

;; flymake mode
(add-to-list 'load-path "~/.emacs.d/site-lisp/emacs-flymake")
(defun flymake-python-init ()
  (let* ((temp-file (flymake-init-create-temp-buffer-copy
                     'flymake-create-temp-inplace))
         (local-file (file-relative-name
                      temp-file
                      (file-name-directory buffer-file-name))))
    (list "epylint" (list local-file))))
(require 'flymake)
(add-to-list 'load-path "~/.emacs.d/site-lisp/emacs-flymake-cursor")
(require 'flymake-cursor)
(add-to-list 'flymake-allowed-file-name-masks '("\\.py\\'" flymake-python-init))
(add-hook 'find-file-hook 'flymake-find-file-hook)
(add-hook 'compilation-mode-hook
          '(lambda () (interactive)
             (local-set-key (kbd "g") nil)
             (local-set-key (kbd "z") nil)))
(add-hook 'python-mode-hook
          '(lambda ()
             (define-key python-mode-map "\C-cn" 'flymake-goto-next-error)))
(add-hook 'python-mode-hook
          '(lambda ()
             (define-key python-mode-map "\C-cp" 'flymake-goto-prev-error)))

;; c++-mode
(add-to-list 'auto-mode-alist '("\\.cc$" . c++-mode))
(add-to-list 'auto-mode-alist '("\\.cpp$" . c++-mode))
(add-to-list 'auto-mode-alist '("\\.cxx$" . c++-mode))
(add-to-list 'auto-mode-alist '("\\.h$" . c++-mode))
(add-to-list 'auto-mode-alist '("\\.hh$" . c++-mode))
(add-to-list 'auto-mode-alist '("\\.hpp$" . c++-mode))
(add-to-list 'auto-mode-alist '("\\.hxx$" . c++-mode))
(add-to-list 'auto-mode-alist '("\\.idl$" . c++-mode))
(add-to-list 'auto-mode-alist '("\\.ipp$" . c++-mode))
(require 'google-c-style)
(add-hook 'c-mode-common-hook 'google-set-c-style)

;; python-mode
(add-to-list 'auto-mode-alist '("\\.py$" . python-mode))
(add-to-list 'auto-mode-alist '("\\.pyw$" . python-mode))
(add-to-list 'auto-mode-alist '("\\.pxd$" . python-mode))
(add-to-list 'auto-mode-alist '("\\.pyx$" . python-mode))
(setq python-indent 2)

;; go-mode
(add-to-list 'auto-mode-alist '("\\.go$" . go-mode))

;; lua mode
(autoload 'lua-mode "lua-mode" "Lua editing mode." t)
(add-to-list 'auto-mode-alist '("\\.lua$" . lua-mode))
(add-to-list 'interpreter-mode-alist '("lua" . lua-mode))

;; clojure mode
(add-to-list 'auto-mode-alist '("\\.clj$" . clojure-mode))

;; comment .ini files with "; "
(add-hook 'conf-space-mode-hook (lambda () (setq comment-start "; "
                                                 comment-end "")))
;; comment .bat files with ":: "
(add-hook 'conf-space-mode-hook (lambda () (setq comment-start ":: "
                                                 comment-end "")))

;; make evil jump words like Vim
(modify-syntax-entry ?_ "w" c++-mode-syntax-table)
(add-hook 'python-mode-hook
          '(lambda ()
             (modify-syntax-entry ?_ "w" python-mode-syntax-table)))
(add-hook 'ruby-mode-hook
          '(lambda ()
             (modify-syntax-entry ?_ "w" ruby-mode-syntax-table)))
(add-hook 'c-mode-common-hook
          '(lambda ()
             (modify-syntax-entry ?_ "w" c-mode-syntax-table)))
(add-hook 'c-mode-common-hook
          '(lambda ()
             (modify-syntax-entry ?_ "w" c++-mode-syntax-table)))
(add-hook 'html-mode-hook
          '(lambda ()
             (modify-syntax-entry ?_ "w" html-mode-syntax-table)))

;; evan functions: google()
(require 'evan-functions)

;; topher-specific
(require 'topher-functions)

;; farsounder specific
(require 'farsounder)
(require 'sonasoft)
(sonasoft-setup-compile)

;; set up hippie-expand. match C-n from Vim
(define-key evil-insert-state-map (kbd "C-n") 'hippie-expand)
(define-key evil-insert-state-map (kbd "C-S-n") 
  (lambda () (interactive) (hippie-expand -1)))
;; Try to do case-sensitive matching with just hippie expand
;; From http://stackoverflow.com/a/8723712/131159
(defadvice hippie-expand (around hippie-expand-case-fold)
  "Try to do case-sensitive matching (not effective with all functions)."
  (let ((case-fold-search nil))
    ad-do-it))
(ad-activate 'hippie-expand)

;; bind RET (mostly in insert mode) to newline and indent
(global-set-key (kbd "RET") 'newline-and-indent)

;; movement control
;; attempts to keep cursor in the middle of the screen while scrolling
(defun move-and-center (scroll-function)
  (call-interactively 'evil-scroll-line-to-center)
  (call-interactively scroll-function)
  (call-interactively 'evil-window-middle))

(defvar my-keys-minor-mode-map (make-keymap))
;; Scroll up and down with Ctrl-j/k
(define-key my-keys-minor-mode-map (kbd "C-j")
  (lambda () (interactive) (move-and-center 'scroll-up)))
(define-key my-keys-minor-mode-map (kbd "C-k")
  (lambda () (interactive) (move-and-center 'scroll-down)))
;; move between windows with Ctrl-Tab
(define-key my-keys-minor-mode-map (kbd "C-<tab>") 'next-multiframe-window)
(define-key my-keys-minor-mode-map (kbd "C-S-<tab>")
  'previous-multiframe-window)
(define-key my-keys-minor-mode-map (kbd "C-S-<iso-lefttab>")
  'previous-multiframe-window)  ;; linux laptop
;; stop emacs from calling suspend-frame on Ctrl-x Ctrl-z
(define-key my-keys-minor-mode-map (kbd "C-x C-z") 'no-op)
(define-key my-keys-minor-mode-map (kbd "C-t")
  (lambda () (interactive) (browse-url "www.google.com")))
(define-key my-keys-minor-mode-map (kbd "C-c C-f")
  (lambda () (interactive) (ff-find-other-file)))
(define-key my-keys-minor-mode-map (kbd "C-c C-s")
  (lambda () (interactive) (named-shell)))
(define-key my-keys-minor-mode-map (kbd "C-x C-k")
  (lambda () (interactive) (kill-this-buffer)))
(define-key my-keys-minor-mode-map (kbd "C-c C-r")
  (lambda () (interactive)
    ;; redo flymake check
    (call-interactively 'flymake-start-syntax-check)
    ;; refresh syntax highlightings
    (call-interactively 'font-lock-fontify-buffer)))
(define-key evil-normal-state-map (kbd "SPC") 'ace-jump-mode)
(define-minor-mode my-keys-minor-mode t 'my-keys-minor-mode-map)
(my-keys-minor-mode 1)

;; from http://stackoverflow.com/questions/7349487/emacs-different-tab-indent-settings-in-different-modes
(defadvice whitespace-cleanup (around whitespace-cleanup-indent-tab
                                      activate)
  "Fix whitespace-cleanup indent-tabs-mode bug"
  (let ((whitespace-indent-tabs-mode indent-tabs-mode)
        (whitespace-tab-width tab-width))
    ad-do-it))

(add-hook 'projectile-idle-timer-hook 'desktop-save-in-desktop-dir)

(setq max-lisp-eval-depth 10000)
