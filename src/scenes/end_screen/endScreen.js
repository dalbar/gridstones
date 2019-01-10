import Phaser from "phaser";

export default class EndScreen extends Phaser.Scene {
  constructor() {
    super({
      key: "end"
    });
  }

  handleBack(){
    this.game.scene.stop("end");
    this.game.scene.start("menu", this.config);
  }

  init(config) {
    this.config = config;
    this.isLost = config.isLost;
  }

  create() {
    const endMsg = this.isLost ? "You lost the game!" : "You won the game!";
    const endMsgObject = this.add.text(this.sys.canvas.width * 0.5, this.sys.canvas.height * 0.5, endMsg, { fontSize: '32px', fill: '0' });
    endMsgObject.setOrigin(0.5, 0.5);

    const backButtonObject = this.add.text(this.sys.canvas.width * 0.5, this.sys.canvas.height * 0.5 + 32, "Back", { fontSize: '32px', fill: '0' });
    backButtonObject.setOrigin(0.5, 0.5);
    backButtonObject.setInteractive();
    backButtonObject.on('pointerdown', () => this.handleBack());
  }
}