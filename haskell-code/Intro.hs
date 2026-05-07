{-# LANGUAGE InstanceSigs #-}
module Intro where

-- >>> x
-- 25
x :: Integer
x = 23 + 2

double :: Integer -> Integer
double = (* 2)

data Pet =
    Dog
  | Cat
  | Snake
  deriving Show

isCute :: Pet -> Bool
isCute Dog   = True
isCute Cat   = True
isCute Snake = False

data Liveness
  = Alive
  | Dead
  deriving Show

type Weight = Integer

-- data Dillo = MkDillo 
--   { dilloLiveness :: Liveness
--   , dilloWeight :: Weight }
--   deriving Show

-- dillo1 :: Dillo
-- dillo1 = MkDillo { dilloLiveness = Alive, dilloWeight = 10 }

-- dillo2 :: Dillo
-- dillo2 = MkDillo Alive 10


-- runOverDillo :: Dillo -> Dillo
-- runOverDillo dillo = dillo { dilloLiveness = Dead }

data Animal = 
    MkDillo { dilloLiveness :: Liveness
          , dilloWeight :: Weight }
  | MkParrot String Weight
  deriving Show

dillo1 :: Animal
dillo1 = MkDillo { dilloLiveness = Alive, dilloWeight = 10 }

dillo2 :: Animal
dillo2 = MkDillo Dead 8

parrot1 :: Animal
parrot1 = MkParrot "Welcome!" 1

parrot2 :: Animal
parrot2 = MkParrot "Hello!" 2

runOverAnimal :: Animal -> Animal
runOverAnimal (MkDillo _ w) = MkDillo Dead w
runOverAnimal (MkParrot _ w) = MkParrot "..." w
