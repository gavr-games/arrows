import {channel} from "./socket";

class Bot {
  static addNew(difficulty) {
    channel.push("add_bot", { difficulty: difficulty });
  }
}

export default Bot;