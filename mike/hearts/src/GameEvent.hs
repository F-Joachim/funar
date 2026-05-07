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