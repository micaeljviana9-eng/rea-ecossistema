;;; Restore the NAR read from standard input into the directory named
;;; by the first command-line argument.
;;;
;;; We cannot use "guix archive --extract" for this as it handles
;;; --extract from within a (with-store ...) form, and therefore
;;; insists on connecting to guix-daemon even though restoring a NAR
;;; needs nothing from the store.  This should be fixed in the future.

(use-modules (guix serialization))

(restore-file (current-input-port) (cadr (command-line)))
