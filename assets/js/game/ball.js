class Ball {
  constructor(scene, config, ball) {
    this.config = config
    this.scene = scene
    this.player = ball.player
    this.health = ball.health
    this.direction = ball.direction
    this.originalX = null
    this.originalY = null
    this.x = null
    this.y = null
    this.graphics = null
    this.text = null
    this.maxBallHealthRadius = 6
    this.update(ball.x, ball.y, ball.health, ball.direction)
  }

  update(x, y, health, direction) {
    let cellHeight = (this.config.field_height - this.config.field_padding * 2) / this.config.rows
    let cellWidth = (this.config.field_width - this.config.field_padding * 2) / this.config.cols
    this.originalX = x
    this.originalY = y
    this.x = this.config.field_padding + x / this.config.cell_width * cellWidth
    this.y = this.config.field_padding + y / this.config.cell_width * cellHeight
    this.direction = direction
    this.health = health
    if (this.graphics === null) {
      this.graphics = this.scene.add.graphics({ fillStyle: { color: (this.config.player1 == this.player) ? this.config.player1_color : this.config.player2_color } })
      this.graphics.setDepth(3)
    }
    this.graphics.clear()
    let radius = 2.5 * (this.health + 1)
    if (this.health > this.maxBallHelathRadius) {
      radius = 2.5 * (this.maxBallHelathRadius + 1)
    }
    let circle = new Phaser.Geom.Circle(this.x, this.y, radius);
    this.graphics.fillCircleShape(circle);
    if (this.health > this.maxBallHelathRadius) {
      if (this.text === null) {
        this.text = this.scene.add.text(this.x, this.y, this.health, {
          fontFamily: 'Arial',
          color: '#ffffff',
          align: 'center',
        }).setFontSize(12).setOrigin(0.5, 0.5).setDepth(4)
      } else {
        this.text.setText(this.health)
      }
    } else if (this.text !== null) {
      this.text.destroy()
      this.text = null
    }
  }

  moveTo(fieldX, fieldY) {
    this.graphics.clear()
    let radius = 2.5 * (this.health + 1)
    if (this.health > this.maxBallHelathRadius) {
      radius = 2.5 * (this.maxBallHelathRadius + 1)
    }
    let circle = new Phaser.Geom.Circle(fieldX, fieldY, radius);
    this.graphics.fillCircleShape(circle);
    this.x = fieldX
    this.y = fieldY
    if (this.text !== null) {
      this.text.setX(this.x)
      this.text.setY(this.y)
    }
  }

  destroy() {
    this.graphics.clear()
    this.graphics = null
    if (this.text !== null) {
      this.text.destroy()
      this.text = null
    }
  }
}

export default Ball