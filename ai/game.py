import requests

GAME_INIT_BOARD_URL = "http://web:4000/api/ai_game/init"
GAME_MOVE_URL = "http://web:4000/api/ai_game/move"
ARROWS_COUNT = 9

class Game(object):

    def __init__(self):
      self.init_board = None
    
    def get_init_board(self):
      if self.init_board == None:
        resp = requests.get(url=GAME_INIT_BOARD_URL)
        self.init_board = resp.json()
      return self.init_board
    
    def make_move(self, board, move, player):
      x, y, direction, change_dir = self.format_move(board, move, player)

      if change_dir:
        board['arrows'][y][x]['direction'] = direction

      return self.send_move(board)
    
    def format_move(self, board, move, player):
      arrow_pos, direction = divmod(move, 2) # 2 possible arrow dirs
      y, x = divmod(arrow_pos, 9)
      arrow = board['arrows'][str(y * 10)][str(x * 10)]
      direction = int(direction)
      if player == board["player1"]: # 1 or 2 dir for top left player
        direction += 1 
      else: # 0 or 4 dir for bottom right player
        if direction == 1:
          direction = 3
      change_dir = True
      change_dir = False if arrow['player'] != player else change_dir
      change_dir = False if direction == 0 and y == 0 else change_dir
      change_dir = False if direction == 1 and x == 8 else change_dir
      change_dir = False if direction == 2 and y == 8 else change_dir
      change_dir = False if direction == 3 and x == 0 else change_dir

      return str(x * 10), str(y * 10), direction, change_dir

    def send_move(self, board):
      r = requests.post(GAME_MOVE_URL, json=board)
      return r.json()
    
    def balls_health(self, board, player):
      health = 0
      for key, ball in board['balls'].items():
        if ball['player'] == player:
          health += ball['health']
      return health
    
    def base_health(self, board, player):
      health = 0
      for key, base in board['bases'].items():
        if base['player'] == player:
          return base['health']
      return health

    def arrows_count(self, board, player):
      count = 0
      for x in range(ARROWS_COUNT):
        for y in range(ARROWS_COUNT):
          arrow = board['arrows'][str(x * 10)][str(y * 10)]
          if arrow['player'] == player:
            count += 1
      return count
    
    def cells_count(self, board, player):
      count = 0
      for x in range(ARROWS_COUNT - 1):
        for y in range(ARROWS_COUNT - 1):
          arrow1 = board['arrows'][str(x * 10)][str(y * 10)]
          arrow2 = board['arrows'][str((x + 1) * 10)][str(y * 10)]
          arrow3 = board['arrows'][str(x * 10)][str((y + 1) * 10)]
          arrow4 = board['arrows'][str((x + 1) * 10)][str((y + 1) * 10)]
          if arrow1['player'] == player and arrow2['player'] == player and arrow3['player'] == player and arrow4['player'] == player:
            count += 1
      return count

    def is_finished(self, board):
      for key, base in board['bases'].items():
        if base['health'] <= 0:
          return True
      return False

      