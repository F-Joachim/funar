export { type Endpoints, type HeartsMessage,
	 processGameCommands, dealHands, makeUpdate }

import { GameEvent, GameCommand } from './GameEvent.ts';
import { List, Map } from 'immutable';
import { ViewModel } from './ViewModel.ts';
import { type ViewCommand, type Endpoint, makePostViewCommand } from './ViewUpdate.ts';
import { Player, Card } from './Cards.ts';
import { encodeGameCommand, gameCommandsDecoder,
	 encodeGameEvent, gameEventsDecoder } from './HeartsJson.ts';

type Endpoints =
    { Table: Endpoint,
      Players: Map<Player, Endpoint>
    };

type HeartsMessage =
    | { tag: 'GotGameCommands', commands: List<GameCommand> }
    | { tag: 'GotGameEvents', events: List<GameEvent> }
    | { tag: 'ProcessGameCommands' }
    | { tag: 'DealHands' }

const makeGotGameCommands: (commands: List<GameCommand>) => HeartsMessage =
    (commands) => ({tag: 'GotGameCommands', commands: commands});

const makeGotGameEvents: (commands: List<GameEvent>) => HeartsMessage =
    (events) => ({tag: 'GotGameEvents', events: events});

const processGameCommands: HeartsMessage = { tag: 'ProcessGameCommands' };
const dealHands: HeartsMessage = { tag: 'DealHands' };

const gameCommandsMessageDecoder = gameCommandsDecoder.map(makeGotGameCommands);
const gameEventsMessageDecoder = gameEventsDecoder.map(makeGotGameEvents);

const makeUpdate: (endpoints: Endpoints) => (message: HeartsMessage, model: ViewModel) => [ViewModel, List<ViewCommand<HeartsMessage>>] =
    (endpoints) => (message, model) => {
	switch (message.tag) {
	    case 'GotGameCommands':
		return [ViewModel.addPendingCommands(model, message.commands),
			List.of<ViewCommand<HeartsMessage>>()];
	    case 'GotGameEvents':
		return [ViewModel.processEvents(message.events, model),
			message.events.flatMap(event =>
			    endpoints.Players.valueSeq().map((endpoint: string) =>
				makePostViewCommand(endpoint, encodeGameEvent(event), gameCommandsMessageDecoder)))];
	    case 'ProcessGameCommands': {
		const [commands, newModel] = ViewModel.getPendingCommands(model);
		return [newModel,
			commands.map(command =>
			    makePostViewCommand(endpoints.Table, encodeGameCommand(command),
						gameEventsMessageDecoder))];
	    }
	    case 'DealHands':
		return [model,
			List.of(makePostViewCommand(endpoints.Table,
						    encodeGameCommand(GameCommand.deckToDealHands(Card.deck.shuffle(),
												  model.players)),
						    gameEventsMessageDecoder))];
	}
    };

