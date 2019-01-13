import game from "./game";
import _Phaser from "./ml/phaser.bs";
import { initMap, dispatch , game_state, id_event, iD, players_event, pLAYERS, phase_event, move_event, mOVE, hand_event, pHASE, hAND, wINNER} from "./ml/state.bs";
import { init_config } from "./ml/utils.bs";
const socket = new WebSocket('ws://127.0.0.1:8081');

let listeners = initMap();

const config = init_config(game_state, subscribeGameState, sendMove, sendWinner, handleRegister, sendStartMessage);
console.log(config)
socket.addEventListener('open',  () => {
  Object.keys(game.scene.keys).forEach(key => console.log(key))
  //game.scene.start("test1");
  game.scene.start("menu", init_config(game_state, subscribeGameState, sendMove, sendWinner, handleRegister, sendStartMessage));
});

socket.addEventListener('message', event => {
  const parsed = JSON.parse(event.data);
  handleEvent(parsed);
});
menu
const handleRegister = () => {
  const message = { type: "REGISTER" };
  socket.send(JSON.stringify(message));
}
const handleEvent = data => {
  switch(data.type){
    case "ID": gameState = dispatch_game_state(id_event, iD(data.id)); break;
    case "PLAYERS": gameState = dispatch_game_state(players_event, pLAYERS(data.players));  break;
    case "PHASE": gameState = dispatch_game_state(phase_event, pHASE(data.phase)); break;
    case "MOVE": gameState = dispatch_game_state(move_event, mOVE(data.move)); break;
    case "HAND": gameState = dispatch_game_state(hand_event, hAND(JSON.parse(data.hand))); break;
    case "WINNER": gameState = dispatch_game_state(winnerAction, wINNER(data.id)); break;
  }
}

const subscribeGameState = (_event, fn) => {
  const [ newListeners, idx] = subscribe(listeners, _event, state => fn(state));
  listeners = newListeners;
  return idx;
}

const sendStartMessage = () => {
  socket.send(JSON.stringify({ type: "PHASE", phase: "start"}))
}

const sendMove = (x, y) => {
  socket.send(JSON.stringify({type: "MOVE", move: JSON.stringify({ x, y })}))
}

const sendWinner = (id) => {
  socket.send(JSON.stringify({type: "WINNER", id}))
}

