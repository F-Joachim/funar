{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE InstanceSigs #-}
module DB where

import qualified Data.Map.Strict as Map
import Data.Map.Strict (Map, (!))

import Control.Applicative
import Database.SQLite.Simple
import Database.SQLite.Simple.FromRow

{-
put "Mike" 100
x = get "Mike"
put "Mike" (x+1)
y = get "Mike"
return (show (x+y))
-}

type Key = String
type Value = Integer

{-
data DBCommand a =
    Put Key Value
  | Get Key
  | Return a

type DBProgram a = [DBCommand a]

p1 = [Put "Mike" 100,
      Get "Mike",
      Put "Mike" (x+1)
     ]
-}

data DB a =
    Get Key       (Value -> DB a) -- Callback/Continuation
  | Put Key Value (()    -> DB a)
  | Return a

p1 :: DB String
p1 = Put "Mike" 100 (\() ->
     Get "Mike" (\x ->
     Put "Mike" (x+1) (\() ->
     Get "Mike" (\y ->
     Return (show(x+y))))))

runDB :: DB a -> Map Key Value -> (a, Map Key Value)

-- >>> runDB p1 Map.empty
-- ("201",fromList [("Mike",101)])
runDB (Get key callback) db =
    let value = db ! key
    in runDB (callback value) db
runDB (Put key value callback) db = 
    let db' = Map.insert key value db
    in runDB (callback ()) db'
runDB (Return result) db = (result, db)

data Entry = MkEntry Key Value
  deriving Show

instance FromRow Entry where
    fromRow :: RowParser Entry
    fromRow = MkEntry <$> field <*> field

instance ToRow Entry where
    toRow (MkEntry key value) = toRow (key, value)

runDBSQLite :: Connection -> DB a -> IO a
runDBSQLite conn (Get key callback) = undefined
runDBSQLite conn (Put key value callback) = undefined
runDBSQLite conn (Return result) = return result

-- return :: a -> IO a

-- foo = execute_

get :: Key -> DB Value
get key = Get key Return -- (\value -> Return value)

put :: Key -> Value -> DB ()
put key value = Put key value Return

splice :: DB a -> (a -> DB b) -> DB b
splice (Get key callback) next =
    Get key (\value ->
        splice (callback value) next)
splice (Put key value callback) next =
    Put key value (\() ->
        splice (callback ()) next)
splice (Return result) next = next result

p1' :: DB String
-- >>> runDB p1' Map.empty
-- ("201",fromList [("Mike",101)])
p1' = splice (put "Mike" 100) (\() ->
      splice (get "Mike") (\x ->
      splice (put "Mike" (x+1)) (\() ->
      splice (get "Mike") (\y ->
      Return (show(x+y))))))

-- >>> :info Monad
-- type Monad :: (* -> *) -> Constraint
-- class Applicative m => Monad m where
--   (>>=) :: m a -> (a -> m b) -> m b
--   return :: a -> m a

--     pure :: a -> m a

instance Functor DB where

instance Applicative DB where

instance Monad DB where
    (>>=) = splice
    return = Return

p1'' :: DB String

-- >>> runDB p1'' Map.empty
-- ("201",fromList [("Mike",101)])
p1'' = do put "Mike" 100
          x <- get "Mike"
          put "Mike" (x+1)
          y <- get "Mike"
          return (show(x+y))

-- fmap ::        (a ->   b) -> f a -> f b
-- (<*>) ::     f (a ->   b) -> f a -> f b
-- flip (>>=) ::  (a -> f b) -> f a -> f b

-- (>>=) :: f a -> (a -> f b) -> f b