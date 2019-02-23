import {channel} from "../socket"

class Arrow {
  constructor(scene, config, arrow) {
    this.config = config
    this.scene = scene
    this.player = null
    this.direction = null
    let cellHeight = (config.field_height - config.field_padding * 2) / config.rows
    let cellWidth = (config.field_width - config.field_padding * 2) / config.cols
    this.originalX = arrow.x
    this.originalY = arrow.y
    this.x = arrow.x / config.cell_width * cellWidth
    this.y = arrow.y / config.cell_width * cellHeight
    this.sprite = null
    this.update(arrow.player, arrow.direction)
  }

  update(player, direction) {
    if (this.player != player || player == null) {
      this.player = player
      let arrowSprite = 'arrow'
      if (this.player == this.config.player1) {
        arrowSprite += '_p1'
      } else if (this.player == this.config.player2) {
        arrowSprite += '_p2'
      }
      if (this.sprite != null) {
        this.sprite.destroy()
      }
      this.sprite = this.scene.add.sprite(this.config.field_padding + this.x, this.config.field_padding + this.y, arrowSprite).setOrigin(0.5, 0.5);
      this.sprite.setInteractive()
      this.sprite.on('pointerdown', () => this.onClick() );
      this.sprite.originalX = this.originalX
      this.sprite.originalY = this.originalY
    }
    if (this.direction != direction) {
      this.direction = direction
      this.sprite.angle = direction * 90
    }
  }

  onClick() {
    channel.push("change_arrow", {x: this.originalX, y: this.originalY})
  }
}


export default Arrow;