import Phaser from "phaser";
import board from "../../assets/board.svg";
import {
  transform_world_to_image_coords,
  scale_marble_size,
  color_map,
  get_n_m_board
} from "../../ml/board_utils.bs";
import { get_value, moveAction, winnerAction } from "../../ml/state.bs";
import { modify_slot, matches_any_pattern } from "../../ml/gridstones.bs";
import marble from "../../assets/tileGrey_30.png";
import check from "../../assets/green_checkmark.png";
import PatternCard from "./pattern_card";

const GRID_W = 6;
const GRID_H = 6;

const EMPTY = 0;
const PLACED = 1;
const NEW = 2;
const LOCKED = 3;

const initMarble = () => ({ state: EMPTY, sprite: null });

const getBoardIdx = (x, y) => y * GRID_H + x;

export default class MainScene extends Phaser.Scene {
  constructor(config) {
    super({
      key: "board"
    });
    this.draw_board = this.drawBoard.bind(this);
    this.preload = this.preload.bind(this);
    this.init = this.init.bind(this);
    this.handleUpdateScores = this.handleUpdateScores.bind(this);
    this.board = [];
    this.boardMatrix = get_n_m_board(GRID_H, GRID_W);
    this.players = [];
    this.transform_image_coordinates = this.transform_image_coordinates.bind(
      this
    );
    this.drawHand = this.drawHand.bind(this);
    this.handleMove = this.handleMove.bind(this);
    this.isTurn = false;
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
    const patterns = this.hand;
    this.handContainer = this.add.container();;
    const padding = 20;
    const width = this.sys.canvas.width / 5 - padding;
    const y = this.sys.canvas.height * 0.8;
    this.cards = patterns.map(
      pattern => new PatternCard({ pattern, scene: this })
    );
    this.cards.forEach((card, i) => {
      card.x = width * i + padding * i;
      card.y = y;
      card.width = width;
      card.heigth = width;
      card.drawCard();
    });
  }

  startEndScreen(id) {
    this.game.scene.stop('board');
    this.game.scene.start('end', { ...this.config, isLost: id !== this.id });
  }

  addBoardEvents() {
    this.board.forEach(slot => {
      slot.zone.on("pointerdown", () => {
        if (this.isTurn) {
          this.handleSlotClick(slot)
        }
      });
    });
  }

  clearMarble(marble) {
    marble.state = "";
    marble.sprite.destroy();
  }

  handleSlotClick(slot) {
    const { zone, x_idx, y_idx, marble } = slot;
    const { x, y } = zone;
    if (!(marble.state === LOCKED || marble.state === NEW)) {
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
      if (matches.length > 0) {
        const [[index]] = matches;
        this.cards[index].drawDoneOverlay();
        this.cards.splice(index, 1)
      }
      this.finishTurn(x_idx, y_idx);
      marble.state = newState;
    }
  }

  finishTurn(x_idx, y_idx) {
    this.board.forEach(slot => {
      if (slot.marble.state === NEW) {
        slot.marble.state = PLACED;
      }
    });
    if(this.isTurn) this.sendMove(x_idx, y_idx);
  }

  transform_image_coordinates(x, y) {
    return transform_world_to_image_coords(
      x,
      y,
      this.sys.canvas.width,
      this.sys.canvas.height
    );
  }

  init(config) {
    this.config = config;
    this.players = config.players;
    this.id = config.id;
    this.sendMove = config.sendMove;
    this.sendWinner = config.sendWinner;
    this.hand = config.hand;
    this.moveSubscriptionIdx = config.subscribe(moveAction,
      state => this.handleMove(state));
    this.winnerSubscriptionIdx = config.subscribe(winnerAction, state => this.startEndScreen(get_value(state, winnerAction)))
  }

  handleMove(state) {
    const { x, y, nextPlayer } = get_value(state, moveAction);
    if (x > 0 && y > 0 && !this.isTurn) {
      this.handleSlotClick(this.board[getBoardIdx(x, y)]);
    }
    this.isTurn = nextPlayer === this.id ? true : false;
    this.nextPlayer = nextPlayer;
  }

  lockSlot(x, y){
    this.board[getBoardIdx(x, y)].marble.state = LOCKED;
  }

  lockRow(idx){
    if(idx < GRID_H){
      for(let i = 0; i < GRID_W; i++) {
        this.lockSlot(i, idx)
      }
    }
  }

  lockCol(idx){
    if(idx < GRID_W){
      for(let j = 0; j < GRID_H; j++ ){
        this.lockSlot(idx, j)
      }    
    }
  }

  restrictBoard() {
    if (this.players.length < 4) {
      this.lockRow(GRID_H - 1)
      this.lockCol(GRID_W - 1)
    }
    if (this.players.length < 3){
      this.lockCol(0);
      this.lockRow(0);
    }
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
      0.15 * this.sys.canvas.height
    );
    this.restrictBoard();
    this.addBoardEvents();
    this.drawHand();
    this.scores = [0, 0, 0, 0].map((_, idx) => this.addScoreText(16, 16 + 16 * idx));
  }

  addScoreText(x, y) {
    return this.add.text(x, y, ``, { fontSize: '16px', fill: '#000' });
  }

  handleUpdateScores() {
    this.players.forEach(({ id, score }, idx) => {
      this.scores[idx].setFontStyle(this.nextPlayer === id ? 'bold' : '');
      this.scores[idx].text = `Player${idx + 1} : ${score} ${id === this.id ? "(me)" : ""}`;
    })
  }

  update() {
    this.handleUpdateScores();
    if (this.cards && this.cards.length === 0) {
      // restart game
      this.sendWinner(this.id);
    }
  }
}

if (module.hot) {
  module.hot.accept();
}
