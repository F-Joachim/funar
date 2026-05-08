import { Map, List } from 'immutable';
import { ViewModel } from './ViewModel.ts'
import { HeartsView, type Endpoints } from './View.tsx'
import { Player } from './Cards.ts'
import { StrictMode } from 'react';
import './cards.css'

function App() {
    const mike = Player.make('Mike')
    const peter = Player.make('Peter')
    const annette = Player.make('Annette')
    const nicole = Player.make('Nicole')
    const players = List.of(mike, peter, annette, nicole)

    const endpoints: Endpoints =
    { Table: "http://localhost:8080/command",
      Players: Map([[mike, "http://localhost:8001/event"],
		    [peter, "http://localhost:8002/event"],
		    [nicole, "http://localhost:8003/event"],
		    [annette, "http://localhost:8004/event"]]) };

    console.log('running App');
    
    return (
	<StrictMode>
	    <h1>Hearts</h1>
	    <HeartsView initialModel={ViewModel.initial(players)} endpoints={endpoints}/>
	</StrictMode>
    )
}

export default App
