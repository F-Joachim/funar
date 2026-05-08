export { GameEvent, GameCommand };

import { Player, Card, Hand, Trick } from './Cards.ts';

import { Map, List } from 'immutable';

type GameEvent =
    | { tag: 'HandDealt', player: Player, hand: Hand }
    | { tag: 'PlayerTurnChanged', player: Player }
    | { tag: 'LegalCardPlayed', player: Player, card: Card }
    | { tag: 'TrickTaken', player: Player, trick: Trick }
    | { tag: 'IllegalCardAttempted', player: Player, card: Card }
    | { tag: 'GameEnded', player: Player }

interface GameEventTypeRef {
    handDealt(player: Player, hand: Hand): GameEvent;
    playerTurnChanged(player: Player): GameEvent;
    legalCardPlayed(player: Player, card: Card): GameEvent;
    trickTaken(player: Player, trick: Trick): GameEvent;
    illegalCardAttempted(player: Player, card: Card): GameEvent;
    gameEnded(player: Player): GameEvent;

    caseOf<A>(event: GameEvent,
	      table: { HandDealt: (player: Player, hand: Hand) => A,
		       PlayerTurnChanged: (player: Player) => A,
		       LegalCardPlayed: (player: Player, card: Card) => A,
		       TrickTaken: (player: Player, trick: Trick) => A,
		       IllegalCardAttempted: (player: Player, card: Card) => A,
		       GameEnded: (player: Player) => A
		     }): A;
    // for testing
    deckToHandDealt(deck: List<Card>, players: List<Player>): List<GameEvent>;
}

const GameEvent: GameEventTypeRef = {
    handDealt: (player: Player, hand: Hand) =>
	({ tag: 'HandDealt', player: player, hand: hand }),
    playerTurnChanged: (player: Player) =>
	({ tag: 'PlayerTurnChanged', player: player }),
    legalCardPlayed: (player: Player, card: Card) =>
	({ tag: 'LegalCardPlayed', player: player, card: card }),
    trickTaken: (player: Player, trick: Trick) =>
	({ tag: 'TrickTaken', player: player, trick: trick }),
    illegalCardAttempted: (player: Player, card: Card) =>
	({ tag: 'IllegalCardAttempted', player: player, card: card }),
    gameEnded: (player: Player) =>
	({ tag: 'GameEnded', player: player }),

    caseOf: (event, table) => {
	switch (event.tag) {
	    case 'HandDealt': return table.HandDealt(event.player, event.hand);
	    case 'PlayerTurnChanged': return table.PlayerTurnChanged(event.player);
	    case 'LegalCardPlayed': return table.LegalCardPlayed(event.player, event.card);
	    case 'TrickTaken': return table.TrickTaken(event.player, event.trick);
	    case 'IllegalCardAttempted': return table.IllegalCardAttempted(event.player, event.card);
	    case 'GameEnded': return table.GameEnded(event.player);
	}
    },

    deckToHandDealt:
    (deck: List<Card>, players: List<Player>) => {
	let handSize = Math.floor(deck.size / players.size);
	return List([...Array(players.size).keys()].map(index =>
	    ({tag: 'HandDealt',
	      player: players.get(index)!,
	      hand: Hand.make(deck.skip(handSize * index).take(handSize)) })))
    }

}

type GameCommand =
    | { tag: 'DealHands', playerHands: Map<Player, Hand> }
    | { tag: 'PlayCard', player: Player, card: Card }

interface GameCommandTypeRef {
    dealHands(playerHands: Map<Player, Hand>): GameCommand;
    playCard(player: Player, card: Card): GameCommand;
    deckToDealHands(deck: List<Card>, players: List<Player>): GameCommand;
    caseOf<A>(command: GameCommand,
	      table: { DealHands: (playerHands: Map<Player, Hand>) => A,
		       PlayCard: (player: Player, card: Card) => A
		     }): A;
}

const GameCommand: GameCommandTypeRef = {
    dealHands: (playerHands: Map<Player, Hand>) =>
	({ tag: 'DealHands', playerHands: playerHands }),
    playCard: (player: Player, card: Card) =>
	({ tag: 'PlayCard', player: player, card: card }),

    deckToDealHands:
    (deck: List<Card>, players: List<Player>) => {
	let handSize = Math.floor(deck.size / players.size);
	return { tag: 'DealHands',
		 playerHands:
		 Map([...Array(players.size).keys()].map(index =>
		     [(players.get(index))!, Hand.make(deck.skip(handSize * index).take(handSize))])) }
		     
    },

    caseOf: (command, table) => {
	switch (command.tag) {
	    case 'DealHands': return table.DealHands(command.playerHands);
	    case 'PlayCard': return table.PlayCard(command.player, command.card);
	}
    }
}

