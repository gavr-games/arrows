from random import randint
import random
import numpy as np
from keras.utils import to_categorical
from DQN import DQNAgent
from game import Game
from timeit import default_timer as timer
#from keras.backend.tensorflow_backend import set_session
#import tensorflow as tf

#config = tf.ConfigProto()
#config.intra_op_parallelism_threads = 1
#config.inter_op_parallelism_threads = 1

#set_session(tf.Session(config=config))

GAMES_COUNT = 100
EPSILON = 50
RANDOM_MOVES_PROPORTION = 2.5
PLAYER = 2

def run():
  agent = DQNAgent()
  counter_games = 0
  game_engine = Game()

  while counter_games < GAMES_COUNT:
    board = game_engine.get_init_board()
    start = timer()
    
    while not game_engine.is_finished(board):
      #agent.epsilon is set to give randomness to actions
      agent.epsilon = EPSILON - counter_games

      #get state
      state = agent.get_state(board, PLAYER)

      #perform random actions based on agent.epsilon, or choose the action
      if randint(0, EPSILON * RANDOM_MOVES_PROPORTION) < agent.epsilon:
        final_move = random.choice(agent.possible_moves(state))
        print("--- > random")
      else:
        # predict action based on the state
        prediction = agent.model.predict(state)
        final_move = np.argmax(prediction[0])
      
      #perform new move and get new state
      board_new, changed_dir = game_engine.make_move(board, final_move, PLAYER)
      state_new = agent.get_state(board_new, PLAYER)

      #set treward for the new state
      reward = agent.get_reward(game_engine, board, board_new, changed_dir, PLAYER)
      breakpoint()

      #train short memory base on the new action and state
      agent.train_short_memory(state, final_move, reward, state_new, game_engine.is_finished(board))

      # store the new data into a long term memory
      agent.remember(state, final_move, reward, state_new, game_engine.is_finished(board))
      board = board_new

    agent.replay_new()
    counter_games += 1
    print('Time', timer() - start)
    print('Turns', board["turn"])
    print('Game', counter_games)
  
  # save trained model
  agent.model.save_weights('weights.hdf5')
run()