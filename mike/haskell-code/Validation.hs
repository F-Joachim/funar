{-# LANGUAGE InstanceSigs #-}
module Validation where

data Car = MkCar { licensePlate :: String,
                   seatCount :: Integer }
    deriving Show

-- blöd:
car1 = MkCar "" (-1)

data Result a =
    Success a
  | Failure [String] -- Fehlermeldung
  deriving Show

instance Functor Result where
    fmap :: (a -> b) -> Result a -> Result b
    fmap f (Success a) = undefined
    fmap f (Failure errors) = undefined

mkCar :: String -> Integer -> Result Car
mkCar s n =
    if length s >= 2 && length s <= 14
    then if n >= 2
         then Success (MkCar s n)
         else Failure ["invalid seat count"]
    else if n >= 2
         then Failure ["invalid license-plate length"]
         else Failure ["invalid seat count", "invalid license-plate length"]