import Phaser from "phaser";
import { scale_marble_size } from "./board_utils.bs";
const GRID_W = 3;
const GRID_H = 3;

export default class PatternCard {
  constructor({ pattern, scene, x = 0, y = 0, width = 0, heigth = 0 }){
    this.isDone = false;
    this.pattern = pattern;
    this.scene = scene;
    this.drawCard = this.drawCard.bind(this);
    this.x = x;
    this.y = y;
    this.width = width;
    this.heigth = heigth;
  }
  
  drawDoneOverlay(){
    if(!this.isDone){
      this.isDone = true;
      const overlay = this.scene.add.graphics();
      const doneSprite = this.scene.add.sprite(this.width * 0.5, this.heigth * 0.5, "check");
      doneSprite.setOrigin(0.5, 0.5);
      doneSprite.displayHeight = this.heigth * 0.3;
      doneSprite.displayWidth = this.width * 0.3;
      overlay.fillStyle(parseInt("757575", 16), 0.5);
      overlay.fillRect(0,0,this.width,this.heigth);
      this.cardContainer.add(overlay)
      this.cardContainer.add(doneSprite);

    }
  }
  drawCard(){
    this.cardContainer = this.scene.add.container();
    const sWidth = this.width / GRID_W;
    const sHeight = this.heigth / GRID_H;
    const [mWidth, mHeight] = scale_marble_size(sWidth, sHeight, 30);

    for (let i = 0; i < GRID_H; i++) {
      for (let j = 0; j < GRID_W; j++) {
        const slot = this.scene.add.graphics();
        const sX = j * sWidth;
        const sY = i * sHeight;
        slot.lineStyle(5, parseInt("E1E2E1", 16), 1.0);
        slot.fillStyle(parseInt("bbdefb", 16), 1.0);
        slot.beginPath();
        //draw top border if needed
        if (i === 0) {
          slot.moveTo(sX, sY);
          slot.lineTo(sX + sWidth, sY);
        }
        //draw right and bottom border
        slot.moveTo(sX + sWidth, sY);
        slot.lineTo(sX + sWidth, sY + sHeight);
        slot.lineTo(sX, sY + sHeight);
        //draw left border if needed
        if (j === 0) {
          slot.lineTo(sX, sY);
        }
        slot.fillRect(j * sWidth, i * sHeight, sWidth, sHeight);
        slot.strokePath();
        this.cardContainer.add(slot);
        if(this.pattern[i][j] === 1){
          const marbleSprite = this.scene.add.sprite(sX + sWidth * 0.5, sY + sHeight * 0.5, "marble");
          this.cardContainer.add(marbleSprite);
          marbleSprite.displayHeight = mHeight;
          marbleSprite.displayWidth = mWidth;
        }
      }
    }
    this.cardContainer.setPosition(this.x, this.y);
  }
}
