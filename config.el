;;; config.el --- Imandra Layer configuration File for Spacemacs
;;
;; Copyright (c) 2020 Imandra, Inc.
;;
;; Author: Matt Bray <matt@imandra.ai>
;; URL: https://github.com/AestheticIntegration/imandra-spacemacs-layer
;;
;; This file is not part of GNU Emacs.
;;

;; Variables
(defcustom imandra-mode-backend
  'merlin
  "Backend to use"
  :type '(choice
          (const :tag "LSP" lsp)
          (const :tag "merlin" merlin)))
