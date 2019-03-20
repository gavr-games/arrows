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

def run():
  agent1 = DQNAgent()
  agent2 = DQNAgent()
  counter_games = 0
  game_engine = Game()

  while counter_games < GAMES_COUNT:
    board = game_engine.get_init_board()
    start = timer()
    #set player for agents
    agent1.player = randint(1,2)
    agent2.player = 1 if agent1.player == 2 else 2
    
    while not game_engine.is_finished(board):
      #agent.epsilon is set to give randomness to actions
      agent1.epsilon = EPSILON - counter_games
      agent2.epsilon = EPSILON - counter_games

      #get state
      state1 = agent1.get_state(board)
      state2 = agent2.get_state(board)

      #perform random actions based on agent.epsilon, or choose the action
      if randint(0, EPSILON * RANDOM_MOVES_PROPORTION) < agent1.epsilon:
        final_move1 = random.choice(agent1.possible_moves(state1))
      else:
        # predict action based on the state
        prediction = agent1.model.predict(state1)
        final_move1 = np.argmax(prediction[0])
      
      if randint(0, EPSILON * RANDOM_MOVES_PROPORTION) < agent2.epsilon:
        final_move2 = random.choice(agent2.possible_moves(state2))
      else:
        # predict action based on the state
        prediction = agent2.model.predict(state2)
        final_move2 = np.argmax(prediction[0])
      
      #perform new move and get new state
      board_new, changed_dir1 = game_engine.make_move(board, final_move1, agent1.player)
      board_new, changed_dir2 = game_engine.make_move(board_new, final_move2, agent2.player)
      board_new = game_engine.send_move(board_new)
      state_new1 = agent1.get_state(board_new)
      state_new2 = agent2.get_state(board_new)

      #set reward for the new state
      reward1 = agent1.get_reward(game_engine, board, board_new, changed_dir1)
      reward2 = agent2.get_reward(game_engine, board, board_new, changed_dir2)

      #train short memory base on the new action and state
      game_is_finished = game_engine.is_finished(board_new)
      agent1.train_short_memory(state1, final_move1, reward1, state_new1, game_is_finished)
      agent2.train_short_memory(state2, final_move2, reward2, state_new2, game_is_finished)

      # store the new data into a long term memory
      agent1.remember(state1, final_move1, reward1, state_new1, game_is_finished)
      agent2.remember(state2, final_move2, reward2, state_new2, game_is_finished)
      board = board_new

      if game_is_finished:
        if game_engine.is_win(board, agent1.player):
          agent1.wins_count += 1
        if game_engine.is_win(board, agent2.player):
          agent2.wins_count += 1
      print('.', end='', flush=True)

    agent1.replay_new()
    agent2.replay_new()
    counter_games += 1
    print('Finished')
    print('Game', counter_games)
    print('Time', timer() - start)
    print('Turns', board["turn"])
    print('Agent 1 wins', agent1.wins_count)
    print('Agent 2 wins', agent2.wins_count)
    
  
  # save trained model
  if agent1.wins_count > agent2.wins_count:
    agent1.model.save_weights('weights.hdf5')
  else:
    agent2.model.save_weights('weights.hdf5')
run()