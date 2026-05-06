#lang deinprogramm/sdp

; Liste umdrehen
(: rev ((list-of %a) -> (list-of %a)))

#;(check-expect (rev (list 1 2 3 4))
              (list 4 3 2 1))

(define rev
  (lambda (list)
    (cond
      ((empty? list) empty)
      ((cons? list)
       (append-element ; Kontext des Aufrufs von rev
        (rev (rest list))
        (first list))))))

; Standard-Implementierung für Speichern von Kontexten:
; Stack bzw. Array aus "Frames" für die Funktionsaufrufe
; -> hier Platzverbrauch proportional zur Länge der Liste
; => tendenziell "Stack-Overflow", weil Stack klein und fest in der Größe

; Laufzeit für n Elemente:
; 1 + 2 + ... + n-1 + n = O(n^2)
; = (n+1 * n)/2 = n^2/2 + ... = O(n^2)
; Gauß'sche Summenformel

; Element an eine Liste anhängen
(: append-element ((list-of %a) %a -> (list-of %a)))

#;(check-expect (append-element (list 1 2 3) 4)
              (list 1 2 3 4))

(define append-element
  (lambda (list element)
    (cond
      ((empty? list) (cons element empty))
      ((cons? list)
       (cons (first list) 
             (append-element (rest list) element))))))

; Liste umdrehen mit Zwischenergebnis
(: rev2 ((list-of %a) (list-of %a) -> (list-of %a)))

(check-expect (rev2 (list 1 2 3 4) empty)
              (list 4 3 2 1))

; acc: Liste der "bisher gesehenen Elemente", umgedreht

; endrekursiv / tail-recursive
(define rev2
  (lambda (list acc)
    ; Schleifeninvariante
    (cond
      ((empty? list) acc) ; haben alle Elemente gesehen
      ((cons? list)
       (rev2 (rest list) ; kein Kontext: tail call, benötigen keinen Platz auf dem "Stack"
             (cons (first list) acc))))))

; auf JVM: auch tail calls verbrauchen Platz auf dem Stack
; => Kotlin: tailrec, Scala: @tailrec, Clojure: loop

; TCO / "tail call optimization" vs. proper tail calls