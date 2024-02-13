;;; packages.el --- imandra layer packages file for Spacemacs.
;;
;; Copyright (c) 2012-2017 Sylvain Benner & Contributors
;;
;; Author: David Aitken <dave@dimac.local>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

;;; Commentary:

;; See the Spacemacs documentation and FAQs for instructions on how to implement
;; a new layer:
;;
;;   SPC h SPC layers RET
;;
;;
;; Briefly, each package to be installed or configured by this layer should be
;; added to `imandra-packages'. Then, for each package PACKAGE:
;;
;; - If PACKAGE is not referenced by any other Spacemacs layer, define a
;;   function `imandra/init-PACKAGE' to load and initialize the package.

;; - Otherwise, PACKAGE is already referenced by another Spacemacs layer, so
;;   define the functions `imandra/pre-init-PACKAGE' and/or
;;   `imandra/post-init-PACKAGE' to customize the package as it is loaded.

;;; Code:

(defconst imandra-packages
  '((imandra-mode
     :location (recipe :fetcher github
                       :repo "imandra-ai/imandra-mode"))
    lsp-mode
    flycheck
    flycheck-ocaml
    merlin
    ocamlformat)
  "The list of Lisp packages required by the imandra layer.

Each entry is either:

1. A symbol, which is interpreted as a package to be installed, or

2. A list of the form (PACKAGE KEYS...), where PACKAGE is the
    name of the package to be installed or loaded, and KEYS are
    any number of keyword-value-pairs.

    The following keys are accepted:

    - :excluded (t or nil): Prevent the package from being loaded
      if value is non-nil

    - :location: Specify a custom installation location.
      The following values are legal:

      - The symbol `elpa' (default) means PACKAGE will be
        installed using the Emacs package manager.

      - The symbol `local' directs Spacemacs to load the file at
        `./local/PACKAGE/PACKAGE.el'

      - A list beginning with the symbol `recipe' is a melpa
        recipe.  See: https://github.com/milkypostman/melpa#recipe-format")

(defun imandra/init-imandra-mode ()
  (use-package imandra-mode
    :mode (("\\.iml$" . imandra-mode))
    :config
    (progn
      (if (and (equal imandra-mode-backend 'merlin)
               (configuration-layer/package-used-p 'merlin))
          (progn
            (require 'imandra-mode-merlin)
            (if (configuration-layer/package-used-p 'merlin-eldoc)
                (imandra-merlin-setup-eldoc))
            (if (configuration-layer/package-used-p 'merlin-company)
                (imandra-merlin-setup-company))))
      (if (and (equal imandra-mode-backend 'lsp)
               (configuration-layer/package-used-p 'lsp-mode))
          (require 'imandra-mode-lsp)))))

(defun imandra/init-ocamlformat ()
  (use-package ocamlformat
    :defer t
    :init
    (when imandra-format-on-save
      (require 'imandra-mode-ocamlformat))))

;; Copied from ocaml layer
(defun imandra/post-init-flycheck ()
  (spacemacs/enable-flycheck 'imandra-mode))

;; Copied from ocaml layer
(defun imandra/post-init-flycheck-ocaml ()
  (use-package flycheck-ocaml
    :if (and (configuration-layer/package-used-p 'flycheck)
             (equal imandra-mode-backend 'merlin))
    :defer t
    :init
    (with-eval-after-load 'merlin
      (setq merlin-error-after-save nil)

      ;; Copied from flycheck-ocaml
      ;; TODO: create flycheck-imandra package?
      (flycheck-define-generic-checker 'imandra-merlin
        "A syntax checker for Imandra using Merlin Mode.

See URL `https://github.com/the-lambda-church/merlin'."
        :start #'flycheck-ocaml-merlin-start
        :verify #'flycheck-verify-ocaml-merlin
        :modes '(imandra-mode)
        :predicate (lambda () (and merlin-mode
                                   ;; Don't check if Merlin's own checking is
                                   ;; enabled, to avoid duplicate overlays
                                   (not merlin-error-after-save))))

      (defun flycheck-imandra-setup ()
        "Setup Flycheck Imandra.

Add `imandra-merlin' to `flycheck-checkers'."
        (interactive)
        (add-to-list 'flycheck-checkers 'imandra-merlin))

      (flycheck-imandra-setup))))

(defun imandra/post-init-merlin ()
  (use-package merlin
    :defer t
    :init
    (if (equal imandra-mode-backend 'merlin)
        (progn
          ;; Copied from ocaml layer
          (add-to-list 'spacemacs-jump-handlers-imandra-mode
                       'spacemacs/merlin-locate)
          (add-hook 'imandra-mode-hook 'merlin-mode)
          (spacemacs/set-leader-keys-for-major-mode 'imandra-mode
            "cp" 'merlin-project-check
            "cv" 'merlin-goto-project-file
            "Ec" 'merlin-error-check
            "En" 'merlin-error-next
            "EN" 'merlin-error-prev
            "gb" 'merlin-pop-stack
            "gG" 'spacemacs/merlin-locate-other-window
            "gl" 'merlin-locate-ident
            "gi" 'merlin-switch-to-ml
            "gI" 'merlin-switch-to-mli
            "go" 'merlin-occurrences
            "hh" 'merlin-document
            "ht" 'merlin-type-enclosing
            "hT" 'merlin-type-expr
            "rd" 'merlin-destruct)
          (spacemacs/declare-prefix-for-mode 'tuareg-mode "mc" "compile/check")
          (spacemacs/declare-prefix-for-mode 'tuareg-mode "mE" "errors")
          (spacemacs/declare-prefix-for-mode 'tuareg-mode "mg" "goto")
          (spacemacs/declare-prefix-for-mode 'tuareg-mode "mh" "help")
          (spacemacs/declare-prefix-for-mode 'tuareg-mode "mr" "refactor"))

      ;; Otherwise disable merlin-mode (automatically enabled by tuareg-mode)
      (add-hook 'imandra-mode-hook (lambda () (merlin-mode -1))))))

(defun imandra/post-init-lsp-mode ()
  (use-package lsp-mode
    :if (equal imandra-mode-backend 'lsp)
    :defer t
    :init (add-hook 'imandra-mode-hook 'lsp-mode)))

;;; packages.el ends here
