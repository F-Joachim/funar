{-# LANGUAGE InstanceSigs #-}
module GameEvent where

import Cards

import qualified Data.Map as Map
import Data.Map (Map)

-- Event:
-- Objekt, das ein Ereignis beschreibt
-- - in der Vergangenheit
-- - fachlich
-- - sollten nicht den neuen Zustand enthalten
-- Event-Sourcing:
-- - Events erzählen die gesamte Geschichte der Domäne
-- - Redundanz OK

{-
data GameEvent =
    GameSetup [(Player, Hand)]
  | GameStarted Player
  | PlayedCard Player Card
  | TrickEnded [Card] Player
  | ReceivedPoints Player Integer
  | TurnChanged Player -- wer ist als nächstes dran
  | GameEnded Player
-}

data GameEvent
  = HandDealt Player Hand
  | PlayerTurnChanged Player
  | LegalCardPlayed Player Card
  | TrickTaken Player Trick
  | IllegalCardAttempted Player Card
  | GameEnded Player
  deriving (Show, Eq)

-- Command:
-- Objekt, der einen Wunsch repräsentiert
-- - in der Zukunft
-- - vielleicht passiert es gar nicht
data GameCommand =
    DealHands (Map Player Hand) 
  | PlayCard Player Card
  deriving (Show, Eq)

data Game a = -- entspricht DB a
    RecordEvent GameEvent (() -> Game a) -- wie Put
  | IsPlayValid Player Card (Bool -> Game a) -- wie Get
  | Return a

instance Functor Game where
instance Applicative Game where

instance Monad Game where
    return :: a -> Game a
    return = Return
    (>>=) (RecordEvent event callback) next =
        RecordEvent event (\() ->
            callback () >>= next)
    (>>=) (IsPlayValid player card callback) next =
        IsPlayValid player card (\x ->
            callback x >>= next)
    (>>=) (Return result) next = next result

recordEventM :: GameEvent -> Game ()
recordEventM event = RecordEvent event Return

isPlayValidM :: Player -> Card -> Game Bool
isPlayValidM player card = IsPlayValid player card Return

-- Maybe Player: wer hat gewonnen, falls das Spiel vorbei ist
tableProcessCommandM :: GameCommand -> Game (Maybe Player)
tableProcessCommandM (DealHands hands) =
    do let events = map (uncurry HandDealt) (Map.toList hands)
       let recordEvents = map recordEventM events
       -- mapM_ recordEventM events
       sequence_ recordEvents
       return Nothing
tableProcessCommandM (PlayCard player card) = 
    do valid <- isPlayValidM player card
       if valid
       then do recordEventM (LegalCardPlayed player card)
               undefined
       else do recordEventM (IllegalCardAttempted player card)
               return Nothing