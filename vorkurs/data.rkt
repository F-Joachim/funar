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