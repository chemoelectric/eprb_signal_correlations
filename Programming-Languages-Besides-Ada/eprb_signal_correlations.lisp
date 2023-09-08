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

(defconstant π      pi)
(defconstant π/2    (/ π 2))
(defconstant π/3    (/ π 3))
(defconstant π/4    (/ π 4))
(defconstant π/6    (/ π 6))
(defconstant π/8    (/ π 8))
(defconstant π/180  (/ π 180))
(defconstant 2π     (+ π π))

;; We cannot call it a ‘signal’ in Common Lisp, because I guess that
;; is taken, so let us instead call it a ‘σignal’.
(defun σignalp (σ) (or (eq σ '↶) (eq σ '↷)))
(deftype σignal () '(satisfies σignalp))

;; And let us call a ‘tag’ a ‘τag’.
(defun τagp (τ) (or (eq τ '⊕) (eq τ '⊖)))
(deftype τag () '(satisfies τagp))

(defun assign-τag (ζ σ)
  (check-type σ σignal)
  (let* ((r (random 1.0))
         (τ (cond ((eq σ '↶) (if (< r (expt (cos ζ) 2)) '⊕ '⊖))
                  ((eq σ '↷) (if (< r (expt (sin ζ) 2)) '⊕ '⊖)))))
    (list τ σ)))

(defun collect-data (ζ₁ ζ₂ run-length)
  (loop repeat run-length
        collect (let ((σ (if (< (random 1.0) 0.5) '↶ '↷)))
                  (list (assign-τag ζ₁ σ)
                        (assign-τag ζ₂ σ)))))

(defun count-pairs (raw-data σ τ₁ τ₂)
  (check-type σ σignal)
  (check-type τ₁ τag)
  (check-type τ₂ τag)
  (let ((n 0))
    (loop for pair in raw-data
          do (progn
               (assert (eq (cadr (car pair)) (cadr (cadr pair))))
               (when (and (eq (cadr (car pair)) σ)
                          (eq (car (car pair)) τ₁)
                          (eq (car (cadr pair)) τ₂))
                 (setf n (1+ n)))))
    n))

(defun frequency (raw-data σ τ₁ τ₂)
  (/ (count-pairs raw-data σ τ₁ τ₂) (length raw-data)))

(defun cosine-sign (φ) (if (< (cos φ) 0) -1 1))
(defun sine-sign (φ)   (if (< (sin φ) 0) -1 1))
(defun cc-sign (φ₁ φ₂) (* (cosine-sign φ₁) (cosine-sign φ₂)))
(defun cs-sign (φ₁ φ₂) (* (cosine-sign φ₁) (sine-sign φ₂)))
(defun sc-sign (φ₁ φ₂) (* (sine-sign φ₁) (cosine-sign φ₂)))
(defun ss-sign (φ₁ φ₂) (* (sine-sign φ₁) (sine-sign φ₂)))

(defun estimate-ρ-from-raw-data (raw-data φ₁ φ₂)
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

(defun estimate-ρ (φ₁ φ₂ run-length)
  (estimate-ρ-from-raw-data (collect-data φ₁ φ₂ run-length) φ₁ φ₂))

(defun print-bell-tests (delta-φ)
  (let ((run-length 100000))
    (format t "~4Tφ₂ − φ₁ = ~6,2F°~%" (/ delta-φ π/180))
    (do ((i 0 (1+ i)))
        ((= i 33))
      (let* ((φ₁ (* i π 1/16))
             (φ₂ (+ φ₁ delta-φ)))
        (format t "~4Tφ₁ = ~6,2F°~19Tφ₂ = ~6,2F°~34Tρ est. = ~8,5F~%"
                (/ φ₁ π/180) (/ φ₂ π/180)
                (estimate-ρ φ₁ φ₂ run-length))))))

(terpri)
(print-bell-tests (- π/8))
(terpri)
(print-bell-tests π/8)
(terpri)
(print-bell-tests (* -3 π/8))
(terpri)
(print-bell-tests (* 3 π/8))
(terpri)
