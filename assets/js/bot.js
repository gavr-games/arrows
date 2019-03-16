import {channel} from "./socket"

class Bot {
  static addNew() {
    channel.push("add_bot", {})
  }
}

export default Bot;