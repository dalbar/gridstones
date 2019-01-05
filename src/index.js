import game from "./game";
import { initMap, subscribe, dispatch, idAction, playersAction, moveAction } from "./state.bs";

const socket = new WebSocket('ws://localhost:8080');
let gameState = initMap();
let listeners = initMap();

socket.addEventListener('open',  () => {
  const message = { type: "register" };
  socket.send(JSON.stringify(message));
});

socket.addEventListener('message', event => {
  const parsed = JSON.parse(event.data);
  handleEvent(parsed);
});

const handleEvent = data => {
  switch(data.type){
    case "ID": gameState = dispatchGameState(idAction, data.id); break;
    case "PLAYERS": gameState = dispatchGameState(playersAction, data.players);  break;
  }
}

const dispatchGameState = (msg, data) => dispatch(gameState, listeners, msg, data);

const subscribeGameState = (_event, fn) => {
  const [ newListeners, idx] = subscribe(listeners, _event, state => fn(state));
  listeners = newListeners;
  return idx;
}


game.scene.start("board", {state: gameState, subscribe: subscribeGameState});