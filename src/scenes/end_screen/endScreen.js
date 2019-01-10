import Phaser from "phaser";

export default class EndScreen extends Phaser.Scene {
  constructor() {
    super({
      key: "end"
    });
  }

  init(config){
    this.isLost = config.isLost;
  }

  create(){
    console.log(this.isLost);
    const endMsg = this.isLost ? "You lost the game!": "You won the game!";
    const endMsgObject = this.add.text(this.sys.canvas.width * 0.5, this.sys.canvas.height * 0.5, endMsg, { fontSize: '32px' ,fill: '0' });
    endMsgObject.setOrigin(0.5, 0.5);
  }

  update(){
  }
}