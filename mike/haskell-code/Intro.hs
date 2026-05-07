{-# LANGUAGE InstanceSigs #-}
module Intro where
import Prelude hiding (Semigroup, Monoid)

x :: Integer
x = 23 + 2 * 21

y :: Integer
y = x + 6

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

instance Eq Pet where  -- Implementierung der Typklasse Eq
  (==) :: Pet -> Pet -> Bool
  (==) Dog Dog = True
  (==) Cat Cat = True
  (==) Snake Snake = True
  (==) _ _ = False


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
    deriving (Eq, Show)

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

feedAnimal' :: (Animal, Weight) -> Animal

-- >>> feedAnimal'(dillo1, 5)
-- MkDillo {dilloLiveness = Alive, dilloWeight = 15}

feedAnimal'(MkDillo liveness weight, amount) =
  case liveness of
    Alive -> MkDillo Alive (weight + amount)
    Dead -> MkDillo Dead weight
feedAnimal'(MkParrot sentence weight, amount) =
  MkParrot sentence (weight + amount)

-- eingebaut als uncurry
-- tuplify :: (Animal -> Weight -> Animal) -> ((Animal, Weight) -> Animal)
entschönfinkeln :: (a -> b -> c) -> ((a, b) -> c) -- Typvariablen (Kleinbuchstaben)
-- tuplify f = \ (a, b) -> f a b
entschönfinkeln f (a, b) = f a b

-- eingebaut als curry
schönfinkeln :: ((a, b) -> c) -> (a -> b -> c)
-- untuplify f = \ a -> \ b -> f (a, b)
schönfinkeln f a b = f (a, b)

-- Haskell Curry
-- Moses Schönfinkel

-- eingebaut als flip
swap :: (a -> b -> c) -> (b -> a -> c)

-- >>> swap feedAnimal 5 dillo1
-- MkDillo {dilloLiveness = Alive, dilloWeight = 15}

-- swap f = \ b -> \ a -> f a b
swap f b a = f a b

-- Funktionskomposition
-- eingebaut als .
o :: (b -> c) -> (a -> b) -> (a -> c)
o f g = \ a -> f (g a)

-- Name aus Sonderzeichen => Infix-Operator

pfff :: Animal -> Animal

-- >>> pfff dillo1
-- MkDillo {dilloLiveness = Dead, dilloWeight = 15}
pfff = runOverAnimal . flip feedAnimal 5

-- >>> tuplify feedAnimal (dillo1, 5)
-- MkDillo {dilloLiveness = Alive, dilloWeight = 15}

-- Der Einflußbereich einer "Flotte" ("Shape") ist eins der folgenden:
-- - ein Kreis
-- - ein Quadrat
-- - die Überlagerung zweier Shapes

-- 1. Datentyp für Shape
-- 2. Funktion, die feststellt, ob ein Punkt innerhalb eines Shapes liegt

data Point = MkPoint Double Double
  deriving (Show, Eq)

point1 :: Point
point1 = MkPoint 1 1

point2 :: Point
point2 = MkPoint 3 3

point3 :: Point
point3 = MkPoint 10 4

data Shape
  = MkCircle {center :: Point, radius :: Double}
  | MkSquare {leftBottom :: Point, sideLength :: Double}
  | MkOverlap {shape1 :: Shape, shape2 :: Shape} -- Kombinator
  deriving (Show)

circle1 :: Shape
circle1 = MkCircle (MkPoint 2 2) 2.0

square1 :: Shape
square1 = MkSquare (MkPoint 3 3) 4.0

within :: Shape -> Point -> Bool
within (MkCircle (MkPoint centerX centerY) radius) (MkPoint x y) =
  let distanceX = (x - centerX) ^ 2
      distanceY = (y - centerY) ^ 2
      difference = sqrt (distanceX + distanceY)
   in difference <= radius
within (MkSquare (MkPoint squareX squareY) sideLength) (MkPoint x y) =
  let rightTopX = squareX + sideLength
      rightTopY = squareY + sideLength
   in ((x >= squareX) && (x <= rightTopX))
        && ((y >= squareY) && (y <= rightTopY))
within (MkOverlap shape1 shape2) point =
  within shape1 point || within shape2 point

-- Liste ist eins der folgenden:
-- - die leere Liste -ODER-                            []
-- - eine Cons-Liste aus erstem Element und Rest-Liste :

-- 1elementige Liste 5
list1 :: [Integer]
list1 = 5 : []
-- 2elementige Liste: 2 5
list2 :: [Integer]
list2 = 2 : (5 : [])

-- 3elementige Liste: 2 5 8
list3 :: [Integer]
list3 = [2,5,8]

-- 4elementige Liste: 3 2 5 8
list4 :: [Integer]
list4 = 3 : list3

-- Liste aufsummieren
listSum :: [Integer] -> Integer
-- >>> listSum list4
-- 18
listSum [] = 0
listSum (x:xs) = x + listSum xs

-- Funktion auf alle Elemente einer Liste anwenden
-- eingebaut als map
listMap :: (a -> b) -> [a] -> [b]
listMap f [] = undefined
listMap f (x:xs) = (f x) : (listMap f xs)

data Optional a =
    Null
  | Result a
  deriving Show

-- Index eines Elements in einer Liste
-- Eq a: Constraint, "a hat mit == vergleichbare Werte"
listIndex :: Eq a => [a] -> a -> Optional Integer

-- >>> listIndex [1,5,7,12,9] 12
-- Result 3

-- >>> listIndex [Cat, Dog, Cat, Snake, Cat] Snake
-- Result 3

listIndex [] element = Null
listIndex (x:xs) element =
    if x == element
    then Result 0
    else case listIndex xs element of
           Null -> Null
           Result index -> Result (index+1)

-- Typklasse ~~~ "Interface"
-- Implementierung: "instance"
-- >>> :info Eq
-- type Eq :: * -> Constraint
-- class Eq a where
--   (==) :: a -> a -> Bool
--   (/=) :: a -> a -> Bool

-- >>> :info Show
-- type Show :: * -> Constraint
-- class Show a where
--   show :: a -> String

-- >>> :info Ord
-- type Ord :: * -> Constraint
-- class Eq a => Ord a where
--   compare :: a -> a -> Ordering
--   (<) :: a -> a -> Bool
--   (<=) :: a -> a -> Bool
--   (>) :: a -> a -> Bool
--   (>=) :: a -> a -> Bool
--   max :: a -> a -> a
--   min :: a -> a -> a

-- >>> :info Num
-- type Num :: * -> Constraint
-- class Num a where
--   (+) :: a -> a -> a
--   (-) :: a -> a -> a
--   (*) :: a -> a -> a
--   negate :: a -> a
--   abs :: a -> a
--   signum :: a -> a
--   fromInteger :: Integer -> a

double' :: Num a => a -> a
double' x = x * 2


-- neutrales Element
-- Zero von Add   -  Add Zero c = Add c Zero = c
-- 0 von +           0 + x = x + 0 = x
-- 1 von *           1 * x = x * 1 = x
-- "leeres Bild" von overlay

-- Halbgruppe:
-- Typ a
-- op :: a -> a -> a
-- op a (op b c) = op (op a b) c
-- Assoziativität
-- a + (b + c) = (a + b) + c
class Semigroup a where
    -- op a (op b c) = op (op a b) c
    op :: a -> a -> a

instance Semigroup Shape where
    op :: Shape -> Shape -> Shape
    op = MkOverlap

instance Semigroup [a] where
    op :: [a] -> [a] -> [a]
    op = (++)

instance (Semigroup p, Semigroup q) => Semigroup (p, q) where
    op :: (p, q) -> (p, q) -> (p, q)
    op (p1, q1) (p2, q2) = (op p1 p2, op q1 q2) 

-- >>> op ([1,2,3], MkCircle point1 5) ([3,4,5], MkSquare point2 3)
-- ([1,2,3,3,4,5],MkOverlap {shape1 = MkCircle {center = MkPoint 1.0 1.0, radius = 5.0}, shape2 = MkSquare {leftBottom = MkPoint 3.0 3.0, sideLength = 3.0}})

-- Monoid:
-- Halbgruppe mit neutralem Element
-- op neutral x = op x neutral = x
class Semigroup a => Monoid a where
    -- op neutral x = op x neutral = x
    neutral :: a

instance Monoid [a] where
    neutral :: [a]
    neutral = []

instance (Monoid p, Monoid q) => Monoid (p, q) where
    neutral :: (p, q)
    neutral = (neutral, neutral)

-- >>> op [1,2,3] [4,5,6]
-- [1,2,3,4,5,6]
-- >>> op [1,2,3] neutral
-- [1,2,3]

listFold :: (a -> b -> b) -> b -> [a] -> b
listFold f e [] = e
listFold f e (x:xs) = f x (listFold f e xs)

monoidFold :: Monoid b => [b] -> b

-- >>> monoidFold [[1,2,3], [4,5,6], [7,8,9]]
-- [1,2,3,4,5,6,7,8,9]
monoidFold list = listFold op neutral list
