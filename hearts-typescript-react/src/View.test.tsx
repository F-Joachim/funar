import { expect, test } from 'vitest';
import * as View from './View.tsx'
import { Card } from './Cards.ts'

test("cardToElement works", () => {
    expect(View.renderCard(Card.make('Diamonds', 'Two')))
	.toStrictEqual(
	    <div className="card rank-2 diams">
		<span className="rank">2</span>
		<span className="suit">&diams;</span>
	    </div>
	);
    expect(View.renderCard(Card.make('Clubs', 'Queen')))
	.toStrictEqual(
	    <div className="card rank-q clubs">
		<span className="rank">Q</span>
		<span className="suit">&clubs;</span>
	    </div>
	);
    expect(View.renderCard(Card.make('Spades', 'Ace')))
	.toStrictEqual(
	    <div className="card rank-a spades">
		<span className="rank">A</span>
		<span className="suit">&spades;</span>
	    </div>
	);
    expect(View.renderCard(Card.make('Hearts', 'Ten')))
	.toStrictEqual(
	    <div className="card rank-10 hearts">
		<span className="rank">10</span>
		<span className="suit">&hearts;</span>
	    </div>
	);
})
