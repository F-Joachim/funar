#lang deinprogramm/sdp

; Liste umdrehen
(: rev ((list-of %a) -> (list-of %a)))

(check-expect (rev (list 1 2 3 4))
              (list 4 3 2 1))

(define rev
  (lambda (list)
    (cond
      ((empty? list) empty)
      ((cons? list)
       (append-element
        (rev (rest list))
        (first list))))))

; Laufzeit für n Elemente:
; 1 + 2 + ... + n-1 + n = O(n^2)
; = (n+1 * n)/2 = n^2/2 + ... = O(n^2)
; Gauß'sche Summenformel

; Element an eine Liste anhängen
(: append-element ((list-of %a) %a -> (list-of %a)))

(check-expect (append-element (list 1 2 3) 4)
              (list 1 2 3 4))

(define append-element
  (lambda (list element)
    (cond
      ((empty? list) (cons element empty))
      ((cons? list)
       (cons (first list) 
             (append-element (rest list) element))))))