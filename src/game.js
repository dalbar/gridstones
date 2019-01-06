import Phaser from "phaser";
import Board from "./scenes/board_scene";
import Menu from "./scenes/menu"

class MyGame extends Phaser.Game {
  constructor() {
    super({
      width: 600,
      height: 800,
      type: Phaser.AUTO,
      backgroundColor: '#f3cca3',
      scene: [Menu, Board]
    });
  }
}
const game = new MyGame();

export default game;


//      backgroundColor: '#f3cca3',