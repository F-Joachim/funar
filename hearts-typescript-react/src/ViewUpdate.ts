export { type Endpoint, type ViewCommand, makeExecuteUpdate, makePostViewCommand }
import { useState } from 'react';
import { type Json } from './Json.ts';
import { type Decoder } from './JsonDecoder.ts';
import { List } from 'immutable';

// note this runs asynchronously
const postJson = (endpoint: string, body: Json): Promise<Json> =>
    fetch(endpoint, {
	method: 'POST',
	headers: {
	    'Content-Type': 'application/json',
	},
	body: JSON.stringify(body),
    }).then(response => {
	console.log(`postJson ${endpoint} ${JSON.stringify(body)}`);
	if (!response.ok) {
	    throw new Error(`HTTP error! status: ${response.status}`);
	}
	return response.json();
    });

type Endpoint = string

type ViewCommand<Message> =
    | { tag: 'Post', endpoint: Endpoint, body: Json, decoder: Decoder<Message> }

const makePostViewCommand: <Message>(endpoint: string, body: Json, decoder: Decoder<Message>) => ViewCommand<Message> =
    (endpoint, body, decoder) => ({tag: 'Post', endpoint: endpoint, body: body, decoder: decoder})

const makeExecuteUpdate: <Model, Message>(initialModel: Model, update: (message: Message, model: Model) => [Model, List<ViewCommand<Message>>]) =>
    [Model, (message: Message) => void] =
    <Model, Message>(initialModel: Model,
		     update: (message: Message, model: Model) => [Model, List<ViewCommand<Message>>]) => {
	const [model, setModel] = useState(initialModel);

	const executeCommands: (commands: List<ViewCommand<Message>>) => void =
	    (commands) => {
		// force sequential execution
		if (!commands.isEmpty()) {
		    executeCommand(commands.first()!!).then(_ =>
			executeCommands(commands.shift()));
		};
	    };

	const executeCommand: (command: ViewCommand<Message>) => Promise<void> =
	    (command) =>
		postJson(command.endpoint, command.body)
		    .then(json => {
			command.decoder.decode(json).caseOf({
			    Left: (decodeError) => { console.log(`decode error: ${JSON.stringify(decodeError)}`) },
			    Right: (message) => executeUpdate(message)
			})});
	
	const executeUpdate = (message: Message) => {
	    const viewCommandsPromise = new Promise<List<ViewCommand<Message>>>((resolve, _reject) =>
		setModel(model => {
		    const [newModel, viewCommands] = update(message, model);
		    resolve(viewCommands);
		    return newModel
		}));
	    viewCommandsPromise.then(executeCommands);
	};
	return [model, executeUpdate];
    };
