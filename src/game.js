import Phaser from "phaser";
import Menu from "./scenes/menu"
import End from "./scenes/end_screen";
import Board from "./ml/board.bs";

class MyGame extends Phaser.Game {
  constructor() {
    super({
      width: 600,
      height: 800,
      type: Phaser.AUTO,
      backgroundColor: '#f3cca3',
      scene: [Board]
    });
  }
}
const game = new MyGame();


console.log(Board);

export default game;



//      backgroundColor: '#f3cca3',