export { ViewModel };
import { Player, Card, Hand, Trick, Pile } from './Cards.ts';
import { GameEvent, GameCommand } from './GameEvent.ts';
import { List, Map } from 'immutable';

type PlayerHands = Map<Player, Hand>

type PlayerPiles = Map<Player, Pile>

type ViewModel = {
    players: List<Player>,
    next: number, // index
    hands: PlayerHands,
    piles: PlayerPiles,
    trick: Trick,
    pendingCommands: List<GameCommand>
}

interface ViewModelTypeRef {
    initial(players: List<Player>): ViewModel
    processEvent(event: GameEvent, model: ViewModel): ViewModel
    processEvents(events: List<GameEvent>, model: ViewModel): ViewModel
    addPendingCommands(model: ViewModel, command: List<GameCommand>): ViewModel
    getPendingCommands(model: ViewModel): [List<GameCommand>, ViewModel]
}

const emptyPlayerHands: (players: List<Player>) => PlayerHands =
    (players: List<Player>) => Map(players.map(player => [player, Hand.empty]))

const emptyPlayerPiles: (players: List<Player>) => PlayerPiles =
    (players: List<Player>) => Map(players.map(player => [player, Pile.empty]))

const ViewModel: ViewModelTypeRef = {
    initial:
	(players: List<Player>) =>
	({ players: players,
	   next: 0,
	   hands: emptyPlayerHands(players),
	   piles: emptyPlayerPiles(players),
	   trick: Trick.empty,
	   pendingCommands: List.of() }),

    processEvent:
    (event: GameEvent, model: ViewModel) =>
	GameEvent.caseOf(
	    event,
	    {HandDealt: (player: Player, hand: Hand) =>
		({...model, hands: model.hands.set(player, hand) }),
	     
	     PlayerTurnChanged: (player: Player) =>
		({...model,
		  next: model.players.indexOf(player)}),
	     
	     LegalCardPlayed: (player: Player, card: Card) =>
		({...model,
		  hands: model.hands.update(player, (hand) => hand!.remove(card)),
		  trick: model.trick.add(player, card)
		 }),
	     
	     TrickTaken: (player: Player, trick: Trick) =>
		({...model,
		  piles: model.piles.update(player, Pile.empty,
					    (pile) => pile.addTrick(trick)),
		  trick: Trick.empty
		 }),
	     
	     IllegalCardAttempted: (_player: Player, _card: Card) => model,
	     
	     GameEnded: (_player: Player) => model}),

    processEvents:
    (events: List<GameEvent>, model: ViewModel) =>
	events.reduce((model, event) =>  ViewModel.processEvent(event, model), model),

    addPendingCommands:
    (model: ViewModel, commands: List<GameCommand>) =>
	({...model,
	  pendingCommands: model.pendingCommands.concat(commands) }),

    getPendingCommands:
    (model: ViewModel) =>
	[model.pendingCommands, {...model, pendingCommands: List() }]
    
}
