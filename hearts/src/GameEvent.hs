{-# LANGUAGE InstanceSigs #-}
module GameEvent where

import           Cards

import           Data.Map (Map)
import qualified Data.Map as Map

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


data Game a = 
    RecordEvent GameEvent (() -> Game a)
  | IsPlayValid Player Card (Bool -> Game a)
  | TakeTrick (Maybe (Trick, Player) -> Game a)
  | NextPlayer Player (Player -> Game a)
  | GameOver (Maybe Player -> Game a)
  | Return a


instance Functor Game where
  -- fmap :: (a -> b) -> Game a -> Game b
  -- fmap = undefined

instance Applicative Game where
  -- pure :: a -> Game a
  -- pure = Return
  -- (<*>) :: Game (a -> b) -> Game a -> Game b
  -- (<*>) = undefined

instance Monad Game where
  return :: a -> Game a
  return = Return
  (>>=) :: Game a -> (a -> Game b) -> Game b
  (>>=) (RecordEvent event callback) next = RecordEvent event (\() -> callback () >>= next)
  (>>=) (Return result) next = next result
  (>>=) (IsPlayValid player card callback) next = IsPlayValid player card (\valid -> callback valid >>= next)
  (>>=) (TakeTrick callback) next = TakeTrick (\x -> callback x >>= next)
  (>>=) (NextPlayer player callback) next = NextPlayer player (\x -> callback x >>= next)
  (>>=) (GameOver callback) next = GameOver (\x -> callback x >>= next)

recordEventM :: GameEvent -> Game ()
recordEventM event = RecordEvent event Return

isPlayValidM :: Player -> Card -> Game Bool
isPlayValidM player card = IsPlayValid player card Return

takeTrickM :: Game (Maybe (Trick, Player))
takeTrickM = TakeTrick Return

nextPlayerM :: Player -> Game Player
nextPlayerM player = NextPlayer player Return

gameOverM :: Game (Maybe Player)
gameOverM = GameOver Return

-- Maybe Player: wer hat gewonnen, falls das Spiel vorbei ist
tableProcessCommandM :: GameCommand -> Game (Maybe Player)
tableProcessCommandM (DealHands hands) = do
  let events = map (uncurry HandDealt) (Map.toList hands)
  mapM_ recordEventM events
  return Nothing
tableProcessCommandM (PlayCard player card) = do
  valid <- isPlayValidM player card
  if valid
  then do
    recordEventM (LegalCardPlayed player card)
    trick <- takeTrickM
    case trick of
      Just (trick, trickTaker) -> do
        recordEventM (TrickTaken trickTaker trick)
        gameOver <- gameOverM
        case gameOver of
          Just winner -> do
            recordEventM (GameEnded winner)
            return (Just winner)
          Nothing -> do
            recordEventM (PlayerTurnChanged trickTaker)
            return Nothing
      Nothing -> do
        nextPlayer <- nextPlayerM player
        recordEventM (PlayerTurnChanged player)
        return Nothing
  else do
    recordEventM (IllegalCardAttempted player card)
    return Nothing