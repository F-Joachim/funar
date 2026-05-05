#lang deinprogramm/sdp/beginner
; https://www.deinprogramm.de/
(require deinprogramm/sdp/image)
(define x
  (+ 23
     (* 2 21)))
(define y (+ x 5))

(define circle1 (circle 50 "solid" "red"))
(define square1 (square 100 "outline" "green"))
(define star1 (star 50 "solid" "gold"))
(define overlay1 (overlay star1 circle1))

#;(above
 (beside circle1 star1)
 (beside star1 circle1))

#;(above
 (beside square1 circle1)
 (beside circle1 square1))

; Abstraktion
; Voraussetzung: 2 Beispiele
; - kopieren (ein letztes Mal)
; - Unterschiede durch (abstrakte) Namen ersetzen
; - Namen in ein lambda aufnehmen

; Konstruktionsanleitungen

; Kurzbeschreibung
; quadratisches Kachelmuster generieren

; Signaturdeklaration
(: tile (image image -> image))



(define tile
  (lambda (image1 image2)
    (above
     (beside image1 image2)
     (beside image2 image1))))

;(tile circle1 star1)

#|
class C {
  // x steht für Speicherzelle, in der die Zahl drinsteht
  static int m(int x) {
     ... x ...
     x = x + 1;
     ... x ...
  }


  ... C.m(42) ...

|#


