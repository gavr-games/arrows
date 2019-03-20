import numpy as np
from DQN import DQNAgent
from game import Game
from http.server import HTTPServer, BaseHTTPRequestHandler
import json

agent = DQNAgent("weights.hdf5")
game_engine = Game()

class SimpleHTTPRequestHandler(BaseHTTPRequestHandler):
  def do_POST(self):
    print("[INFO] Received POST request", flush = True)
    content_length = int(self.headers['Content-Length'])
    body = self.rfile.read(content_length)
    self.send_response(200)
    self.end_headers()
    board = json.loads(body)
    player = board["player2"]
    agent.player = player
    state = agent.get_state(board)
    prediction = agent.model.predict(state)
    final_move = np.argmax(prediction[0])
    x, y, direction, change_dir = game_engine.format_move(board, final_move, player)
    print(x, y, direction, change_dir)
    if change_dir == True:
      answer = {'x': int(x), 'y': int(y), 'direction': int(direction)}
      self.wfile.write(json.dumps(answer).encode('utf-8'))
    else:
      self.wfile.write("{}".encode('utf-8'))

httpd = HTTPServer(('', 8000), SimpleHTTPRequestHandler)
print("[INFO] Started server at port 8000", flush = True)
httpd.serve_forever()