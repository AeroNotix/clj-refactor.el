;; This is an example of how you could set up this file. This setup
;; requires a directory called util in the project root and that the
;; util directory contains the testing tools ert and espuds.

(let* ((features-directory
        (file-name-directory
         (directory-file-name (file-name-directory load-file-name))))
       (project-directory
        (file-name-directory
         (directory-file-name features-directory))))
  (setq clj-refactor-root-path project-directory))

(add-to-list 'load-path clj-refactor-root-path)

(setq lein-profiles-file
  (expand-file-name "profiles.clj" "~/.lein"))

(setq lein-profiles-exists-p
  (file-exists-p lein-profiles-file))

(require 'clojure-mode)
(require 'clj-refactor)
(require 'espuds)
(require 'ert)
(require 's)
(require 'cider)

(defun clojure-expected-ns ()
  "Returns the namespace name that the file should have."
  (let* ((project-dir (file-truename
                       (locate-dominating-file default-directory
                                               "project.clj")))
         (relative (substring (file-truename (buffer-file-name)) (length project-dir) -4)))
    (replace-regexp-in-string
     "_" "-" (mapconcat 'identity (cdr (split-string relative "/")) "."))))

(Setup
 ;; hacking lein profiles
 (when lein-profiles-exists-p
   (copy-file "~/.lein/profiles.clj" "~/.lein/profiles.clj_ecukessave" "ok"))

 (cljr-add-keybindings-with-prefix "C-!")
 (add-hook 'clojure-mode-hook (lambda () (clj-refactor-mode))))

(Before
 ;; Before each scenario is run
 )

(defun save-all-buffers-dont-ask ()
  (dolist (buffer (buffer-list))
    (with-current-buffer buffer
      (let ((filename (buffer-file-name)))
        (when (and filename
                   (or (file-exists-p filename)
                       (s-ends-with? ".clj" filename)))
          (save-buffer))))))

(defun kill-matching-buffers-dont-ask (regexp &optional internal-too)
  (dolist (buffer (buffer-list))
    (let ((name (buffer-name buffer)))
      (when (and name (not (string-equal name ""))
                 (or internal-too (/= (aref name 0) ?\s))
                 (string-match regexp name))
        (kill-buffer buffer)))))

(defun revert-lein-profiles ()
  (if lein-profiles-exists-p
   (progn
     (copy-file "~/.lein/profiles.clj_ecukessave" "~/.lein/profiles.clj" "ok")
     (delete-file "~/.lein/profiles.clj_ecukessave"))
   (when (file-exists-p (expand-file-name "profiles.clj" "~/.lein"))
     (delete-file "~/.lein/profiles.clj"))))

(After
 (save-all-buffers-dont-ask)
 (kill-matching-buffers-dont-ask "clj")
 (delete-directory (expand-file-name "tmp" clj-refactor-root-path) t))

(Teardown
 ;; After when everything has been run
 ;; hacking lein profiles
 (revert-lein-profiles))
