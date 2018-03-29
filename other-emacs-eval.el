;;; other-emacs-eval.el --- Evaluate the Emacs Lisp expression in other Emacs -*- lexical-binding: t; -*-

;; Copyright (C) 2018  Xu Chunyang

;; Author: Xu Chunyang <mail@xuchunyang.me>
;; Homepage: https://github.com/xuchunyang/other-emacs-eval
;; Package-Requires: ((emacs "25.1") (async "1.9.2"))
;; Keywords: tools
;; Created: Thu, 29 Mar 2018 17:28:30 +0800

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; Eval the Emacs Lisp expression in other Emacs.

;;; Code:

(require 'async)

;;;###autoload
(defun other-emacs-eval (form &optional emacs)
  "Evaluate FORM with EMACS and return its value.
If EMACS is omitted or nil, the same Emacs as this one will be
used.  If EMACS is non-nil, it should be the name (or the
absolute file name) of an Emacs."
  (if (not emacs)
      (async-get (async-start (lambda () (eval form))))
    (let ((path (executable-find emacs)))
      (if path
          (let ((invocation-directory (file-name-directory path))
                (invocation-name (file-name-nondirectory path)))
            (async-get (async-start (lambda () (eval form)))))
        (user-error "Emacs not found: %s" emacs)))))

(defun other-emacs-eval-read-emacs ()
  (read-shell-command "Emacs: " "emacs"))

;;;###autoload
(defun other-emacs-eval-last-sexp (emacs &optional insert-value)
  "Evaluate sexp before point with EMACS; print value in the echo area.
With prefix argument or INSERT-VALUE is non-nil, print value into
current buffer."
  (interactive (list (other-emacs-eval-read-emacs)
                     current-prefix-arg))
  (let ((value (other-emacs-eval (elisp--preceding-sexp) emacs)))
    (prin1 value (if insert-value (current-buffer) t))))

;;;###autoload
(defun other-emacs-eval-print-last-sexp (emacs)
  "Evaluate sexp before point with EMACS; print value into current buffer."
  (interactive (list (other-emacs-eval-read-emacs)))
  (let ((standard-output (current-buffer)))
    (terpri)
    (other-emacs-eval-last-sexp emacs t)
    (terpri)))

(provide 'other-emacs-eval)
;;; other-emacs-eval.el ends here
