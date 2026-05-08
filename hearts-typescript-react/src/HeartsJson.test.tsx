import { expect, test } from 'vitest';

import { gameEventDecoder, gameEventsDecoder } from './HeartsJson.ts';
import { Card, Suit, Rank, Hand, Player } from './Cards.ts';
import { GameEvent } from './GameEvent.ts';
import { Right } from 'purify-ts/Either'
import { List } from 'immutable';

test("event can be decoded", () => {
    expect(gameEventDecoder.decode({"contents":["Annette",[{"rank":"Nine","suit":"Diamonds"}]],"tag":"HandDealt"}))
	.toStrictEqual(Right(GameEvent.handDealt(Player.make("Annette"), Hand.make(List.of(Card.make(Suit.diamonds, Rank.nine))))));
})

test("events can be decoded", () => {
    expect(gameEventsDecoder.decode([{"contents":["Annette",[{"rank":"Nine","suit":"Diamonds"}]],"tag":"HandDealt"}]))
	.toStrictEqual(Right(List.of(GameEvent.handDealt(Player.make("Annette"), Hand.make(List.of(Card.make(Suit.diamonds, Rank.nine)))))));
})
