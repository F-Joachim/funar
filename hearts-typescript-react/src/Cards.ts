export { Rank, Suit, Card, Hand, Player, Trick, Pile };
import { Set, List, Record } from 'immutable';
import type { RecordOf } from 'immutable';
import { Tuple } from 'purify-ts/Tuple';

type Rank =
    'Two' | 'Three' | 'Four' | 'Five' | 'Six' | 'Seven' | 'Eight' | 'Nine' | 'Ten' | 'Jack' | 'Queen' | 'King' | 'Ace';

interface RankTypeRef {
    two: Rank;
    three: Rank;
    four: Rank;
    five: Rank;
    six: Rank;
    seven: Rank;
    eight: Rank;
    nine: Rank;
    ten: Rank;
    jack: Rank;
    queen: Rank;
    king: Rank;
    ace: Rank;
}

const Rank: RankTypeRef = {
    two: 'Two',
    three: 'Three',
    four: 'Four',
    five: 'Five',
    six: 'Six',
    seven: 'Seven',
    eight: 'Eight',
    nine: 'Nine',
    ten: 'Ten',
    jack: 'Jack',
    queen: 'Queen',
    king: 'King',
    ace: 'Ace'
}

const allRanks: List<Rank> = List.of('Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine', 'Ten', 'Jack', 'Queen', 'King', 'Ace')

type Suit =
    'Diamonds' | 'Clubs' | 'Spades' | 'Hearts'

interface SuitTypeRef {
    diamonds: Suit;
    clubs: Suit;
    spades: Suit;
    hearts: Suit;
}
const Suit: SuitTypeRef = {
    diamonds: 'Diamonds',
    clubs: 'Clubs',
    spades: 'Spades',
    hearts: 'Hearts'
}

const allSuits: List<Suit> = List.of('Diamonds', 'Clubs', 'Spades', 'Hearts')

type CardProps = { suit: Suit, rank: Rank }

type Card = RecordOf<CardProps>

const defaultCardProps: CardProps = { suit: 'Diamonds', rank: 'Ace' };

const makeCard: Record.Factory<CardProps> = Record(defaultCardProps);

interface CardTypeRef {
    make(suit: Suit, rank: Rank): Card;
    deck: List<Card>;
}

const Card: CardTypeRef = {
    make: (suit: Suit, rank: Rank) => makeCard({suit: suit, rank: rank}),

    deck: allRanks.flatMap(rank => allSuits.map(suit => makeCard({suit: suit, rank: rank})))
}

interface HandTypeRef {
    make(cards: List<Card>): Hand;
    empty: Hand;
}

interface Hand {
    cards(): List<Card>;
    isEmpty(): boolean;
    has(card: Card): boolean;
    remove(card: Card): Hand;
}

class HandImpl implements Hand {
    private list: Set<Card>;

    private constructor(cards: Set<Card>) {
	this.list = cards;
    }
    static make(cards: List<Card>): Hand {
	return new HandImpl(Set(cards));
    }
    static empty(): Hand {
	return new HandImpl(Set.of());
    }

    cards(): List<Card> {
	return this.list.toList();
    }
    isEmpty(): boolean {
	return this.list.size == 0;
    }
    has(card: Card): boolean {
	return this.list.has(card);
    }

    remove(card: Card): Hand {
	return new HandImpl(this.list.delete(card));
    }
}

const Hand: HandTypeRef = {
    make: (cards: List<Card>) => HandImpl.make(cards),
    empty: HandImpl.empty()
}

type PlayerProps = { name: string }

type Player = RecordOf<PlayerProps>

interface PlayerTypeRef {
    make: (name: string) => Player
}

const makePlayer: Record.Factory<PlayerProps> = Record({name: 'Mike'})

const Player: PlayerTypeRef = {
    make: (name: string) => makePlayer({ name: name })
}

interface TrickTypeRef {
    fromList(list: List<Tuple<Player, Card>>): Trick;
    empty: Trick;
}

interface Trick {
    isEmpty(): boolean;
    cards(): List<Card>;
    toList(): List<Tuple<Player, Card>>;
    add(player: Player, card: Card): Trick;
    leadingCard(): Card;
}    

// first card first, most recent one last (reverse from Haskell)
class TrickImpl implements Trick {
    private list: List<Tuple<Player, Card>>;

    private constructor(list: List<Tuple<Player, Card>>) {
	this.list = list;
    }
    static empty() {
	return new TrickImpl(List.of());
    }
    static fromList(list: List<Tuple<Player, Card>>) {
	return new TrickImpl(list);
    }
    isEmpty(): boolean {
	return this.list.size == 0;
    }
    cards(): List<Card> {
	return this.list.map(t => t.snd());
    }
    toList(): List<Tuple<Player, Card>> {
	return this.list;
    }
    add(player: Player, card: Card): Trick {
	return new TrickImpl(this.list.push(Tuple(player, card)));
    }
    leadingCard(): Card {
	return this.list.first()!.snd();
    }
}

const Trick: TrickTypeRef = {
    fromList: (list: List<Tuple<Player, Card>>) => TrickImpl.fromList(list),
    empty: TrickImpl.empty()
}

interface PileTypeRef {
    make(cards: Card[]): Pile;
    empty: Pile
}

interface Pile {
    cards(): Card[];
    isEmpty(): boolean;
    addTrick(trick: Trick): Pile;
}

class PileImpl implements Pile {
#cards: Set<Card>
	
    private constructor(cards: Set<Card>) {
	this.#cards = cards;
    }
    static make(cards: Card[]): Pile {
	return new PileImpl(Set(cards));
    }
    static empty(): Pile {
	return new PileImpl(Set.of());
    }

    cards(): Card[] {
	return [...this.#cards];
    }
    isEmpty(): boolean {
	return this.#cards.size == 0;
    }
    addTrick(trick: Trick): Pile {
	return new PileImpl(this.#cards.union(Set(trick.cards())));
    }
}

const Pile: PileTypeRef = {
    make: (cards: Card[]) => PileImpl.make(cards),
    empty: PileImpl.empty()
}
