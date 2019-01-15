var express = require('express');
var app = express();
const WebSocket = require('ws');
const uuidv4 = require('uuid/v4');
const decks = require('./deck');

const wss = new WebSocket.Server({ host: "127.0.0.1", port: 8081 });
const players = new Map();
const playOrder = [];
let curDeck = [];
let curPlayer = 0;


let gameState = "waiting"

const broadcast = message => {
  players.forEach(player => player.ws.send(message));
}

const hanldeMessage = (message, ws) => {
  switch (message.type) {
    case "REGISTER":
      if (gameState !== "start" && players.size < 4) handleRegister(ws);
      ws.send(JSON.stringify({ type: "PHASE", phase: gameState }));
      break;
    case "PHASE":
      if (message.phase === "start") handleStart();
      break;
    case "MOVE":
      const move = JSON.parse(message.move);
      handleMove(move);
      break;
    case "SCORE": 
      const {id } = message;
      handleScore(id)
      break;
  }
}

const handleScore = id => {
  const cur_player = players.get(id);
  if (cur_player.score === 1) handleWinner(id)
  else {
    players.set(id, Object.assign({}, cur_player, { score: cur_player.score - 1}));
    broadcastAllPlayers();
  }
}

const handleWinner = id => {
  players.forEach((v, i) => players.set(i, Object.assign({}, v, {score: 5})));
  broadcast(JSON.stringify({type: "WINNER", id}));
  playOrder.splice(0, playOrder.length);
  gameState = "waiting"
}

const handleClose = ws => {
  const { playerID } = ws;
  players.delete(playerID);
  handleWinner("");
  broadcastAllPlayers();
}

const filterGameRelevant = ({ id, score }) => {
  return { score, id }
}

const handleStart = () => {
  if (players.size > 1 && players.size < 5) {
    gameState = "start";
    players.forEach((value, id) => {
      playOrder.push(id);
      dealHand(value.ws);
    });
    broadcast(JSON.stringify({ type: "PHASE", phase: "start" }));
    const move = JSON.stringify({ x: -1, y: -1, nextPlayer: playOrder[curPlayer] });
    broadcast(JSON.stringify({ type: "MOVE", move: move }))
  }
}

const handleMove = ({ x, y }) => {
  curPlayer = (curPlayer + 1) % playOrder.length;
  const move = JSON.stringify({ x: x, y: y, nextPlayer: playOrder[curPlayer] });
  broadcast(JSON.stringify({ type: "MOVE", move: move }))

}

const handleRegister = ws => {
  const playerID = uuidv4();
  players.set(playerID, { ws: ws, score: 5, id: playerID });
  ws.playerID = playerID;
  const message = JSON.stringify({ id: playerID, type: "ID" })
  ws.send(message);
  broadcastAllPlayers();
}

const dealHand = ws => {
  const getRandomInt = max => {
    return Math.floor(Math.random() * Math.floor(max));
  };
  if(curDeck.length < 5){
    curDeck = decks.createDeck();
  }
  const hand = [...Array(5).keys()].map(() =>
    curDeck.splice(getRandomInt(curDeck.length - 1), 1)[0]
  );

  ws.send(JSON.stringify({ type: "HAND", hand: JSON.stringify(hand) }));

}
broadcastAllPlayers = () => {
  const gameRelevantMessage = [];
  players.forEach(value => gameRelevantMessage.push(filterGameRelevant(value)));
  broadcast(JSON.stringify({ type: "PLAYERS", players: gameRelevantMessage }));
}



wss.on('connection', function connection(ws) {
  ws.on('message', function incoming(message) {
    const parsed = JSON.parse(message);
    hanldeMessage(parsed, ws);
  });
  ws.on('close', () => handleClose(ws));
});

app.use(express.static('dist'))
app.listen(3001);