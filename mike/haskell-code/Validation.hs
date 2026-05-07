{-# LANGUAGE InstanceSigs #-}
module Validation where

newtype LicensePlate = MkLicensePlate String
  deriving Show

mkLicensePlate :: String -> Result LicensePlate
mkLicensePlate s =
    if length s >= 2 && length s <= 14
    then Success (MkLicensePlate s)
    else Failure ["invalid license-plate length"]

newtype SeatCount = MkSeatCount Integer
  deriving Show

mkSeatCount :: Integer -> Result SeatCount
mkSeatCount n =
    if n >= 2
    then Success (MkSeatCount n)
    else Failure ["invalid seat count"]

data Car = MkCar { licensePlate :: LicensePlate,
                   seatCount :: SeatCount }
    deriving Show

-- blöd:
-- car1 = MkCar "" (-1)

data Result a =
    Success a
  | Failure [String] -- Fehlermeldung
  deriving Show

instance Functor Result where
    fmap :: (a -> b) -> Result a -> Result b
    fmap f (Success a) = Success (f a)
    fmap f (Failure errors) = Failure errors

-- >>> :info Applicative
-- type Applicative :: (* -> *) -> Constraint
-- class Functor f => Applicative f where
--   pure :: a -> f a
--   (<*>) :: f (a -> b) -> f a -> f b

-- fmap  ::   (a -> b) -> f a -> f b
-- (<*>) :: f (a -> b) -> f a -> f b

instance Applicative Result where
    pure :: a -> Result a
    pure = Success
    (<*>) :: Result (a -> b) -> Result a -> Result b
    (<*>) (Failure errors1) (Failure errors2) = Failure (errors1 ++ errors2)
    (<*>) (Failure errors) (Success a) = Failure errors
    (<*>) (Success fab) (Failure errors) = Failure errors
    (<*>) (Success fab) (Success a) = Success (fab a)

data Car1 = MkCar1 { seatCount1 :: SeatCount }

mkCar1 :: Integer -> Result Car1
mkCar1 n = fmap MkCar1 (mkSeatCount n)

x :: Result Integer
x = pure 1

-- (<$>) = fmap

resultMap2 :: (p -> q -> r) -> Result p -> Result q -> Result r
resultMap2 f resp resq =
--    pure f <*> resp <*> resq
    f <$> resp <*> resq

resultMap3 :: (p -> q -> r -> s) -> Result p -> Result q -> Result r -> Result s
resultMap3 f resp resq ress =
    pure f <*> resp <*> resq <*> ress

{-
resultMap2 f (Failure errors1) (Failure errors2) = Failure (errors1 ++ errors2)
resultMap2 f (Failure errors) (Success b) = Failure errors
resultMap2 f (Success a) (Failure errors) = Failure errors
resultMap2 f (Success a) (Success b) = Success (f a b)
-}

mkCar :: String -> Integer -> Result Car
mkCar s n =
--  resultMap2 MkCar (mkLicensePlate s) (mkSeatCount n)
  MkCar <$> (mkLicensePlate s) <*> (mkSeatCount n)

-- >>> mkCar "" 0
-- Failure ["invalid license-plate length","invalid seat count"]
{-
    if length s >= 2 && length s <= 14
    then if n >= 2
         then Success (MkCar s n)
         else Failure ["invalid seat count"]
    else if n >= 2
         then Failure ["invalid license-plate length"]
         else Failure ["invalid seat count", "invalid license-plate length"]
-}
