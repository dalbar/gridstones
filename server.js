const WebSocket = require('ws');
const uuidv4 = require('uuid/v4');
const decks = require('./deck');

const wss = new WebSocket.Server({ port: 8080 });
const players = new Map();
const playOrder = [];
const curDeck = decks.createDeck();
let curPlayer = 0;


let gameState = "waiting"

const broadcast = message => {
  players.forEach(player => player.ws.send(message));
}

const hanldeMessage = (message, ws) => {
  switch(message.type){
    case "REGISTER": 
      if(gameState !== "start") handleRegister(ws);
      ws.send(JSON.stringify({ type: "PHASE", phase: gameState}));
      break;
    case "PHASE":
      if(message.phase === "start") handleStart(); 
      break;
    case "MOVE":
      const move = JSON.parse(message.move);
      handleMove(move);
  }
}

const filterGameRelevant = ({ id, score }) => {
  return { score, id }
}

const handleStart = () => {
  if(players.size > 1){
    gameState = "start";
    broadcast(JSON.stringify({ type: "PHASE", phase: "start" }));
    players.forEach((value, id) => {
      playOrder.push(id);
      dealHand(value.ws);
    });
    const move =  JSON.stringify({x: -1, y: -1, nextPlayer: playOrder[curPlayer]});
    broadcast(JSON.stringify({ type: "MOVE", move: move }))
  }
}

const handleMove = ({x, y}) => {
  curPlayer = (curPlayer + 1) % playOrder.length;
  const move =  JSON.stringify({x: x, y: y, nextPlayer: playOrder[curPlayer]});
  broadcast(JSON.stringify({ type: "MOVE", move: move }))

}

const handleRegister = ws => {
  const playerID = uuidv4();
  players.set(playerID, { ws: ws, score: 5, id: playerID});
  ws.playerID = playerID;
  const message = JSON.stringify({id: playerID, type: "ID"})
  ws.send(message);
  broadcastAllPlayers();
}

const dealHand = ws => {
  const getRandomInt = max => {
    return Math.floor(Math.random() * Math.floor(max));
  };
  const hand = [...Array(5).keys()].map( () => 
    curDeck.splice(getRandomInt(curDeck.length - 1), 1)[0] 
  );

  ws.send(JSON.stringify({ type: "HAND", hand: JSON.stringify(hand)}));

}
broadcastAllPlayers = () => {
  const gameRelevantMessage = [];
  players.forEach( value => gameRelevantMessage.push(filterGameRelevant(value)));
  broadcast(JSON.stringify({ type: "PLAYERS", players: gameRelevantMessage }));
}
const handleClose = ws => {
  const { playerID } = ws;
  players.delete(playerID);
}

wss.on('connection', function connection(ws) {
  ws.on('message', function incoming(message) {
    const parsed = JSON.parse(message);
    hanldeMessage(parsed, ws);
  });
  ws.on('close', () => handleClose(ws));
});

