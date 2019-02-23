import Phaser from "phaser"
import PlayerBase from "./player_base"
import Arrow from "./arrow"
import Ball from "./ball"
import Cell from "./cell"
import Utils from "./utils"

const gridColor = 0xcccccc //grey
const base1Color = 0xff0000 //red
const base2Color = 0x0000ff //blue
const drawColor = 0x00ff00 //green

class Game {
  constructor() {
    if (!window.gameId) {
      return
    }
    this.status = "new"
    this.base1 = null
    this.base2 = null
    this.arrows = []
    this.cells = []
    this.balls = {}
    this.turn = 0
    this.width = 840
    this.height = 840
    this.padding = 20
    this.gameConfig = null
    let config = {
      width: this.width,
      height: this.height,
      type: Phaser.AUTO,
      parent: 'game',
      backgroundColor: "#fff",
      scene: {
          preload: this.preload,
          create: this.create,
          update: this.update
      }
    };
    this.game = new Phaser.Game(config)
  }

  preload() {
    this.load.image('arrow', '/images/sprites/arrow.png');
    this.load.image('arrow_p1', '/images/sprites/arrow_p1.png');
    this.load.image('arrow_p2', '/images/sprites/arrow_p2.png');
  }
  create() {
    let minSize = Math.min(window.innerHeight - document.getElementById('game-info').clientHeight, document.getElementById('game').clientWidth, 840)
    this.game.resize(minSize, minSize)
    game.width = minSize
    game.height = minSize
  }
  update() {
    if (!game.gameConfig || game.status != "running") {
      return;
    }
    let speed = (game.width - game.padding * 2) / game.gameConfig.rows / game.gameConfig.cell_width * game.gameConfig.ball_speed / 60
    let ballKeys = Object.keys(game.balls)
    for(let i = 0; i < ballKeys.length; i++) {
      let ball = game.balls[ballKeys[i]]
      let x = ball.x
      let y = ball.y
      switch (ball.direction) {
        case 0: y -= speed; break;
        case 1: x += speed; break;
        case 2: y += speed; break;
        case 3: x -= speed; break;
      }
      ball.moveTo(x, y)
    }
  }

  initBoard(board) {
    let scene = this.game.scene.getAt(0)
    this.gameConfig = board.config
    this.status = "running"
    // Grid
    let graphics = scene.add.graphics({ lineStyle: { width: 4, color: gridColor } })
    let cell_height = (this.height - this.padding * 2) / board.config.rows
    let cell_width = (this.width - this.padding * 2) / board.config.cols
    for(let i = 0; i <= board.config.rows; i++) {
      let line = new Phaser.Geom.Line(this.padding, this.padding + i * cell_height, this.width - this.padding, this.padding + i * cell_height);
      graphics.strokeLineShape(line);
    }
    for(let i = 0; i <= board.config.cols; i++) {
      let line = new Phaser.Geom.Line(this.padding + i * cell_width, this.padding, this.padding + i * cell_height, this.height - this.padding);
      graphics.strokeLineShape(line);
    }
    // Bases
    this.base1 = new PlayerBase(scene, Object.assign(this.baseConfig(board), {color: base1Color,}), board.bases["0"])
    this.base2 = new PlayerBase(scene, Object.assign(this.baseConfig(board), {color: base2Color,}), board.bases["1"])

    // Arrows
    for(let y = 0; y <= board.config.rows; y++) {
      let arrowY = y * board.config.cell_width
      this.arrows[arrowY] = []
      for(let x = 0; x <= board.config.cols; x++) {
        let arrowX = x * board.config.cell_width
        this.arrows[arrowY][arrowX] = new Arrow(scene, this.baseConfig(board), board.arrows[arrowY.toString()][arrowX.toString()])
      }
    }

    // Cells
    for(let y = 0; y < board.config.rows; y++) {
      let cellY = y * board.config.cell_width
      this.cells[cellY] = []
      for(let x = 0; x < board.config.cols; x++) {
        let cellX = x * board.config.cell_width
        this.cells[cellY][cellX] = new Cell(scene, this.baseConfig(board), cellX, cellY, board.arrows)
      }
    }
  }

  updateBoard(board) {
    let scene = this.game.scene.getAt(0)
    if (this.turn == 0) {
      this.initBoard(board)
    }

    // Bases
    this.base1.updateHealth(board.bases["0"].health)
    this.base2.updateHealth(board.bases["1"].health)

    // Arrows
    for(let y = 0; y <= board.config.rows; y++) {
      let arrowY = y * board.config.cell_width
      for(let x = 0; x <= board.config.cols; x++) {
        let arrowX = x * board.config.cell_width
        this.arrows[arrowY][arrowX].update(board.arrows[arrowY.toString()][arrowX.toString()].player, board.arrows[arrowY.toString()][arrowX.toString()].direction)
      }
    }

    // Balls
    let current_balls_keys = Object.keys(this.balls)
    let update_balls_keys = Object.keys(board.balls)
    let remove_balls_keys = current_balls_keys.filter(key => !update_balls_keys.includes(key))
    for (let i = 0; i < remove_balls_keys.length; i ++) {
      this.balls[remove_balls_keys[i]].destroy()
      delete this.balls[remove_balls_keys[i]]
    }
    let new_balls_keys = update_balls_keys.filter(key => !current_balls_keys.includes(key))
    for (let i = 0; i < new_balls_keys.length; i ++) {
      this.balls[new_balls_keys[i]] = new Ball(scene, this.baseConfig(board), board.balls[new_balls_keys[i]])
    }
    let same_balls_keys = update_balls_keys.filter(key => current_balls_keys.includes(key))
    for (let i = 0; i < same_balls_keys.length; i ++) {
      this.balls[same_balls_keys[i]].update(board.balls[same_balls_keys[i]].x, board.balls[same_balls_keys[i]].y, board.balls[same_balls_keys[i]].health, board.balls[same_balls_keys[i]].direction)
    }

    // Cells
    for(let y = 0; y < board.config.rows; y++) {
      let cellY = y * board.config.cell_width
      for(let x = 0; x < board.config.cols; x++) {
        let cellX = x * board.config.cell_width
        this.cells[cellY][cellX].update(board.arrows)
      }
    }
    
    this.turn++;
  }

  updateArrow(arrow) {
    this.arrows[arrow.y][arrow.x].update(arrow.player, arrow.direction)
  }

  finish(payload) {
    let scene = this.game.scene.getAt(0)
    this.status = "finished"
    let text = "Player 1 wins!"
    let color = Utils.decimalColorToHTMLcolor(base1Color)
    if ( (this.base1.health <= 0 && this.base2.health <= 0) || (this.base1.health == this.base2.health)) { // draw
      text = "Draw!"
      color = Utils.decimalColorToHTMLcolor(drawColor)
    } else if (this.base1.health <= 0 || this.base1.health < this.base2.health) { // player 2 win
      text = "Player 2 wins!"
      color = Utils.decimalColorToHTMLcolor(base2Color)
    }
    scene.add.text(this.width / 2, this.height / 2, text,{
      fontFamily: 'Arial',
      color: color,
      align: 'center',
    }).setFontSize(this.height / 8).setOrigin(0.5, 0.5)
  }

  baseConfig(board) {
    return Object.assign(board.config, {
      field_width: this.width,
      field_height: this.height,
      field_padding: this.padding,
      player1: board.player1,
      player2: board.player2,
      player1_color: base1Color,
      player2_color: base2Color
    })
  }
}

const game = new Game();

export default game;