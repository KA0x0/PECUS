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

(define-module (pecus services secrets)
  #:use-module (gnu services)
  #:use-module (gnu services base)
  #:use-module (gnu services admin)
  #:use-module (gnu services shepherd)
  #:use-module (gnu system shadow)
  #:use-module (gnu packages admin)
  #:use-module ((gnu packages guile) #:select (guile-sqlite3))
  #:use-module ((gnu packages gnupg) #:select (guile-gcrypt))
  #:use-module (guix gexp)
  #:use-module (guix hash)
  #:use-module (guix records)
  #:use-module (guix modules)
  #:use-module (guix store)
  #:use-module (pecus services account)
  #:use-module (pecus services activation)
  #:use-module (pecus services parameters)
  #:use-module (pecus services config-serialization)
  #:use-module (ice-9 match)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-11)
  #:use-module (srfi srfi-26)
  #:export (<secrets-configuration>
            secrets-configuration

            <secrets-service>
            secrets-service
            secrets-service-configuration
            secrets-service-account
            secrets-service-database
            secrets-service-requirements
            secrets-service-private-directory
            secrets-service-output-file
            secrets-service-extra-parameters)
  #:export-syntax (create-secrets
                   create-secrets-section))

(define-syntax get-secrets-name
  (lambda (x)
    (syntax-case x (daemon
                    account-configuration account-expression account-reference
                    daemon-account daemon-account-expression)
      ((_ name)
       (identifier? #'name)
       #'(cons 'name (account-configuration (id 'name))))
      ((_ (account-expression form))
       #'(cons (get-service-account-id form) form))
      ((_ (account-reference name))
       (identifier? #'name)
       #'(cons 'name (account-reference (id 'name))))
      ((_ (account-reference name reference))
       (and (identifier? #'name) (identifier? #'reference))
       #'(cons 'name (account-reference (id 'reference))))
      ((_ (account-configuration name clause ...))
       #'(cons name (account-configuration (id name) clause ...)))
      ((_ (daemon-account-expression form))
       #'(cons (get-service-account-id form) (make-daemon-account form)))
      ((_ (daemon-account name clause ... (daemon daemon-clause ...)))
       #'(cons name (make-daemon-account
                     (account-configuration (id name) clause ...)
                     (daemon-account-configuration daemon-clause ...))))
      ((_ (daemon-account name clause ...))
       #'(cons name (make-daemon-account
                     (account-configuration (id name) clause ...)
                     (daemon-account-configuration)))))))

(define-syntax get-secrets-parameters
  (lambda (x)
    (define (make-field-name name)
      (datum->syntax name
                     (symbol-append (syntax->datum name) '-extra-parameters)))
    (syntax-case x (function gexp)
      ((_ secrets _)
       #'secrets)
      ((_ secrets type function name)
       #'(type
          (inherit secrets)
          (extra-parameters name)))
      ((_ secrets type gexp name)
       #'(type
          (inherit secrets)
          (extra-parameters name)))
      ((_ secrets type (name value))
       (identifier? #'name)
       (with-syntax ((extra-parameters-field (make-field-name #'type)))
         #'(let* ((extra-parameters (extra-parameters-field secrets)))
             (type
              (inherit secrets)
              (extra-parameters (acons 'name value extra-parameters))))))
      ((_ secrets type (name value) parameters ...)
       #'(get-secrets-parameters (get-secrets-parameters secrets type (name value)) type parameters ...)))))

(define-syntax get-secrets-options
  (syntax-rules (root-owned-secrets)
    ((_ secrets)
     secrets)
    ((_ secrets root-owned-secrets)
     (secrets-configuration (inherit secrets) (root-owned-secrets? #t)))
    ((_ _ other)
     (syntax-error "Invalid secrets-configuration option" other))
    ((_ secrets first second rest ...)
     (get-secrets-options (get-secrets-options secrets first) second rest ...))))

(define-syntax get-section-options
  (syntax-rules (make-executable group-readable parameters-only place-in-root-directory)
    ((_ secrets)
     secrets)
    ((_ secrets make-executable)
     (secrets-section (inherit secrets) (make-executable? #t)))
    ((_ secrets group-readable)
     (secrets-section (inherit secrets) (group-readable? #t)))
    ((_ secrets parameters-only)
     (secrets-section (inherit secrets) (parameters-only? #t)))
    ((_ secrets place-in-root-directory)
     (secrets-section (inherit secrets) (place-in-root-dir? #t)))
    ((_ secrets other)
     (syntax-error "Invalid secrets-section option" other))
    ((_ secrets first second rest ...)
     (get-section-options (get-section-options secrets first) second rest ...))))

(define-syntax get-secrets-section
  (lambda (x)
    (define (make-fields-name name)
      (datum->syntax name
                     (symbol-append (syntax->datum name) '-configuration-fields)))

    (syntax-case x (main expand-options expand-rest
                         options template serialize store-file extra-parameters)
      ((_ main (store-file output-file template-file))
       #'(internal-make-secrets-section template-file output-file '() #f #f #f #f))
      ((_ main (template output-file contents))
       #'(let* ((template-file (mixed-text-file output-file contents)))
           (internal-make-secrets-section template-file output-file '() #f #f #f #f)))
      ((_ main (serialize output-file type configuration))
       (identifier? #'type)
       (with-syntax ((fields-name (make-fields-name #'type)))
         #'(let* ((output (serialize-configuration configuration fields-name))
                  (template-file (mixed-text-file output-file output)))
             (internal-make-secrets-section template-file output-file '() #f #f #f #f))))
      ((_ expand-options section)
       #'section)
      ((_ expand-rest section)
       #'section)
      ((_ expand-rest section (extra-parameters parameter ...))
       #'(get-secrets-parameters secrets secrets-section parameter ...))
      ((_ expand-options section (options option ...) rest ...)
       #'(let ((this-option (get-section-options section option ...)))
           (get-secrets-section expand-rest this-option rest ...)))
      ((_ expand-options section rest ...)
       #'(get-secrets-section expand-rest section rest ...)))))


(define-syntax expand-config
  (syntax-rules (options extra-sections expand-main expand-options expand-rest)
    ((_ expand-options config)
     config)
    ((_ expand-rest config)
     config)
    ((_ expand-main config (extra-sections sections) rest ...)
     (let ((new-config (secrets-configuration (inherit config)
                                              (extra-sections sections))))
       (expand-config expand-options new-config rest ...)))
    ((_ expand-main config rest ...)
     (expand-config expand-options config rest ...))
    ((_ expand-rest config (extra-parameters parameter ...))
     (get-secrets-parameters config secrets-configuration parameter ...))
    ((_ expand-options config (options option ...) rest ...)
     (expand-config expand-rest (get-secrets-options config option ...) rest ...))
    ((_ expand-options config rest ...)
     (expand-config expand-rest config rest ...))))


(define-syntax expand-section
  (syntax-rules (options expand-options expand-rest)
    ((_ expand-options section)
     section)
    ((_ expand-rest section)
     section)
    ((_ expand-rest section (extra-parameters parameter ...))
     (get-secrets-parameters section secrets-section parameter ...))
    ((_ expand-options section (options option ...) rest ...)
     (expand-section expand-rest (get-section-options section option ...) rest ...))
    ((_ expand-options section rest ...)
     (expand-section expand-rest section rest ...))))


(define-syntax create-secrets-section
  (lambda (x)
    (syntax-case x ()
      ((_ section)
       #'(get-secrets-section main section))
      ((_ section rest ...)
       (begin
         (with-syntax ((section-syntax #'(create-secrets-section section)))
           #'(expand-section expand-options section-syntax rest ...)))))))


(define-syntax create-secrets
  (lambda (x)
    (syntax-case x (main-section)
      ((_ name-pat (main-section section options ...) rest ...)
       (begin
         (with-syntax ((main-section-syntax #'(create-secrets-section section options ...))
                       (name-and-account #'(get-secrets-name name-pat)))
           #'(let* ((secrets (secrets-configuration
                              (name (car name-and-account))
                              (account (cdr name-and-account))
                              (main-section main-section-syntax))))
               (expand-config expand-main secrets rest ...)))))
      ((_ name-pat section rest ...)
       (with-syntax ((main-section-syntax #'(create-secrets-section section))
                     (name-and-account #'(get-secrets-name name-pat)))
         #'(let* ((secrets (secrets-configuration
                            (name (car name-and-account))
                            (account (cdr name-and-account))
                            (main-section main-section-syntax))))
             (expand-config expand-main secrets rest ...)))))))


(define-record-type* <secrets-section>
  secrets-section
  internal-make-secrets-section
  secrets-section?

  (template-file        secrets-section-template-file)
  (output-file          secrets-section-output-file)

  (extra-parameters     secrets-section-extra-parameters)
  (make-executable?     secrets-section-make-executable?)
  (group-readable?      secrets-section-group-readable?)
  (place-in-root-dir?   secrets-section-place-in-root-dir?)
  (parameters-only?     secrets-section-parameters-only?))


(define-record-type* <secrets-configuration>
  secrets-configuration
  make-secrets-configuration
  secrets-configuration?

  (name                 secrets-configuration-name)
  (account              secrets-configuration-account)
  (main-section         secrets-configuration-main-account)

  (extra-sections       secrets-configuration-extra-sections        (default '()))

  (extra-parameters     secrets-configuration-extra-parameters      (default '()))

  (root-owned-secrets?  secrets-configuration-root-owned-secrets?   (default #f)))


(define-record-type* <secrets-service-section>
  secrets-service-section
  make-secrets-service-section
  secrets-service-section?

  (template-file        secrets-service-section-template-file)
  (output-file          secrets-service-section-output-file)

  (extra-parameters     secrets-service-section-extra-parameters)
  (make-executable?     secrets-service-section-make-executable?)
  (group-readable?      secrets-service-section-group-readable?)
  (place-in-root-dir?   secrets-service-section-place-in-root-dir?)
  (parameters-only?     secrets-service-section-parameters-only?))


(define-record-type* <secrets-service>
  secrets-service
  make-secrets-service
  secrets-service?

  (name                 secrets-service-name)
  (account              secrets-service-account)
  (database             secrets-service-database)
  (requirements         secrets-service-requirements)
  (private-directory    secrets-service-private-directory)
  (output-file          secrets-service-output-file)
  (main-section         secrets-service-main-section)
  (root-owned-secrets?  secrets-service-root-owned-secrets?)
  (extra-sections       secrets-service-extra-sections)
  (extra-parameters     secrets-service-extra-parameters))


(define (file-like-to-name file)
  (cond ((plain-file? file)
         (plain-file-name file))
        ((computed-file? file)
         (computed-file-name file))
        (else file)))


(define (secrets-activation-action service)
  (match-records* ((service <secrets-service> main-section extra-sections))
      (let ((main-action (create-activation-section service main-section))
            (extra-actions (map (cut create-activation-section service <>) extra-sections)))
        #~(begin
            #$main-action
            #$@extra-actions))))


(define (create-activation-section service section)
  (match-records* ((service <secrets-service> account database private-directory
                            root-owned-secrets?)
                   (account <service-account> id user group working-directory
                            pid-directory-group)
                   (section <secrets-service-section> template-file output-file
                            make-executable? group-readable? parameters-only?
                            extra-parameters))

      (define regular-activation-action
        #~(begin
            (format #t "Activating secret: ~a - ~a~%" '#$id #$database)
            (use-modules (srfi srfi-1))
            (let* ((secrets-file (secrets-file-open #$database))
                   (real-user (if #$root-owned-secrets? "root" #$user))
                   (real-group (if #$root-owned-secrets? "root" #$group))
                   (uid (passwd:uid (getpw real-user)))
                   (gid (group:gid (getgr real-group)))
                   (output-directory (dirname #$output-file))
                   (directory-mode (if #$group-readable? #o750 #o700))
                   (file-mode (if #$group-readable? #o640 #o600))
                   (default-parameters
                     `((user . ,#$user)
                       (group . ,#$group)
                       (working-directory . ,#$working-directory)
                       ,@(if #$(maybe-value-set? pid-directory-group)
                             `((pid-directory-gid . ,(group:gid (getgr #$pid-directory-group))))
                             '())
                       #$@extra-parameters))
                   (parameters
                    (fold
                     (lambda (arg iter)
                       (acons (car arg) (cdr arg) iter))
                     default-parameters `(#$@extra-parameters))))
              (format #t "Activating secret #1: ~a - ~a / ~a / ~a - ~a - ~a - ~a~%"
                      #$template-file #$root-owned-secrets? #$user #$group #$working-directory
                      #$output-file parameters)
              (create-directory-with-owner #$private-directory uid gid #o700)
              (unless (or (equal? #$working-directory output-directory)
                          (equal? #$private-directory output-directory))
                (format #t "Creating output directory: ~a - ~a / ~a - ~a~%"
                        output-directory uid gid directory-mode)
                (create-directory-with-owner output-directory uid gid directory-mode))
              (secrets-file-substitute secrets-file #$template-file #$output-file
                                       #:working-directory #$private-directory
                                       #:user uid #:group gid #:file-mode file-mode
                                       #:parameters parameters))))

    (define parameters-only-activation-action
      #~(begin
          (format #t "Activating parameter-only secret: ~a~%" '#$id)
          (use-modules (srfi srfi-1))
          (let* ((real-user (if #$root-owned-secrets? "root" #$user))
                 (real-group (if #$root-owned-secrets? "root" #$group))
                 (uid (passwd:uid (getpw real-user)))
                 (gid (group:gid (getgr real-group)))
                 (directory-mode (if #$group-readable? #o750 #o700))
                 (file-mode (if #$make-executable?
                                (if #$group-readable? #o750 #o700)
                                (if #$group-readable? #o640 #o600)))
                 (output-directory (dirname #$output-file))
                 (default-parameters `((user . ,#$user)
                                       (group . ,#$group)
                                       (working-directory . ,#$working-directory)
                                       #$@extra-parameters))
                 (parameters (fold
                              (lambda (arg iter)
                                (acons (car arg) (cdr arg) iter))
                              default-parameters `(#$@extra-parameters))))
            (format #t "Activating secret #1: ~a - ~a / ~a / ~a - ~a - ~a - ~a~%"
                    #$template-file #$root-owned-secrets? #$user #$group #$working-directory
                    #$output-file parameters)
            (create-directory-with-owner #$private-directory uid gid #o700)
            (unless (or (equal? #$working-directory output-directory)
                        (equal? #$private-directory output-directory))
              (format #t "Creating output directory: ~a - ~a / ~a - ~a~%"
                      output-directory uid gid directory-mode)
              (create-directory-with-owner output-directory uid gid directory-mode))
            (secrets-file-substitute/parameters-only #$template-file #$output-file parameters
                                                     #:user uid #:group gid #:file-mode file-mode))))

    (if parameters-only?
        parameters-only-activation-action
        regular-activation-action)))


(define (secrets-service-activation service)
  (match-records* ((service <secrets-service> name account main-section))
      (let* ((id (service-account-id account))
             (real-name (symbol-append 'secrets-service- (or name id)))
             (requirement (symbol-append 'activation-task-account- id)))
        (activation-task
         (id real-name)
         (requirements `(,requirement))
         (modules '((guix base16)
                    (guix build utils)
                    (pecus build utils)
                    (pecus build secrets-service)
                    (pecus build secrets-utils)))
         (extensions (list guile-sqlite3 guile-gcrypt))
         (action (secrets-activation-action service))))))


(define-public secrets-service-type
  (service-type (name 'secrets)
                (extensions
                 (list (service-extension activation-task-service-type
                                          secrets-service-activation)))
                (description
                 "Secrets service activation.")))


(define* (resolve-extra-parameters configuration #:key service-account parameters)
  (match-records* ((configuration <secrets-configuration> extra-parameters))
      (cond ((list? extra-parameters)
             extra-parameters)
            ((gexp? extra-parameters)
             extra-parameters)
            (else
             (throw 'wrong-type-arg extra-parameters)))))


(define* (resolve-secrets-section configuration
                                  #:key working-directory private-directory
                                  parent-parameters)
  (match-records* ((configuration <secrets-section> template-file output-file
                                  make-executable? parameters-only? group-readable?
                                  place-in-root-dir? extra-parameters))
      (let ((output-file (string-append
                          (if place-in-root-dir? working-directory private-directory)
                          "/" output-file)))
        (secrets-service-section
         (template-file template-file)
         (output-file output-file)
         (make-executable? make-executable?)
         (group-readable? group-readable?)
         (place-in-root-dir? place-in-root-dir?)
         (parameters-only? parameters-only?)
         (extra-parameters #~(#$@parent-parameters #$@extra-parameters))))))


(define* (resolve-parameterized-secrets-service configuration
                                                #:key service-account parameters)
  (match-records* ((configuration <secrets-configuration> name account main-section
                                  root-owned-secrets? extra-sections extra-parameters)
                   (parameters <system-parameters>
                               service-root service-run-root secrets-database)
                   (service-account <service-account> id working-directory daemon-account?
                                    log-directory log-file-path pid-directory pid-file-path))
      (let* ((requirement (symbol-append 'activation-task-secrets-service- (or name id)))
             (resolved-extra-parameters (resolve-extra-parameters configuration #:service-account service-account
                                                                  #:parameters parameters))
             (daemon-parameters (if daemon-account?
                                    `((log-file . ,log-file-path)
                                      (log-directory . ,log-directory)
                                      (pid-file . ,pid-file-path)
                                      (pid-directory . ,pid-directory)
                                      (service-root . ,service-root)
                                      (service-run-root . ,service-run-root))
                                    '()))
             (all-parameters #~(#$@daemon-parameters #$@resolved-extra-parameters))
             (private-directory (string-append working-directory "/private"))
             (main-section (resolve-secrets-section main-section #:private-directory private-directory
                                                    #:working-directory working-directory
                                                    #:parent-parameters all-parameters))
             (extra-sections (map (cut resolve-secrets-section <> #:private-directory private-directory
                                       #:working-directory working-directory
                                       #:parent-parameters all-parameters) extra-sections))
             (output-file (secrets-service-section-output-file main-section)))

        (secrets-service
         (name name)
         (account service-account)
         (database secrets-database)
         (requirements `(user-processes ,requirement))
         (private-directory private-directory)
         (main-section main-section)
         (output-file output-file)
         (root-owned-secrets? root-owned-secrets?)
         (extra-sections extra-sections)
         (extra-parameters all-parameters)))))



(define-parameterized-service secrets
  (record-type <secrets-configuration>)
  (resolve resolve-parameterized-secrets-service)
  (parent service-account
          (lambda* (configuration #:key parameters)
            (secrets-configuration-account configuration)))
  (compose list)
  (extend list))

