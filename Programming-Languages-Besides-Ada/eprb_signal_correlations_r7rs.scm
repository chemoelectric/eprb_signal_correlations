;;; This is free and unencumbered software released into the public domain.
;;;
;;; Anyone is free to copy, modify, publish, use, compile, sell, or
;;; distribute this software, either in source code form or as a compiled
;;; binary, for any purpose, commercial or non-commercial, and by any
;;; means.
;;;
;;; In jurisdictions that recognize copyright laws, the author or authors
;;; of this software dedicate any and all copyright interest in the
;;; software to the public domain. We make this dedication for the benefit
;;; of the public at large and to the detriment of our heirs and
;;; successors. We intend this dedication to be an overt act of
;;; relinquishment in perpetuity of all present and future rights to this
;;; software under copyright law.
;;;
;;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
;;; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
;;; MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
;;; IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
;;; OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
;;; ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
;;; OTHER DEALINGS IN THE SOFTWARE.
;;;
;;; For more information, please refer to <https://unlicense.org>

;;
;; For R⁷RS-small Scheme, plus SRFI-27 random bits and Common
;; Lisp-style formatting.
;;
;; With CHICKEN, you will get far better performance from the compiler
;; than from the interpreter. :)
;;

(import (scheme base)
        (scheme inexact)
        (srfi 27))
(cond-expand
  (gauche  (import (srfi 28)))
  (chicken (import (format)))
  (guile   (import (ice-9 format))))

(define π      (* 4 (atan 1)))
(define π/2    (/ π 2))
(define π/3    (/ π 3))
(define π/4    (/ π 4))
(define π/6    (/ π 6))
(define π/8    (/ π 8))
(define π/180  (/ π 180))
(define 2π     (+ π π))

(define (signal? σ) (or (eq? σ '↶) (eq? σ '↷)))
(define (tag? τ) (or (eq? τ '⊕) (eq? τ '⊖)))

(define (assign-tag ζ σ)
  (unless (signal? σ) (error "assign-tag: expected signal" σ))
  (let* ((r (random-real))
         (τ (cond ((eq? σ '↶) (if (< r (expt (cos ζ) 2)) '⊕ '⊖))
                  ((eq? σ '↷) (if (< r (expt (sin ζ) 2)) '⊕ '⊖)))))
    (list τ σ)))

(define (collect-data ζ₁ ζ₂ run-length)
  (let loop ((data '())
             (n run-length))
    (if (zero? n)
        data
        (let ((σ (if (< (random-real) 0.5) '↶ '↷)))
          (loop (cons (list (assign-tag ζ₁ σ)
                            (assign-tag ζ₂ σ))
                      data)
                (- n 1))))))

(define (count-tagged-signal-pairs raw-data σ τ₁ τ₂)
  (unless (signal? σ) (error "count-pairs: expected signal" σ))
  (unless (tag? τ₁) (error "count-pairs: expected tag" τ₁))
  (unless (tag? τ₂) (error "count-pairs: expected tag" τ₂))
  (let loop ((n 0)
             (data raw-data))
    (if (null? data)
        n
        (let ((sigpair (car data)))
          (unless (eq? (cadr (car sigpair)) (cadr (cadr sigpair)))
            (error "count-tagged-signal-pairs: corrupted raw data"
                   sigpair))
          (if (and (eq? (cadr (car sigpair)) σ)
                   (eq? (car (car sigpair)) τ₁)
                   (eq? (car (cadr sigpair)) τ₂))
              (loop (+ n 1) (cdr data))
              (loop n (cdr data)))))))

(define (frequency raw-data σ τ₁ τ₂)
  (/ (count-tagged-signal-pairs raw-data σ τ₁ τ₂)
     (length raw-data)))

(define (cosine-sign φ) (if (negative? (cos φ)) -1 1))
(define (sine-sign φ)   (if (negative? (sin φ)) -1 1))
(define (cc-sign φ₁ φ₂) (* (cosine-sign φ₁) (cosine-sign φ₂)))
(define (cs-sign φ₁ φ₂) (* (cosine-sign φ₁) (sine-sign φ₂)))
(define (sc-sign φ₁ φ₂) (* (sine-sign φ₁) (cosine-sign φ₂)))
(define (ss-sign φ₁ φ₂) (* (sine-sign φ₁) (sine-sign φ₂)))

(define (estimate-ρ-from-raw-data raw-data φ₁ φ₂)
  (let* ((ac2c2 (frequency raw-data '↶ '⊕ '⊕))
         (ac2s2 (frequency raw-data '↶ '⊕ '⊖))
         (as2c2 (frequency raw-data '↶ '⊖ '⊕))
         (as2s2 (frequency raw-data '↶ '⊖ '⊖))
         (cs2s2 (frequency raw-data '↷ '⊕ '⊕))
         (cs2c2 (frequency raw-data '↷ '⊕ '⊖))
         (cc2s2 (frequency raw-data '↷ '⊖ '⊕))
         (cc2c2 (frequency raw-data '↷ '⊖ '⊖))

         (c2c2 (+ ac2c2 cc2c2))
         (c2s2 (+ ac2s2 cc2s2))
         (s2c2 (+ as2c2 cs2c2))
         (s2s2 (+ as2s2 cs2s2))

         (cc (* (cc-sign φ₁ φ₂) (sqrt c2c2)))
         (cs (* (cs-sign φ₁ φ₂) (sqrt c2s2)))
         (sc (* (sc-sign φ₁ φ₂) (sqrt s2c2)))
         (ss (* (ss-sign φ₁ φ₂) (sqrt s2s2)))

         (c12 (+ cc ss))
         (s12 (- sc cs)))

    (- (* c12 c12) (* s12 s12))))

(define (estimate-ρ φ₁ φ₂ run-length)
  (estimate-ρ-from-raw-data (collect-data φ₁ φ₂ run-length) φ₁ φ₂))

(define (print-bell-tests delta-φ)
  (let ((run-length 500000))
    (format #t "    φ₂ − φ₁ = ~6,2F°~%" (/ delta-φ π/180))
    (do ((i 0 (+ i 1)))
        ((= i 33))
      (let* ((φ₁ (* i π 1/16))
             (φ₂ (+ φ₁ delta-φ)))
        (format #t "    φ₁ = ~6,2F°  φ₂ = ~6,2F°   ρ est. = ~8,5F~%"
                (/ φ₁ π/180) (/ φ₂ π/180)
                (estimate-ρ φ₁ φ₂ run-length))))))

(format #t "~%")
(print-bell-tests (- π/8))
(format #t "~%")
(print-bell-tests π/8)
(format #t "~%")
(print-bell-tests (* -3 π/8))
(format #t "~%")
(print-bell-tests (* 3 π/8))
(format #t "~%")
