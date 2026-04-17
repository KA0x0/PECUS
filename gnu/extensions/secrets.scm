;;; GNU Guix --- Functional package management for GNU
;;;
;;; This file is NOT part of GNU Guix.
;;;
;;; This program is free software: you can redistribute it and/or modify
;;; it under the terms of the GNU General Public License as published by
;;; the Free Software Foundation, either version 3 of the License, or
;;; (at your option) any later version.
;;;
;;; This program is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Code:

(define-module (guix extensions secrets)
  #:use-module (guix ui)
  #:use-module (guix scripts)
  #:use-module (ice-9 match)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-37)
  #:export (guix-secrets))


;;;
;;; Command-line options.
;;;

(define (show-help)
  (display "Usage: guix secrets [OPTIONS] COMMAND

Unfortunately, there are third-party applications that store clear-text
passwords in their configuration files, such as for instance Bacula.

We generate a template configuration file that can be placed in the
world-readable store and define an activation service that creates the
real configuration file that is only accessibly by the service process.

The template will contain a special pattern instead of the actual password,
such as for instance %key% and the activation service will replace these
with the real values using a special secrets file that's only accessible
by the root user.

Unless you specify a custom file name, this tool needs to be run as root.
")

  (display "
   -s, --secrets=PATH    specify path name of the secrets file
                         (default /etc/guix/secrets.db)
")
  (display "
   --force               force the action
")
  (display "
   -h, --help            display this help and exit")
  (newline)
  (display "
General commands:

   create                create as empty new secrets file

                         This will not replace an existing file
                         unless --force has been given.

   list                  list keys in the secrets file

   remove KEY            remove entry KEY

   scan PATH             scan document FILE and print all templates
                         found in it in the same format as list.

   verify PATH           scan document FILE and verify that an entry
                         of the correct type exists in the database
                         for each template found in it.

Password commands:

   get KEY               retrieve secret for KEY

   generate KEY          generate new random password for KEY

                         If the key already exists, an error will
                         be reported unless --force has been given.

   passwd KEY            prompt for a new password for key KEY

                         If the key already exists, an error will
                         be reported unless --force has been given.

Text and Blob commands:

   read KEY              retrieve text entry KEY

   write KEY             write text entry KEY

   Without any additional arguments, these will read / write a text
   using standard input / output.

   To read / write a file instead, use

       --file=PATH       read / write file located at PATH.

   To read / write a Blob entry, use

       --blob=PATH       read / write blob entry.
")

  (newline)
  (newline))


(define %options
  (list
   (option '(#\h "help") #f #f
           (lambda _
             (show-help)
             (exit 0)))
   (option '(#\s "secrets") #t #f
           (lambda (opt name arg result)
             (alist-cons 'secrets arg result)))
   (option '("file") #t #f
           (lambda (opt name arg result)
             (alist-cons 'file arg result)))
   (option '("blob") #t #f
           (lambda (opt name arg result)
             (alist-cons 'blob arg result)))
   (option '("force") #f #f
           (lambda (opt name _ result)
             (alist-cons 'force-flag #t result)))))

(define %default-secrets-file "/etc/guix/secrets.db")

(define %default-options
  `((secrets . ,(or (getenv "GUIX_SECRETS_FILE") %default-secrets-file))
    (force-flag . #f)))

(define %actions '("create" "list"))

(define (execute-action name . args)
  (let* ((module (resolve-interface '(baulig build secrets-service)))
         (proc (string->symbol (string-append "secrets-file-action-" (symbol->string name))))
         (action (module-ref module proc)))
    (format #t "ACTION: ~a - ~a - ~a~%" name module action)
    (format #t "ACTION ARGS: ~s~%" args)
    (apply action args)))

(define (report-error . args)
  (format (current-error-port) "guix secrets: ~a~%"
          (apply format #f args))
  (exit -1))

(define (check-force action)
  (case action
    ((create
      generate
      passwd
      write)
     #t)
    (else (report-error "~a: cannot --force this action~%" action))))

(define (check-file-arg action)
  (case action
    ((read
      write)
     #t)
    (else (report-error "~a: cannot use --file with this action~%" action))))

(define (check-blob-arg action)
  (case action
    ((read
      write)
     #t)
    (else (report-error "~a: cannot use --blob with this action~%" action))))

(define (parse-sub-command arg result)
  (let ((action (assoc-ref result 'action))
        (arguments (assoc-ref result 'arguments)))
    (cond (arguments
           (assoc-set! result 'arguments (cons arg arguments)))
          (action
           (alist-cons 'arguments (list arg) result))
          (else
           (let ((action (string->symbol arg)))
             (case action
               ((create
                 list
                 generate
                 get
                 passwd
                 read
                 remove
                 scan
                 verify
                 write)
                (alist-cons 'action action result))
               (else (report-error "~a: unknown action~%" action))))))))

(define-command (guix-secrets . args)
  (category plumbing)
  (synopsis "manage a file containing clear-text passwords")

  (with-error-handling
    (let* ((opts (parse-command-line args %options (list %default-options)
                                     #:build-options? #f
                                     #:argument-handler parse-sub-command))
           (file-name (assq-ref opts 'secrets))
           (action (assoc-ref opts 'action))
           (force-flag (assoc-ref opts 'force-flag))
           (file (assoc-ref opts 'file))
           (blob (assoc-ref opts 'blob))
           (arguments (or (assoc-ref opts 'arguments) '()))
           (root-path (canonicalize-path
                       (string-append (dirname (current-filename)) "/../../packages"))))
      (when force-flag
        (check-force action))
      (when file
        (check-file-arg action))
      (when blob
        (check-blob-arg action))
      (when (and file blob)
        (report-error "--file and --blob are mutually exclusive"))
      (format #t "TEST: ~a - ~a - ~a - ~a~%" opts action arguments root-path)
      (unless action
        (report-error "No command given."))
      (add-to-load-path root-path)
      (let* ((force-arg (if force-flag '(force) '()))
             (file-arg (if file (list (list 'file file)) '()))
             (blob-arg (if blob (list (list 'blob blob)) '()))
             (opts (append force-arg file-arg blob-arg)))
        (apply execute-action action file-name opts (reverse arguments))))))
    