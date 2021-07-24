;;; ~/.config/doom/config.el -*- lexical-binding: t; -*-

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ;;;;;;;;;;;;;;;;;;;;;;        ;;;;;;;;;;;;;;;;;;;;
;; ;;;;;;;;;;;;;;;;                    ;;;;;;;;;;;;;;
;; ;;;;;;;;;;;;;                ;;;;;;;   ;;;;;;;;;;;
;; ;;;;;;;;;;;                ;;;;;;;;;     ;;;;;;;;;
;; ;;;;;;;;;                 ;;;;;;;;         ;;;;;;;
;; ;;;;;;;;                  ;;;;;;            ;;;;;;
;; ;;;;;;;                   ;;;;;;             ;;;;;
;; ;;;;;;            ;;;;;;; ;;;;;;              ;;;;
;; ;;;;;           ;;;;;;;;; ;;;;;;               ;;;
;; ;;;;;           ;;;;;;;   ;;;;;;               ;;;
;; ;;;;;            ;;;;;;    ;;;;;               ;;;
;; ;;;;;             ;;;;;;    ;;;;               ;;;
;; ;;;;;              ;;;;;;    ;;;               ;;;
;; ;;;;;               ;;;;;;    ;                ;;;
;; ;;;;;;               ;;;;;;                   ;;;;
;; ;;;;;;;               ;;;;;                  ;;;;;
;; ;;;;;;;;               ;;;;;                ;;;;;;
;; ;;;;;;;;;;              ;;;;;             ;;;;;;;;
;; ;;;;;;;;;;;;             ;;;;;          ;;;;;;;;;;
;; ;;;;;;;;;;;;;;            ;;;;;       ;;;;;;;;;;;;
;; ;;;;;;;;;;;;;;;;;;                ;;;;;;;;;;;;;;;;
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; user
(setq-default
 user-full-name    "Vivek Menon"
 user-mail-address "mail@vvkmnn.xyz")

;; editor
(setq frame-title-format '("vDoom Emacs | %m | %b") ;; Title
      doom-private-dir "~/.v.doom.d/"               ;; Private Dir
      menu-bar-mode t                               ;; For Yabai WM NOTE https://github.com/koekeishiya/yabai/issues/86#issuecomment-507934212
      doom-theme 'doom-city-lights)                 ;; Theme

;;; ui/pretty-code
;; Iosevka
;; (setq doom-font (font-spec :family "Iosevka" :size 13)
;;     doom-unicode-font (font-spec :family "Iosevka" :size 13)
;;     doom-variable-pitch-font (font-spec :family "Iosevka" :size 13))
;; Fira
(setq doom-font (font-spec :family "Fira Code" :size 13)
      doom-unicode-font (font-spec :family "Fira Mono" :size 13)
      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))


; Package Lists
; (add-to-list 'package-archives
;              '("melpa" . "http://melpa.org/packages/") t)
; (add-to-list 'package-archives
;              '("melpa-stable" . "http://stable.melpa.org/packages/") t)
; (add-to-list 'package-archives
;          '("marmalade" . "https://marmalade-repo.org/packages/") t)
; (add-to-list 'package-archives
;              '("gnu elpa" . "https://elpa.gnu.org/packages/") t)

; Certificates
; (setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3")

; Dictionary


; (setq ispell-program-name "aspell"
;       ispell-silently-savep t)

;; tools/lsp
(setq lsp-enable-file-watchers nil)

;; lang/latex
(setq-default TeX-engine 'xetex
              TeX-PDF-mode t
              TeX-master nil)


;; lang/cc
(after! ccls
  (setq ccls-initialization-options
        '(:clang (:extraArgs ["-isystem/Library/Developer/CommandLineTools/usr/include/c++/v1"
                              "-isystem/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include"
                              "-isystem/usr/local/include"
                              "-isystem/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/clang/11.0.0/include"
                              "-isystem/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/include"
                              "-isystem/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include"
                              "-isystem/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks"]
                  :resourceDir "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/clang/11.0.0")))
  )

;; app/rss
; (add-hook! 'elfeed-show-mode-hook (text-scale-set 2))

;; tools/magit
                                        ; (setq magit-save-repository-buffers nil)
;; magit-repository-directories '(("~/work" . 2))
;; transient-values '((magit-commit "--gpg-sign=5F6C0EA160557395"
;;                     (magit-rebase "--autosquash" "--gpg-sign=5F6C0EA160557395")
;;                     (magit-pull "--rebase" "--gpg-sign=5F6C0EA160557395"))))

