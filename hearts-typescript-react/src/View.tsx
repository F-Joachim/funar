export { HeartsView, renderCard };
import { Card, Rank, Suit, Hand, Trick } from './Cards.ts';
import { GameCommand } from './GameEvent.ts';
import { ViewModel } from './ViewModel.ts';
import { List } from 'immutable';
import { type JSX } from 'react';
import { type Endpoints, 
	 processGameCommands, dealHands, makeUpdate } from './HeartsUpdate.ts';
import { makeExecuteUpdate } from './ViewUpdate.ts';

const rankToSuffix: (rank: Rank) => string = (rank: Rank) => {
    switch (rank) {
	case 'Two': return '2';
	case 'Three': return '3';
	case 'Four': return '4';
	case 'Five': return '5';
	case 'Six': return '6';
	case 'Seven': return '7';
	case 'Eight': return '8';
	case 'Nine': return '9';
	case 'Ten': return '10';
	case 'Jack': return 'j';
	case 'Queen': return 'q';
	case 'King': return 'k';
	case 'Ace': return 'a';
    }
};

const suitToClass: (suit: Suit) => string = (suit: Suit) => {
    switch (suit) {
	case 'Diamonds': return 'diams';
	case 'Clubs': return 'clubs';
	case 'Spades': return 'spades';
	case 'Hearts': return 'hearts';
    }
};

const suitToUnicode: (suit: Suit) => string = (suit: Suit) => {
    switch (suit) {
	case 'Diamonds': return '♦';
	case 'Clubs': return '♣';
	case 'Spades': return '♠';
	case 'Hearts': return '♥';
    }
};

const renderCard: (card: Card) => JSX.Element = (card: Card) =>
    ( <div className={"card rank-" + rankToSuffix(card.rank) + ' ' + suitToClass(card.suit)}>
	<span className="rank">{rankToSuffix(card.rank).toUpperCase()}</span>
	<span className="suit">{suitToUnicode(card.suit)}</span>
      </div> );

// note there's also a hand, and cards lying on the table:
// https://selfthinker.github.io/CSS-Playing-Cards/

const cardsContext = (elements: JSX.Element[]) =>
    (<div className="playingCards fourColours">{elements}</div>);

const renderHand: (hand: Hand) => JSX.Element =
    (hand: Hand) =>
    (<span className="playingCards fourColors faceImages simpleCards inText rotateHand">
	<ul className="table">
	{hand.cards().map(card =>
	    <li key={card.suit + ':' + card.rank}>{renderCard(card)}</li>)}
	</ul>
	</span>)

const cardKey: (card: Card) => string =
    (card) => card.suit + ':' + card.rank;

const renderTrick: (trick: Trick) => JSX.Element =
    (trick) =>
    (<ul className="table">
        {trick.toList().map((pair) =>
	    <li key={pair.fst().name + ' -> ' + cardKey(pair.snd()) }>
	      {renderCard(pair.snd())} from {pair.fst().name}
            </li>)}
     </ul>)

const commandKey: (command: GameCommand) => string =
    (command) => 
	GameCommand.caseOf(command, {
	    DealHands: (_playerHands) => 'Deal Hands',
	    PlayCard: (player, card) =>
		player.name + ' -> ' + cardKey(card)
	});

const renderCommand: (command: GameCommand) => JSX.Element =
    (command) =>
	GameCommand.caseOf(command, {
	    DealHands: (_playerHands) => (<div>Deal Hands</div>),
	    PlayCard: (player, card) =>
		(<div>{player.name} wants to play {renderCard(card)}</div>)
	});

type HeartsViewProps =
    { initialModel: ViewModel, endpoints: Endpoints }

const logHands = (prefix: string, model: ViewModel) => {
    console.log(prefix + `: hands: ${List(model.hands.keys()).toArray().map(player => JSON.stringify(player))} ${model.hands.toArray().map(pair => pair[1].cards().size)}`);
};

const HeartsView: React.FC<HeartsViewProps> =
    ({initialModel, endpoints}) => {

	console.log('running render');

	const update = makeUpdate(endpoints);
	const [model, executeUpdate] = makeExecuteUpdate(initialModel, update);

	return (<>
        <button onClick={() => executeUpdate(dealHands)}>Deal Cards</button>
        <button onClick={() => executeUpdate(processGameCommands)}>Process Commands</button>
	<h2>Players' Hands</h2>
	<ul>
	  {model.players.map(player =>
	    <li key={player.name}>{player.name}:
	      {renderHand(model.hands.get(player)!)}
	    </li>)}
        </ul>
        <h2>Trick</h2>
        {renderTrick(model.trick)}

        <h2>Pending Commands</h2>
        <div className="playingCards fourColors faceImages simpleCards inText">
          <ol>
             {model.pendingCommands.map((command) =>
               <li key={commandKey(command)}>
                 {renderCommand(command)}
               </li>)}
          </ol>
        </div>
      </>);
}
