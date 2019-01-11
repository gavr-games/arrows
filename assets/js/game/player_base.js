import Phaser from "phaser"
import Utils from "./utils"

class PlayerBase {
  constructor(scene, config, base) {
    this.health = base.health
    this.width = 10
    this.height = 10
    let baseX = config.field_padding - this.width / 2
    let baseY = config.field_padding - this.height / 2
    let healthTextX = 0
    let healthTextY = 0
    if (base.x != 0 && base.y != 0) {
      baseX = config.field_width - config.field_padding - this.width / 2
      baseY = config.field_height - config.field_padding - this.width / 2
      healthTextX = config.field_width - config.field_padding + 2
      healthTextY = config.field_height - config.field_padding + 3
    }
    let graphics = scene.add.graphics({fillStyle: { color: config.color } });
    let square = new Phaser.Geom.Rectangle(baseX, baseY, this.width, this.height);
    graphics.fillRectShape(square);
    this.healthText = scene.add.text(healthTextX, healthTextY, this.health, {color: Utils.decimalColorToHTMLcolor(config.color)});
  }

  updateHealth(newHealth) {
    this.health = newHealth
    this.healthText.setText(newHealth)
  }
}

export default PlayerBase;