;; editor/evil
(map! :n "C-h" 'evil-window-left
      :n "C-j" 'evil-window-down
      :n "C-k" 'evil-window-up
      :n "C-l" 'evil-window-right

      ;; :m "M-j" '+default:multi-next-line
      ;; :m "M-k" '+default:multi-previous-line

      (:map evil-treemacs-state-map
        "C-h" 'evil-window-left
        "C-l" 'evil-window-right))


;; :tools/macos
(when (eq system-type 'darwin) ;; macOS
  (setq ns-use-thin-smoothing t)
  ;; (mac-auto-operator-composition-mode)
  (add-to-list 'default-frame-alist '(inhibit-double-buffering . t))
  (add-to-list 'default-frame-alist '(ns-transparent-titlebar . t))
  (add-to-list 'default-frame-alist '(ns-appearance . dark))
  (add-hook 'window-setup-hook #'toggle-frame-maximized))

;; lang/org
(setq org-dir "~/.org"
      org-directory "~/.org/"
      org-ellipsis " ▼ ")

;; editor/flycheck
(setq flycheck-checker-error-threshold 666)
;; :lang/python
;; https://github.com/hlissner/doom-emacs/issues/212 FIXME install pyenv?
;; (setq python-shell-interpreter "python3"
;;       flycheck-python-pycompile-executable "python3")

;;;  lang/plantuml
;; (org-babel-do-load-languages
;;  'org-babel-load-languages
;;  '((plantuml . t))) ;; Add Plant UML to Org


;; NOTE Review upstream

;; (defvar xdg-data (getenv "XDG_DATA_HOME"))
;; (defvar xdg-bin (getenv "XDG_BIN_HOME"))
;; (defvar xdg-cache (getenv "XDG_CACHE_HOME"))
;; (defvar xdg-config (getenv "XDG_CONFIG_HOME"))


;;     +workspaces-switch-project-function #'ignore


;; (add-to-list 'org-modules 'org-habit t)


;;     ;;
;;     ;; Host-specific config

;;     (when (equal (system-name) "triton")
;;       ;; I've swapped these keys on my keyboard
;;       (setq x-super-keysym 'meta
;;             x-meta-keysym  'super))

;;     (pcase (system-name)
;;       ("halimede"
;;        (setq doom-font (font-spec :family "Input Mono Narrow" :size 9)))
;;       (_
;;        (setq doom-font (font-spec :family "Input Mono Narrow" :size 12)
;;              +modeline-height 25)))



;;     ; (:when IS-LINUX
;;     ;   "s-x" #'execute-extended-command
;;     ;   "s-;" #'eval-expression
;;     ;   ;; use super for window/frame navigation/manipulation
;;     ;   "s-w" #'delete-window
;;     ;   "s-W" #'delete-frame
;;     ;   "s-n" #'+default/new-buffer
;;     ;   "s-N" #'make-frame
;;     ;   "s-q" (if (daemonp) #'delete-frame #'evil-quit-all)
;;     ;   ;; Restore OS undo, save, copy, & paste keys (without cua-mode, because
;;     ;   ;; it imposes some other functionality and overhead we don't need)
;;     ;   "s-z" #'undo
;;     ;   "s-c" (if (featurep 'evil) #'evil-yank #'copy-region-as-kill)
;;     ;   "s-v" #'yank
;;     ;   "s-s" #'save-buffer
;;     ;   ;; Buffer-local font scaling
;;     ;   "s-+" (λ! (text-scale-set 0))
;;     ;   "s-=" #'text-scale-increase
;;     ;   "s--" #'text-scale-decrease
;;     ;   ;; Conventional text-editing keys
;;     ;   "s-a" #'mark-whole-buffer
;;     ;   :gi [s-return]    #'+default/newline-below
;;     ;   :gi [s-S-return]  #'+default/newline-above
;;     ;   :gi [s-backspace] #'doom/backward-kill-to-bol-and-indent)

;;     ; :leader
;;     ; (:prefix "f"
;;     ;   :desc "Find file in dotfiles" "t" #'+hlissner/find-in-dotfiles
;;     ;   :desc "Browse dotfiles"       "T" #'+hlissner/browse-dotfiles)
;;     ; (:prefix "n"
;;     ;   :desc "Open mode notes"       "m" #'+hlissner/find-notes-for-major-mode
;;     ;   :desc "Open project notes"    "p" #'+hlissner/find-notes-for-project))


;;     ; ;;
;;     ; ;; Modules

;;     ; ;; emacs/eshell
;;     ; (after! eshell
;;     ;   (set-eshell-alias!
;;     ;    "f"   "find-file $1"
;;     ;    "l"   "ls -lh"
;;     ;    "d"   "dired $1"
;;     ;    "gl"  "(call-interactively 'magit-log-current)"
;;     ;    "gs"  "magit-status"
;;     ;    "gc"  "magit-commit"))

;;     ; ;;
;;     ; ;; Custom

;;     ; (def-project-mode! +javascript-screeps-mode
;;     ;   :match "/screeps\\(?:-ai\\)?/.+$"
;;     ;   :modes (+javascript-npm-mode)
;;     ;   :add-hooks (+javascript|init-screeps-mode)
;;     ;   :on-load (load! "lisp/screeps"))
