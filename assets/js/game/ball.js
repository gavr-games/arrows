import {channel} from "../socket"

class Ball {
  constructor(scene, config, id, ball) {
    this.config = config
    this.id = id
    this.scene = scene
    this.speed = ball.speed
    this.jump_cooldown = ball.jump_cooldown
    this.jump = ball.jump
    this.player = ball.player
    this.health = ball.health
    this.direction = ball.direction
    this.originalX = null
    this.originalY = null
    this.x = null
    this.y = null
    this.graphics = null
    this.rectangle = null
    this.text = null
    this.maxBallHealthRadius = 6
    this.update(ball)
  }

  update(ball) {
    let x = ball.x
    let y = ball.y
    let health = ball.health
    let direction = ball.direction
    this.speed = ball.speed
    this.jump_cooldown = ball.jump_cooldown
    this.jump = ball.jump
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
    if (this.health > this.maxBallHealthRadius) {
      radius = 2.5 * (this.maxBallHealthRadius + 1)
    }
    if (this.jump) {
      this.graphics.setAlpha(0.3)
    } else {
      this.graphics.setAlpha(1)
    }
    let circle = new Phaser.Geom.Circle(this.x, this.y, radius);
    this.graphics.fillCircleShape(circle);
    if (this.rectangle === null) {
      this.rectangle = this.scene.add.rectangle(this.x, this.y, radius * 2, radius *2)
      this.rectangle.setInteractive()
      this.rectangle.on('pointerdown', () => this.onClick() )
      this.rectangle.setAlpha(1)
      this.rectangle.setDepth(4)
    } else {
      this.rectangle.setX(this.x)
      this.rectangle.setY(this.y)
      this.rectangle.setSize(radius * 2, radius * 2)
    }
    if (this.health > this.maxBallHealthRadius) {
      if (this.text === null) {
        this.text = this.scene.add.text(this.x, this.y, this.health, {
          fontFamily: 'Arial',
          color: '#ffffff',
          align: 'center',
        }).setFontSize(12).setOrigin(0.5, 0.5).setDepth(5)
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
    if (this.health > this.maxBallHealthRadius) {
      radius = 2.5 * (this.maxBallHealthRadius + 1)
    }
    let circle = new Phaser.Geom.Circle(fieldX, fieldY, radius);
    if (this.jump_cooldown % 2 == 0 && !this.jump) {
      this.graphics.setAlpha(1)
    } else {
      this.graphics.setAlpha(0.3)
    }
    this.graphics.fillCircleShape(circle);
    this.x = fieldX
    this.y = fieldY
    this.rectangle.setX(this.x)
    this.rectangle.setY(this.y)
    if (this.text !== null) {
      this.text.setX(this.x)
      this.text.setY(this.y)
    }
  }

  destroy() {
    this.graphics.clear()
    this.graphics = null
    this.rectangle.destroy()
    this.rectangle = null
    if (this.text !== null) {
      this.text.destroy()
      this.text = null
    }
  }

  onClick() {
    channel.push("jump_ball", {ball_id: this.id})
  }
}

export default Ball