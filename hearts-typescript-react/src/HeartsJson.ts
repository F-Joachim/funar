export { encodePlayer, playerDecoder,
	 encodeSuit, suitDecoder,
	 encodeRank, rankDecoder,
	 encodeCard, cardDecoder,
	 encodeHand, handDecoder,
	 encodeTrick, trickDecoder,
	 encodeGameEvent, gameEventDecoder, gameEventsDecoder,
	 encodeGameCommand, gameCommandDecoder, gameCommandsDecoder };

import { type Json } from './Json.ts';
import { JsonDecoder, type Decoder } from './JsonDecoder.ts';
import { List, Map } from 'immutable';
import { Tuple } from 'purify-ts/Tuple';

import { Player, Suit, Rank, Card, Hand, Trick } from './Cards.ts';
import { GameEvent, GameCommand } from './GameEvent.ts';

const constructor1Decoder: <A, B>(decoder: Decoder<A>, constructor: (a: A) => B) => Decoder<B> =
    (decoder, constructor) => decoder.map(constructor)

const encodePlayer: (player: Player) => Json = (player) => player.name;

const playerDecoder: Decoder<Player> =
    constructor1Decoder(JsonDecoder.string, Player.make)

const encodeSuit: (suit: Suit) => Json =
    (suit) => {
    	switch (suit) {
	    case 'Diamonds': return 'Diamonds';
	    case 'Clubs': return 'Clubs';
	    case 'Spades': return 'Spades';
	    case 'Hearts': return 'Hearts';
	}
    };

const suitDecoder: Decoder<Suit> =
    JsonDecoder.string.flatMap(s => {
	switch (s) {
	    case 'Diamonds': return JsonDecoder.pure(Suit.diamonds);
	    case 'Clubs': return JsonDecoder.pure(Suit.clubs);
	    case 'Spades': return JsonDecoder.pure(Suit.spades);
	    case 'Hearts': return JsonDecoder.pure(Suit.hearts);
	    default: return JsonDecoder.fail("Not a suit: " + s);
	}
    });

const encodeRank: (rank: Rank) => Json =
    (rank) => {
	switch (rank) {
	    case 'Two': return 'Two';
	    case 'Three': return 'Three';
	    case 'Four': return 'Four';
	    case 'Five': return 'Five';
	    case 'Six': return 'Six';
	    case 'Seven': return 'Seven';
	    case 'Eight': return 'Eight';
	    case 'Nine': return 'Nine';
	    case 'Ten': return 'Ten';
	    case 'Queen': return 'Queen';
	    case 'King': return 'King';
	    case 'Jack': return 'Jack';
	    case 'Ace': return 'Ace';
	}
    };

const rankDecoder: Decoder<Rank> =
    JsonDecoder.string.flatMap(r => {
	switch (r) {
	    case 'Two': return JsonDecoder.pure(Rank.two);
	    case 'Three': return JsonDecoder.pure(Rank.three);
	    case 'Four': return JsonDecoder.pure(Rank.four);
	    case 'Five': return JsonDecoder.pure(Rank.five);
	    case 'Six': return JsonDecoder.pure(Rank.six);
	    case 'Seven': return JsonDecoder.pure(Rank.seven);
	    case 'Eight': return JsonDecoder.pure(Rank.eight);
	    case 'Nine': return JsonDecoder.pure(Rank.nine);
	    case 'Ten': return JsonDecoder.pure(Rank.ten);
	    case 'Queen': return JsonDecoder.pure(Rank.queen);
	    case 'King': return JsonDecoder.pure(Rank.king);
	    case 'Jack': return JsonDecoder.pure(Rank.jack);
	    case 'Ace': return JsonDecoder.pure(Rank.ace);
	    default: return JsonDecoder.fail("Not a rank: " + r);
	}
    });

const encodeCard: (card: Card) => Json =
    (card) => ({suit: encodeSuit(card.suit),
		rank: encodeRank(card.rank)});

const cardDecoder: Decoder<Card> =
    JsonDecoder.map2(Card.make,
		     JsonDecoder.field('suit', suitDecoder),
		     JsonDecoder.field('rank', rankDecoder));

const encodeHand: (hand: Hand) => Json =
    (hand) => hand.cards().map(encodeCard).toArray();

const handDecoder: Decoder<Hand> =
    JsonDecoder.list(cardDecoder).map(Hand.make);

const encodeTrick: (trick: Trick) => Json =
    (trick) =>
    trick.toList().map(tuple => [encodePlayer(tuple.fst()), encodeCard(tuple.snd())]).toArray();

const tuple2Decoder: <A, B>(first: Decoder<A>, second: Decoder<B>) => Decoder<Tuple<A, B>> =
    <A, B>(first: Decoder<A>, second: Decoder<B>) =>
    JsonDecoder.map2(Tuple, JsonDecoder.index(0, first), JsonDecoder.index(1, second));

const trickDecoder: Decoder<Trick> =
    JsonDecoder.list(tuple2Decoder(playerDecoder, cardDecoder))
	.map(Trick.fromList);

const encodeConstructor1: (name: string, json: Json) => Json =
    (name, json) => ({tag: name, contents: json});

const encodeConstructor2: (name: string, json1: Json, json2: Json) => Json =
    (name, json1, json2) =>
    ({ tag: name,
       contents: [json1, json2] })

