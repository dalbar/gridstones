const WebSocket = require('ws');
const uuidv4 = require('uuid/v4')

const wss = new WebSocket.Server({ port: 8080 });
const players = new Map();
const playOrder = [];

const gameState = 0

const broadcast = message => {
  players.forEach(player => player.ws.send(message));
}

const hanldeMessage = (message, ws) => {
  console.log(message);
  switch(message.type){
    case "register": 
      handleRegister(ws);
      break;
    case "quit": 
      console.log("quit")
  }
}

const filterGameRelevant = ({ id, score }) => {
  return { score, id }
}
const handleRegister = ws => {
  if(gameState === 0){
    const playerID = uuidv4();
    players.set(playerID, { ws: ws, score: 5, id: playerID});
    playOrder.push(playerID);
    ws.playerID = playerID;
    const message = JSON.stringify({id: playerID, type: "ID"})
    ws.send(message);
    broadcastAllPlayers();
  }
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

