import Phaser from "phaser";
import {playersAction, idAction, get_value, gamePhaseAction} from "../../state.bs";

export default class MenuScene extends Phaser.Scene {
  constructor() {
    super({
      key: "menu"
    });
    this.players = [];
    this.id = "";
  }

  init(config){
    this.config = config;
    this.playerSubscriptionIdx = config.subscribe(playersAction, state => {
      this.players = get_value(state, playersAction)
    });
    this.idSubscriptionIdx = config.subscribe(idAction, state => this.id = get_value(state, idAction))
    this.phaseSunscriptionIdx = config.subscribe(gamePhaseAction, state => this.handleGameStart(get_value(state, gamePhaseAction)))
  }

  handleGameStart(phase){
    console.log(phase)
    if(phase === "start"){
      if(this.id !== "")
      this.game.scene.start('board', {...this.config, players: this.players, id: this.id });
      else this.startButton.text = "Waiting"
    }

  }

  create(){
    this.startButton = this.add.text(this.sys.canvas.width * 0.5, this.sys.canvas.height * 0.5, 'Start', { fontSize: '32px' ,fill: '0' });
    this.startButton.setOrigin(0.5, 0.5);
    this.startButton.setInteractive();
    this.startButton.on('pointerdown', () => this.config.sendStartMessage());
    this.playerCountText = this.add.text(this.sys.canvas.width * 0.5, this.sys.canvas.height * 0.5 - 32 - 10, '', { fontSize: '16px', fill: '0'});
    this.playerCountText.setOrigin(0.5, 0.5);
  }

  update(){
    this.playerCountText.text = `Number of players: ${this.players.length}`;
  }
}