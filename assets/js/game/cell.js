class Cell {
  constructor(scene, config, x, y, arrows) {
    this.config = config
    this.scene = scene
    this.player = null
    this.originalX = x
    this.originalY = y
    let cellHeight = (this.config.field_height - this.config.field_padding * 2) / this.config.rows
    let cellWidth = (this.config.field_width - this.config.field_padding * 2) / this.config.cols
    this.x = this.config.field_padding + x / this.config.cell_width * cellWidth
    this.y = this.config.field_padding + y / this.config.cell_width * cellHeight
    this.width = cellWidth
    this.height = cellHeight
    this.graphics = null
    this.update(arrows)
  }

  update(arrows) {
    if (this.graphics === null) {
      this.graphics = this.scene.add.graphics()
      this.graphics.setDepth(0)
    }
    let player = arrows[this.originalY.toString()][this.originalX.toString()].player
    if (player === null) {
      this.graphics.clear()
    } else {
      y_loop:
      for(let y = 0; y <= 1; y++) {
        let arrowY = this.originalY + y * this.config.cell_width
        for(let x = 0; x <= 1; x++) {
          let arrowX = this.originalX + x * this.config.cell_width
          if (arrows[arrowY.toString()][arrowX.toString()].player != player) {
            player = null
            break y_loop
          }
        }
      }
      if (player === null) {
        this.graphics.clear()
      } else if (this.player != player) {
        this.graphics.clear()
        this.player = player
        this.graphics.fillStyle((this.config.player1 == player) ? this.config.player1_color : this.config.player2_color, 0.3);
        let square = new Phaser.Geom.Rectangle(this.x, this.y, this.width, this.height);
        this.graphics.fillRectShape(square);
      }
    }
  }
}

export default Cell