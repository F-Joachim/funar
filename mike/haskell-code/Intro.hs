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

doublePlus :: Integer -> Integer -> Integer
-- doublePlus x y = x * 2 + y

doublePlus = \ x -> \ y -> x * 2 + y

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

-- 1 Gleichung pro Fall
isCute Dog = True
isCute Cat = True
isCute Snake = False

-- isCute pet =
--     case pet of
--         Dog -> True
--         Cat -> True
--         Snake -> False

-- Schablone

-- isCute Dog = undefined
-- isCute Cat = undefined
-- isCute Snake = undefined

-- isCute pet =
--     case pet of
--         Dog -> ...
--         Cat -> ...
--         Snake -> ...

-- Gürteltier hat folgende Eigenschaften:
-- - lebendig oder tot   -UND-
-- - Gewicht

-- keine "boolean blindness"
data Liveness =
    Alive | Dead
    deriving Show

type Weight = Integer -- Typsynonym

{-
data Dillo =
    MkDillo { dilloLiveness :: Liveness,
              dilloWeight :: Weight }
    deriving Show

dillo1 :: Dillo
dillo1 = MkDillo { dilloLiveness = Alive, dilloWeight = 10 }

dillo2 :: Dillo

-- >>> dillo2
-- MkDillo {dilloLiveness = Alive, dilloWeight = 10}

-- >>> dilloLiveness dillo1
-- Alive
-- >>> dilloWeight dillo1
-- 10

dillo2 = MkDillo Alive 10

-- Gürteltier überfahren
runOverDillo :: Dillo -> Dillo

-- >>> runOverDillo dillo1
-- MkDillo {dilloLiveness = Dead, dilloWeight = 10}

--- runOverDillo dillo =
--    MkDillo { dilloLiveness = Dead, dilloWeight = dilloWeight dillo }
    -- dilloLiveness dillo
    -- dilloWeight dillo

-- runOverDillo dillo = MkDillo Dead (dilloWeight dillo)
-- pattern matching
-- runOverDillo (MkDillo { dilloLiveness = l, dilloWeight = w }) = MkDillo Dead w
-- runOverDillo (MkDillo { dilloWeight = w}) = MkDillo Dead w
runOverDillo (MkDillo _ weight) = MkDillo Dead weight

-- functional update, "Kopie bis auf ..."
-- runOverDillo dillo = dillo { dilloLiveness = Dead }

-}

-- Tier auf dem texanischen Highway:
-- - Gürteltier
-- - Papagei (Satz und Gewicht)
data Animal =
    MkDillo { dilloLiveness :: Liveness,
              dilloWeight :: Weight }
  | MkParrot String Weight
  deriving Show

-- algebraischer Datentyp

dillo1 :: Animal
dillo1 = MkDillo { dilloLiveness = Alive, dilloWeight = 10 }

dillo2 :: Animal
dillo2 = MkDillo Dead 8

parrot1 :: Animal
parrot1 = MkParrot "Welcome!" 1

parrot2 :: Animal
parrot2 = MkParrot "Goodbye!" 2

-- 1 Gleichung pro Fall
-- bei >1 Fall muß jede Gleichung den Konstruktor erwähnen / pattern matching

runOverAnimal :: Animal -> Animal

-- >>> runOverAnimal dillo1
-- MkDillo {dilloLiveness = Dead, dilloWeight = 10}
-- >>> runOverAnimal parrot1
-- MkParrot "" 1

runOverAnimal (MkDillo liveness weight) = MkDillo Dead weight
runOverAnimal (MkParrot sentence weight) = MkParrot "" weight

-- Schablone:
-- runOverAnimal (MkDillo dillo weight) = undefined
-- runOverAnimal (MkParrot sentence weight) = undefined

-- Tier füttern
-- >>> feedAnimal dillo1 5
-- MkDillo {dilloLiveness = Alive, dilloWeight = 15}
-- >>> feedAnimal dillo2 5
-- MkDillo {dilloLiveness = Dead, dilloWeight = 8}
-- >>> feedAnimal parrot1 5
-- MkParrot "Welcome!" 6
feedAnimal :: Animal -> Weight -> Animal
feedAnimal (MkDillo liveness weight) amount = 
    case liveness of
        Alive -> MkDillo Alive (weight + amount)
        Dead -> MkDillo Dead weight
feedAnimal (MkParrot sentence weight) amount = 
    MkParrot sentence (weight + amount)
