import { expect, test } from 'vitest';
import { Card, Player, Hand } from './Cards.ts';
import { GameCommand } from './GameEvent.ts';
import { Map, List } from 'immutable';

const mike = Player.make('Mike')
const peter = Player.make('Peter')
const annette = Player.make('Annette')
const nicole = Player.make('Nicole')

const players = List.of(mike, peter, annette, nicole)


test("GameCommand.deckToDealHands", () => {
    expect(GameCommand.deckToDealHands(Card.deck, players))
	.toStrictEqual(GameCommand.dealHands(Map(List.of([mike, Hand.make(Card.deck.take(13))],
							 [peter, Hand.make(Card.deck.skip(13).take(13))],
							 [annette, Hand.make(Card.deck.skip(26).take(13))],
							 [nicole, Hand.make(Card.deck.skip(39).take(13))]))))

})
