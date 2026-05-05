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

(above
 (beside circle1 star1)
 (beside star1 circle1))