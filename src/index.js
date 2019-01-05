import game from "./game";

const socket = new WebSocket('ws://localhost:8080');

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
    case "ID": console.log("ID is ", data)
  }
}