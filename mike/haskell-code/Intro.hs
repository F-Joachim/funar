{-# LANGUAGE InstanceSigs #-}
module Intro where

x :: Integer
x = 23 + 2 * 21

y :: Integer
y = x + 5

-- Kommentar

-- >>> x 
-- 65

-- Zahl verdoppeln
double :: Integer -> Integer

-- >>> double 23
-- 46

-- double = \ x -> x * 2
double x = x * 2 -- syntaktischer Zucker

-- Zahl vervierfachen
quadruple :: Integer -> Integer
quadruple x =
    let d = double x -- lokale Gleichung
    in double d

-- Haustier ist eins der folgenden:
-- - Hund ODER
-- - Katze ODER
-- - Schlange
-- Aufzählung
data Pet = -- neuer Datentyp
    Dog | Cat | Snake
    deriving Show -- machen wir immer

-- Ist Haustier niedlich?
isCute :: Pet -> Bool

-- >>> isCute Dog
-- True
-- >>> isCute Snake
-- False

isCute pet =
    case pet of
        Dog -> True
        Cat -> True
        Snake -> False

-- Schablone
-- isCute pet =
--     case pet of
--         Dog -> ...
--         Cat -> ...
--         Snake -> ...
