#lang deinprogramm/sdp/beginner
; Datenanalyse

; Haustier ist eins der folgenden:
; - Hund   ODER
; - Katze  ODER
; - Schlange
; Fallunterscheidung / Summe
; hier speziell: Aufzählung

; Signatur dafür:
(define pet
  (signature (enum "dog" "cat" "snake")))

; Ist ein Haustier niedlich?
(: cute? (pet -> boolean))

(check-expect (cute? "dog") #t)
(check-expect (cute? "cat") #t)
(check-expect (cute? "snake") #f)

; Gerüst
#;(define cute?
  (lambda (pet)
    ...))

; Schablone
#;(define cute?
  (lambda (pet)
    ; Fallunterscheidung => Verzweigung
    ; 1 Zweig pro Fall
    ; (<Bedingung> <Ergebnis>)
    (cond
      ((equal? pet "dog") ...)
      ((equal? pet "cat") ...)
      ((equal? pet "snake") ...))))

(define cute?
  (lambda (pet)
    ; Fallunterscheidung => Verzweigung
    ; 1 Zweig pro Fall
    ; (<Bedingung> <Ergebnis>)
    (cond
      ((equal? pet "dog") #t)
      ((equal? pet "cat") #t)
      ((equal? pet "snake") #f)
      (else #f))))

;(cute? "mouse")

; Uhrzeit besteht aus / hat folgende Eigenschaften:
; - Stunde  UND
; - Minute
; zusammengesetzte Daten / Produkt
(define-record time ; Signatur
  make-time ; Konstruktor
  (time-hour   natural) ; "natürliche Zahlen" 0,1,2,3,4,5...
  (time-minute natural)) ; Selektor / "Getter-Funktion"

(: make-time (natural natural -> time))
(: time-hour (time -> natural))
(: time-minute (time -> natural))

; 11 Uhr 15 Minuten
(define time1 (make-time 11 15))
; 14:23
(define time2 (make-time 14 23))

; Minuten seit Mitternacht
(: msm (time -> natural))

(check-expect (msm time1)
              675)
(check-expect (msm time2)
              863)

; Schablone
#;(define msm
  (lambda (time)
    ... (time-hour time) ...
    ... (time-minute time) ...))

(define msm
  (lambda (time)
    (+ (* (time-hour time) 60)
       (time-minute time))))

; aus den Minuten seit Mitternacht die Zeit berechnen

; Tier auf dem texanischen Highway
; - Gürteltier ODER
; - Papagei
; Fallunterscheidung, gemischte Daten
(define animal
  (signature (mixed dillo
                    parrot)))


; Gürteltier hat folgende Eigenschaften:
; - lebendig?   UND
; - Gewicht


; Zustand des Gürteltiers zu einem bestimmten Zeitpunkt
(define-record dillo
  make-dillo
  dillo? ; Prädikat
  (dillo-alive? boolean)
  (dillo-weight number))

(: make-dillo (boolean number -> dillo))
(: dillo-alive? (dillo -> boolean))
(: dillo-weight (dillo -> number))
(: dillo? (any -> boolean))

; lebendiges Gürteltier, 10kg
(define dillo1 (make-dillo #t 10))
; totes Gürteltier, 8kg
(define dillo2 (make-dillo #f 8))

; Gürteltier überfahren
(: run-over-dillo (dillo -> dillo))

(check-expect (run-over-dillo dillo1)
              (make-dillo #f 10))
(check-expect (run-over-dillo dillo2)
              dillo2 #;(make-dillo #f 8))

; Schablone
#;(define run-over-dillo
  (lambda (dillo)
    (make-dillo ... ...)
    ... (dillo-alive? dillo) ...
    ... (dillo-weight dillo) ...))

(define run-over-dillo
  (lambda (dillo)
    (make-dillo #f (dillo-weight dillo))))

; Gürteltier füttern, variable Menge
(: feed-dillo (dillo number -> dillo))

(check-expect (feed-dillo dillo1 2)
              (make-dillo #t 12))
(check-expect (feed-dillo dillo2 2)
              dillo2)

#;(define feed-dillo
  (lambda (dillo amount)
    (make-dillo
     (dillo-alive? dillo)
     (cond
       ((equal? (dillo-alive? dillo) #t)
        (+ (dillo-weight dillo) amount))
       ((equal? (dillo-alive? dillo) #f)
        (dillo-weight dillo))))))

(define feed-dillo
  (lambda (dillo amount)
    (define alive? (dillo-alive? dillo)) ; lokale Definition
    (define weight (dillo-weight dillo))
    (make-dillo
     alive?
     (if alive?
         (+ weight amount) ; "then" / Konsequente
         weight)
     #;(cond
       ((dillo-alive? dillo)
        (+ (dillo-weight dillo) amount))
       (else ; (not (dillo-alive? dillo))
        (dillo-weight dillo))))))

; Ein Papagei:
; - Satz UND
; - Gewicht
(define-record parrot
  make-parrot
  parrot? ; Prädikat
  (parrot-sentence string)
  (parrot-weight number))

(: parrot? (any -> boolean))

; Begrüßungspapagei, 1kg
(define parrot1 (make-parrot "Welcome!" 1))
(define parrot2 (make-parrot "Goodbye!" 2))

; Papagei überfahren
(: run-over-parrot (parrot -> parrot))

(check-expect (run-over-parrot parrot1)
              (make-parrot "" 1))

(define run-over-parrot
  (lambda (parrot)
    (make-parrot "" (parrot-weight parrot))))


; Tier überfahren
(: run-over-animal (animal -> animal))

(check-expect (run-over-animal dillo1)
              (make-dillo #f 10))
(check-expect (run-over-animal parrot1)
              (make-parrot "" 1))

(define run-over-animal
  (lambda (animal)
    (cond
      ((dillo? animal) (run-over-dillo animal))
      ((parrot? animal) (run-over-parrot animal)))))


; ... vs OO: 2 Methoden
; neues Tier auf dem Highway:
; Open/Closed: OO +, FP -
; neue Funktion:
; Open/Closed: FP +, OO -

; Datenmodellierung mit
; Fallunterscheidungen und         Summen     ODER-Daten
; zusammengesetzten Daten      und Produkten  UND-Daten


; Liste ist eins der folgenden:
; - die leere Liste   ODER
; - eine Cons-Liste aus erstem Element UND Rest-Liste
;                                               ^^^^^ Selbstbezug
(define list-of-numbers
  (signature (mixed empty-list
                    cons-list)))


(define-singleton empty-list ; Signatur
  empty ; Singleton
  empty?) ; Prädikat

#;(define-record empty-list
  make-empty-list
  empty?)

;(define empty (make-empty-list))

; Eine Cons-Liste besteht aus:
; - erstes Element
; - Rest-Liste
(define-record cons-list
  cons
  cons?
  (first number)
  (rest list-of-numbers)) ; Selbstbezug

; 1elementige Liste: 5
(define list1 (cons 5 empty))
; 2elementige Liste: 2 5
(define list2 (cons 2 (cons 5 empty)))
; 3elementige Liste: 2 5 8
(define list3         (cons 2 (cons 5 (cons 8 empty))))
; 4elementige Liste: 3 2 5 8
(define list4 (cons 3 list3))

; Liste aufsummieren
(: list-sum (list-of-numbers -> number))

(check-expect (list-sum list4)
              18)

; Schablone
#;(define list-sum
  (lambda (list)
    (cond
      ((empty? list) ...)
      ((cons? list)
       ... (first list) ...
       ... (list-sum (rest list)) ...))))

(define list-sum
  (lambda (list)
    (cond
      ((empty? list) 0) ; "neutrales Element der Addition"
      ((cons? list)
       (+ (first list)
          (list-sum (rest list)))))))

; Liste aufmultiplizieren
(: list-product (list-of-numbers -> number))

(check-expect (list-product list4)
              240)

(define list-product
  (lambda (list)
    (cond
      ((empty? list) 1) ; "das neutrale Element der Multiplikation"
      ((cons? list)
       (* (first list)
          (list-product (rest list)))))))

; Aus einer Liste alle ungeraden Zahlen extrahieren
(: extract-odds (list-of-numbers -> list-of-numbers))

(check-expect (extract-odds list4)
              (cons 3 (cons 5 empty)))

(define extract-odds
  (lambda (list)
    (cond
      ((empty? list) empty)
      ((cons? list)
       (if (odd? (first list))
           (cons (first list)
                 (extract-odds (rest list)))
           (extract-odds (rest list)))))))

; Abstraktion:
; - kopieren und ggf. umbennen (rekursive Aufrufe nicht vergessen)
; - Unterschiede durch (abstrakte) Namen ersetzen
; - Namen in lambda aufnehmen (rekursive Aufrufe nicht vergessen)

(define extract
  (lambda (p? list)
    (cond
      ((empty? list) empty)
      ((cons? list)
       (if (p? (first list))
           (cons (first list)
                 (extract p? (rest list)))
           (extract p? (rest list)))))))

; Rust - enum
; algebraischer Datentyp (beides)
; enum Animal { Dillo(bool, weight), Parrot(string, weight) }

; Java
; Produkt: record
; Summe: sealed interface / sealed class
; Aufzählungen: enum

; Kotlin
; Produkt: data class
; Summe: sealed interface / sealed class

; Scala
; enum (case class, sealed trait)

; C++
; Summen: variant

; C: tagged union

; Python
; Produkt: data class
; Summe: Klassen

; TypeScript
; Produkt: interface
; Summe: "tagged union"