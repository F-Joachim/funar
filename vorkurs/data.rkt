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

; Tiere auf dem texanischen Highway

; Gürteltier hat folgende Eigenschaften:
; - lebendig?   UND
; - Gewicht

; Zustand des Gürteltiers zu einem bestimmten Zeitpunkt
(define-record dillo
  make-dillo
  (dillo-alive? boolean)
  (dillo-weight number))

(: make-dillo (boolean number -> dillo))
(: dillo-alive? (dillo -> boolean))
(: dillo-weight (dillo -> number))

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