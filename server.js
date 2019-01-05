const WebSocket = require('ws');
const uuidv4 = require('uuid/v4')

const wss = new WebSocket.Server({ port: 8080 });
const players = {};

const hanldeMessage = (message, ws) => {
  console.log(message);
  switch(message.type){
    case "register": handleRegister(ws)
  }
}

const handleRegister = ws => {
  const playerID = uuidv4();
  players[playerID] = { id: uuidv4()};
  const message = JSON.stringify({id: playerID, type: "ID"})
  console.log(message);
  ws.send(message);

}

wss.on('connection', function connection(ws) {
  ws.on('message', function incoming(message) {
    const parsed = JSON.parse(message);
    hanldeMessage(parsed, ws);
  });
});