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

--