const encodeGameEvent: (event: GameEvent) => Json =
    (event) =>
    GameEvent.caseOf(event, {
	PlayerTurnChanged:
	(player) => encodeConstructor1('PlayerTurnChanged', encodePlayer(player)),
	LegalCardPlayed:
	(player, card) => encodeConstructor2('LegalCardPlayed',
					     encodePlayer(player),
					     encodeCard(card)),
	IllegalCardAttempted:
	(player, card) => encodeConstructor2('IllegalCardAttempted',
					     encodePlayer(player),
					     encodeCard(card)),
	GameEnded:
	(player) => encodeConstructor1('GameEnded', encodePlayer(player)),
	HandDealt:
	(player, hand) => encodeConstructor2('HandDealt',
					     encodePlayer(player),
					     encodeHand(hand)),
	TrickTaken:
	(player, trick) => encodeConstructor2('TrickTaken',
					      encodePlayer(player),
					      encodeTrick(trick))
    });

const constructor2Decoder: <A, B, C>(decoderA: Decoder<A>, decoderB: Decoder<B>,
				     constructor: (a: A, b: B) => C) => Decoder<C> =
    (decoderA, decoderB, constructor) =>
    JsonDecoder.map2(constructor,
		     JsonDecoder.index(0, decoderA),
		     JsonDecoder.index(1, decoderB));

const handDealtDecoder: Decoder<GameEvent> =
    constructor2Decoder(playerDecoder, handDecoder, GameEvent.handDealt);

const playerTurnChangedDecoder: Decoder<GameEvent> =
    constructor1Decoder(playerDecoder, GameEvent.playerTurnChanged);

const legalCardPlayedDecoder: Decoder<GameEvent> =
    constructor2Decoder(playerDecoder, cardDecoder, GameEvent.legalCardPlayed);

const trickTakenDecoder: Decoder<GameEvent> =
    constructor2Decoder(playerDecoder, trickDecoder, GameEvent.trickTaken);

const illegalCardAttemptedDecoder: Decoder<GameEvent> =
    constructor2Decoder(playerDecoder, cardDecoder, GameEvent.illegalCardAttempted);

const gameEndedDecoder: Decoder<GameEvent> =
    constructor1Decoder(playerDecoder, GameEvent.gameEnded);

const dataDecoder: <A>(dict: Map<string, Decoder<A>>, invalid: (tag: string) => Decoder<A>) => Decoder<A> =
    (dict, invalid) =>
    JsonDecoder.field('tag', JsonDecoder.string).flatMap(tag => {
	const constructorDecoder = dict.get(tag);
	switch (constructorDecoder) {
	    case undefined: return invalid(tag);
	    default: return JsonDecoder.field('contents', constructorDecoder);
	};
    });

const gameEventDataTable: Map<string, Decoder<GameEvent>> =
    Map([['HandDealt', handDealtDecoder],
	 ['PlayerTurnChanged', playerTurnChangedDecoder],
	 ['LegalCardPlayed', legalCardPlayedDecoder],
	 ['TrickTaken', trickTakenDecoder],
	 ['IllegalCardAttempted', illegalCardAttemptedDecoder],
	 ['GameEnded', gameEndedDecoder]]);

const gameEventDecoder: Decoder<GameEvent> =
    dataDecoder(gameEventDataTable, tag => JsonDecoder.fail("unknown GameEvent tag " + tag));

const gameEventsDecoder: Decoder<List<GameEvent>> =
    JsonDecoder.list(gameEventDecoder);

const encodeGameCommand: (command: GameCommand) => Json =
    (command) =>
    GameCommand.caseOf(command, {
	DealHands:
	(playerHands) =>
	    encodeConstructor1('DealHands',
			       playerHands.toArray().map(pair => {
				   const [player, hand] = pair;
				   return [encodePlayer(player), encodeHand(hand)];
			       })),
	PlayCard:
	(player, card) => encodeConstructor2('PlayCard',
					     encodePlayer(player),
					     encodeCard(card))
    });


const mapDecoder: <K,V>(decoderK: Decoder<K>, decoderV: Decoder<V>) => Decoder<Map<K, V>> =
    (decoderK, decoderV) =>
    JsonDecoder.list(JsonDecoder.map2(Tuple,
				      JsonDecoder.index(0, decoderK),
				      JsonDecoder.index(1, decoderV)))
	.map(list => Map(list.map(tuple => tuple.toArray())));
    

const playerHandsDecoder: Decoder<Map<Player, Hand>> =
    mapDecoder(playerDecoder, JsonDecoder.list(cardDecoder).map(Hand.make));

const dealHandsDecoder: Decoder<GameCommand> =
    constructor1Decoder(playerHandsDecoder, GameCommand.dealHands);

const playCardDecoder: Decoder<GameCommand> =
    constructor2Decoder(playerDecoder, cardDecoder, GameCommand.playCard);

const gameCommandDecoderTable: Map<string, Decoder<GameCommand>> =
    Map([['DealHands', dealHandsDecoder],
	 ['PlayCard', playCardDecoder]]);

const gameCommandDecoder: Decoder<GameCommand> =
    dataDecoder(gameCommandDecoderTable,
		tag => JsonDecoder.fail("unknown GameCommand tag " + tag));

const gameCommandsDecoder: Decoder<List<GameCommand>> =
    JsonDecoder.list(gameCommandDecoder);
