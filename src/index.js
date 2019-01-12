import game from "./game";
import _Phaser from "./ml/phaser.bs";
import { initMap, subscribe, dispatch, idAction, playersAction, moveAction, gamePhaseAction, handAction, winnerAction } from "./ml/state.bs";

const socket = new WebSocket('ws://127.0.0.1:8081');
let gameState = initMap();
let listeners = initMap();

socket.addEventListener('open',  () => {
  Object.keys(game.scene.keys).forEach(key => console.log(key))
  //game.scene.start("test1");
  game.scene.start("menu", {subscribe: subscribeGameState , sendStartMessage, sendMove, sendWinner, handleRegister});
});

socket.addEventListener('message', event => {
  const parsed = JSON.parse(event.data);
  handleEvent(parsed);
});

const handleRegister = () => {
  const message = { type: "REGISTER" };
  socket.send(JSON.stringify(message));
}
const handleEvent = data => {
  switch(data.type){
    case "ID": gameState = dispatchGameState(idAction, data.id); break;
    case "PLAYERS": gameState = dispatchGameState(playersAction, data.players);  break;
    case "PHASE": gameState = dispatchGameState(gamePhaseAction, data.phase); break;
    case "MOVE": gameState = dispatchGameState(moveAction, JSON.parse(data.move)); break;
    case "HAND": gameState = dispatchGameState(handAction, JSON.parse(data.hand)); break;
    case "WINNER": gameState = dispatchGameState(winnerAction, data.id); break;
  }
}

const dispatchGameState = (msg, data) => dispatch(gameState, listeners, msg, data);

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

