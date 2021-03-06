from keras.optimizers import Adam
from keras.models import Sequential
from keras.layers.core import Dense, Dropout
import random
import numpy as np
from operator import add

LEARNING_RATE = 0.0001
GAMMA = 0.9
ARROWS_COUNT = 9
REWARD_BALL_HEALTH = 1
REWARD_PLAYER_BASE_HEALTH = 20
REWARD_OPONENT_BASE_HEALTH = 30
REWARD_ARROWS_COUNT = 2
REWARD_CELLS_COUNT = 2
REWARD_CHANGED_DIR = 1.0
REWARD_NOT_CHANGED_DIR = -1.0

np.set_printoptions(threshold=3000)

class DQNAgent(object):
    

    def __init__(self, weights = None):
      self.memory = []
      self.wins_count = 0
      self.player = 0
      if weights == None:
        self.model = self.network()
      else:
        self.model = self.network(weights)

    # Each state item has the following 10 values
    # 0 - has base or not
    # 1 - base belongs to player
    # 2 - base health
    # 3 - has arrow or not
    # 4 - arrow belongs to player
    # 5 - arrow direction
    # 6 - has ball or not
    # 7 - ball belongs to player
    # 8 - ball health
    # 9 - ball direction
    def get_state(self, board):
      state = np.zeros((17,17,10))
      player = self.player

      # Bases
      for key, base in board['bases'].items():
        x = self.coord_state(base['x'])
        y = self.coord_state(base['y'])
        state[y][x][0] = 1 # has base
        state[y][x][1] = 1 if base['player'] == player else 0
        state[y][x][2] = base['health']
      
      # Arrows
      for x in range(ARROWS_COUNT):
        for y in range(ARROWS_COUNT):
          state_y = y * 2
          state_x = x * 2
          arrow = board['arrows'][str(y * 10)][str(x * 10)]
          state[state_y][state_x][3] = 1 if arrow['player'] != None else 0 # has arrow
          state[state_y][state_x][4] = 1 if arrow['player'] == player else 0 
          state[state_y][state_x][5] = arrow['direction'] if arrow['direction'] != None else 0 
      
      # Balls
      for key, ball in board['balls'].items():
        x = self.coord_state(ball['x'])
        y = self.coord_state(ball['y'])
        if x == -18 or y == -18 or x ==17 or y == 17:
          breakpoint()
        state[y][x][6] = 1 # has ball
        state[y][x][7] = 1 if ball['player'] == player else 0
        state[y][x][8] = ball['health']
        state[y][x][9] = ball['direction']

      return state.flatten().reshape((1, 2890)) # 2890 - total number of elements in state matrix
    
    def coord_state(self, x):
      return (int) (x / 10 * 2)
    
    def get_reward(self, game_engine, board, board_new, changed_dir):
      reward = 0
      player = self.player
      opponent = 1 if player == 2 else 2
    
      # sum all healthes of my balls, difference with old state +-1
      my_balls = game_engine.balls_health(board, player)
      my_balls_new = game_engine.balls_health(board_new, player)
      reward += (my_balls_new - my_balls) * REWARD_BALL_HEALTH

      # sum all healthes of opponent balls, difference with old state +-1
      op_balls = game_engine.balls_health(board, opponent)
      op_balls_new = game_engine.balls_health(board_new, opponent)
      reward -= (op_balls_new - op_balls) * REWARD_BALL_HEALTH
      
      # difference my base health +-20
      my_base = game_engine.base_health(board, player)
      my_base_new = game_engine.base_health(board_new, player)
      reward += (my_base_new - my_base) * REWARD_PLAYER_BASE_HEALTH

      # difference opponent base health +-30
      op_base = game_engine.base_health(board, opponent)
      op_base_new = game_engine.base_health(board_new, opponent)
      reward += (op_base - op_base_new) * REWARD_OPONENT_BASE_HEALTH

      # difference arrows count +-2
      my_arrows = game_engine.arrows_count(board, player)
      my_arrows_new = game_engine.arrows_count(board_new, player)
      reward += (my_arrows_new - my_arrows) * REWARD_ARROWS_COUNT

      # difference opponent arrows count +-2
      op_arrows = game_engine.arrows_count(board, opponent)
      op_arrows_new = game_engine.arrows_count(board_new, opponent)
      reward += (op_arrows_new - op_arrows) * REWARD_ARROWS_COUNT

      # difference my cells +- 10
      my_cells = game_engine.cells_count(board, player)
      my_cells_new = game_engine.cells_count(board_new, player)
      reward += (my_cells_new - my_cells) * REWARD_CELLS_COUNT

      # difference opponents cells +- 10
      op_cells = game_engine.cells_count(board, opponent)
      op_cells_new = game_engine.cells_count(board_new, opponent)
      reward -= (op_cells_new - op_cells) * REWARD_CELLS_COUNT

      if changed_dir == True:
        reward += REWARD_CHANGED_DIR
      else:
        reward = REWARD_NOT_CHANGED_DIR # show ai it is wrong to try to move not his arrows

      return reward
    
    def network(self, weights=None):
      model = Sequential()
      model.add(Dense(units=4048, activation='relu', input_dim=2890)) # field has 17x17 points, each point can have state described by 10 values
      model.add(Dropout(0.25))
      model.add(Dense(units=2024, activation='relu'))
      model.add(Dropout(0.20))
      model.add(Dense(units=512, activation='relu'))
      model.add(Dropout(0.15))
      model.add(Dense(units=162, activation='softmax')) # output is 9x9 arrows and each has 2 possible directions
      opt = Adam(LEARNING_RATE)
      model.compile(loss='mse', optimizer=opt)

      if weights:
          model.load_weights(weights)
      return model

    def remember(self, state, final_move, reward, state_new, is_finished):
      self.memory.append((state, final_move, reward, state_new, is_finished))

    def train_short_memory(self, state, final_move, reward, state_new, is_finished):
      target = reward
      if not is_finished:
        target = reward + GAMMA * np.amax(self.model.predict(state_new)[0])
      target_f = self.model.predict(state)
      target_f[0][final_move] = target
      #target_f = self.set_arrow_rewards(state, target_f)
      self.model.fit(state, target_f, epochs=1, verbose=0)

    def replay_new(self):
      if len(self.memory) > 1000:
        minibatch = random.sample(self.memory, 1000)
      else:
        minibatch = self.memory
      for state, final_move, reward, state_new, is_finished in minibatch:
        target = reward
        if not is_finished:
          target = reward + GAMMA * np.amax(self.model.predict(state_new)[0])
        target_f = self.model.predict(state)
        target_f[0][final_move] = target
        #target_f = self.set_arrow_rewards(state, target_f)
        self.model.fit(state, target_f, epochs=1, verbose=0)
      self.memory = []
    
    def set_arrow_rewards(self, state, target_f):
      possible_moves = self.possible_moves(state)
      for i in possible_moves:
        if target_f[0][i] < REWARD_CHANGED_DIR:
          target_f[0][i] = REWARD_CHANGED_DIR
      return target_f
    
    def possible_moves(self, state):
      moves = []
      for x in range(ARROWS_COUNT):
        for y in range(ARROWS_COUNT):
          if state[0][(y * 17 + x) * 2 * 10 + 4] == 1.0: # my arrow
            move = (y * ARROWS_COUNT + x) * 2
            moves.append(move) # arrow dir 1
            moves.append(move + 1) # arrow dir 2
      return moves
