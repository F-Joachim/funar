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
  | RoundOverTrick (Maybe (Trick, Player) -> Game a)
  | PlayerAfter Player (Player -> Game a)
  | GameOver (Maybe Player -> Game a)
  | GetCommand (GameCommand -> Game a)
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
    (>>=) (RoundOverTrick callback) next =
        RoundOverTrick (\x ->
            callback x >>= next)
    (>>=) (PlayerAfter player callback) next =
        PlayerAfter player (\x ->
            callback x >>= next)
    (>>=) (GameOver callback) next =
        GameOver (\x ->
            callback x >>= next)
    (>>=) (GetCommand callback) next =
        GetCommand (\x ->
            callback x >>= next)
    (>>=) (Return result) next = next result

recordEventM :: GameEvent -> Game ()
recordEventM event = RecordEvent event Return

isPlayValidM :: Player -> Card -> Game Bool
isPlayValidM player card = IsPlayValid player card Return

roundOverTrickM :: Game (Maybe (Trick, Player))
roundOverTrickM = RoundOverTrick Return

playerAfterM :: Player -> Game Player
playerAfterM player = PlayerAfter player Return

gameOverM :: Game (Maybe Player)
gameOverM = GameOver Return

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
               roundOverTrick <- roundOverTrickM
               case roundOverTrick of
                Just (trick, trickTaker) ->
                 do recordEventM (TrickTaken trickTaker trick)
                    over <- gameOverM
                    case over of
                        Just winner ->
                            do recordEventM (GameEnded winner)
                               return (Just winner)
                        Nothing ->
                            do recordEventM (PlayerTurnChanged trickTaker)
                               return Nothing
                Nothing ->
                    do nextPlayer <- playerAfterM player
                       recordEventM (PlayerTurnChanged nextPlayer)
                       return Nothing

       else do recordEventM (IllegalCardAttempted player card)
               return Nothing

-- liefert Gewinner:in
tableLoopM :: GameCommand -> Game Player
tableLoopM command =
    do maybeWinner <- tableProcessCommandM command
       case maybeWinner of
        Just winner -> return winner
        Nothing ->
            GetCommand tableLoopM -- erst mal GameCommand holen, dann wieder tableLoopM 