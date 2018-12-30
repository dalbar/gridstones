import Phaser from "phaser";
import Main from "./scenes/board_scene/main";
 
class MyGame extends Phaser.Game {
  constructor() {
    super({
      width: 600,
      height: 800,
      type: Phaser.AUTO,
      backgroundColor: '#f3cca3',
      scene: [Main]
    });
  }
}
const game = new MyGame();

export default game;