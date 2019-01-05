import Phaser from "phaser";
import board from "../../assets/board.svg";
import {
  transform_world_to_image_coords,
  scale_marble_size,
  color_map,
  get_n_m_board
} from "./board_utils.bs";
import { modify_slot, has_match, pattern1, matches_any_pattern } from "./gridstones.bs";
import PatternCard from "./pattern_card";
import marble from "../../assets/tileGrey_30.png";
import { createDeck } from "./deck";
import check from "../../assets/green_checkmark.png";

const GRID_W = 6;
const GRID_H = 6;

const EMPTY = 0;
const PLACED = 1;
const NEW = 2;
const LOCKED = 3;

const initMarble = () => ({ state: EMPTY, sprite: null });

export default class MainScene extends Phaser.Scene {
  constructor() {
    super({
      key: "Main"
    });
    this.board = [];
    this.boardMatrix = get_n_m_board(GRID_H, GRID_W);
    this.draw_board = this.drawBoard.bind(this);
    this.preload = this.preload.bind(this);
    this.deck = createDeck();
    this.transform_image_coordinates = this.transform_image_coordinates.bind(
      this
    );
    this.drawHand = this.drawHand.bind(this);
  }

  drawBoard(w, h, x_offset = 0, y_offset = 0) {
    this.boardContainer = this.add.container();
    const sWidth = w / GRID_W;
    const sHeight = h / GRID_H;
    for (let i = 0; i < GRID_H; i++) {
      for (let j = 0; j < GRID_W; j++) {
        const slot = this.add.graphics();
        const fillColor = parseInt(color_map[j][i], 16);
        const sX = j * sWidth;
        const sY = i * sHeight;
        const hitZone = this.add.zone(
          sX + 0.5 * sWidth,
          sY + 0.5 * sHeight,
          sWidth,
          sHeight
        );

        slot.lineStyle(5, 0, 1.0);
        slot.fillStyle(fillColor, 1.0);
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
        hitZone.setInteractive();
        this.boardContainer.add(slot);
        this.boardContainer.add(hitZone);
        this.board.push({
          x_idx: j,
          y_idx: i,
          zone: hitZone,
          graphics: slot,
          marble: initMarble()
        });
      }
      this.boardContainer.setPosition(x_offset, y_offset);
    }
  }

  drawHand() {
    this.handContainer = this.add.container();;
    const padding = 20;
    const width = this.sys.canvas.width / 5 - padding;
    const y = this.sys.canvas.height * 0.8;
    const startingHand = 5;
    this.cards = [...Array(startingHand).keys()].map(
      i => new PatternCard({ pattern: this.deck.pop(0), scene: this })
    );
    this.cards.forEach((card, i) => {
      card.x = width * i + padding * i;
      card.y = y;
      card.width = width;
      card.heigth = width;
      card.drawCard();
    });
  }

  drawEndScreen(){
    const { width, height } = this.sys.canvas;
    const endScreenContainer = this.add.container();
    const overlay = this.add.graphics();
    overlay.fillStyle(parseInt("757575", 16), 0.1);
    overlay.fillRect(0,0,width,height)

    endScreenContainer.add(overlay);

    const winText = this.add.text(16, 32, `You won the game!`, { fontSize: '32px', fill: '#fff59d' });
    winText.setPosition(width/2, height/2);
    winText.setOrigin(0.5,0.5);

  }
  addBoardEvents() {
    this.board.forEach(slot => {
      slot.zone.on("pointerdown", () => this.handleSlotClick(slot));
    });
  }

  clearMarble(marble) {
    marble.state = "";
    marble.sprite.destroy();
  }

  handleSlotClick(slot) {
    const { zone, x_idx, y_idx, marble } = slot;
    const { x, y } = zone;
    if(marble.state === LOCKED ||marble.state === NEW){
      return
    }
    const newState = modify_slot(this.boardMatrix, [x_idx, y_idx], marble.state);
    if (newState === EMPTY) {
      marble.sprite.destroy();
    } else {
      const [mWidth, mHeight] = this.marbleDim;
      const marbleSprite = this.add.sprite(x, y, "marble");
      this.boardContainer.add(marbleSprite);
      marbleSprite.displayHeight = mHeight;
      marbleSprite.displayWidth = mWidth;
      marble.sprite = marbleSprite;
    }
    const patterns = this.cards.map(card => card.pattern);
    const matches = matches_any_pattern(this.boardMatrix, patterns);
    if(matches.length > 0){
      const [ [ index ]] = matches;
      this.cards[index].drawDoneOverlay();
      this.cards.splice(index, 1)
    }
    this.finishTurn();
    marble.state = newState;

  }

  finishTurn(){
    console.log("next turn")
    this.board.forEach( slot => {
      if (slot.marble.state === NEW){
        slot.marble.state = PLACED;
      }
    })
  }

  transform_image_coordinates(x, y) {
    return transform_world_to_image_coords(
      x,
      y,
      this.sys.canvas.width,
      this.sys.canvas.height
    );
  }

  preload() {
    this.load.image("board", board);
    this.load.image("marble", marble);
    this.load.image("check", check);
  }

  create() {
    const boardWidth = 0.8 * this.sys.canvas.width;
    const boardHeight = 0.8 * this.sys.canvas.width;
    this.marbleDim = scale_marble_size(boardWidth, boardHeight, 30);
    this.drawBoard(
      boardWidth,
      boardHeight,
      0.1 * this.sys.canvas.width,
      0.1 * this.sys.canvas.height
    );
    this.addBoardEvents();
    this.drawHand();
    this.ownScore = this.add.text(16, 16, ``, { fontSize: '16px', fill: '#000' });
    this.enemyScore = this.add.text(16, 32, `opponent's cards left: 5`, { fontSize: '16px', fill: '#000' });
  }

  update() {
    this.ownScore.text = `my cards left: ${this.cards.length}`;
    if(this.cards.length === 0){
      // restart game
      this.drawEndScreen();
    }
  }
}

if (module.hot) {
  module.hot.accept();
}
