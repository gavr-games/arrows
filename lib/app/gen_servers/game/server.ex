defmodule App.Game.Server do
  use GenServer
  require Logger
  import App.Game.Helper
  alias App.Board.Operations.{Init, Update}
  alias App.Game.Operations.Exit
  alias App.Arrow.Operations.ChangeDirection

  def create(game) do
    case GenServer.whereis(ref(game.id)) do
      nil ->
        Supervisor.start_child(App.Game.Supervisor, [%{game: game, board: %{}}])
      _game ->
        {:error, :game_server_already_exists}
    end
  end

  def start_link(state) do
    GenServer.start_link __MODULE__, state, name: ref(state[:game].id)
  end

  defp ref(game_id) do
    {:global, {:game_server, game_id}}
  end

  def init(state) do
    game_id = state[:game].id
    Logger.info "Init GenServer for game with id=#{game_id}"
    AppWeb.Endpoint.subscribe "game:#{game_id}", []
    Process.send_after self(), :init_game, 0
    {:ok, state}
  end

  def handle_info(:init_game, state) do
    game_id = state[:game].id
    Logger.info "Init game with id #{game_id}"
    case state[:game].status do
      1 -> #running
        schedule_timer()
        {:noreply, Map.put(state, :board, Init.call(state[:game]))}
      0 -> #new
        {:noreply, state}
      _ ->
        {:stop, :normal, state}
    end
  end

  def handle_info(:update, state) do
    game_id = state[:game].id
    Logger.info "Update game with id #{game_id}"
    case state[:game].status do
      1 -> #running
        board = Update.call(state[:board])
        AppWeb.Endpoint.broadcast "game:#{state[:game].id}", "update", board
        if board[:bases][0][:health] <= 0 || board[:bases][1][:health] <= 0 do
          Exit.call(state[:game].id)
        else
          schedule_timer()
        end
        {:noreply, Map.put(state, :board, board)}
      0 -> #new
        {:noreply, state}
      _ ->
        {:stop, :normal, state}
    end
  end

  def handle_info(%{event: "start"}, state) do
    game_id = state[:game].id
    Logger.info "Start game with id #{game_id}"
    schedule_timer()
    {:noreply, %{game: Map.put(state[:game], :status, game_status_code("running")), board: Init.call(state[:game])}}
  end

  def handle_info(%{event: "finish"}, state) do
    game_id = state[:game].id
    Logger.info "Finish game with id #{game_id}"
    {:stop, :normal, state}
  end

  def handle_info(%{event: "player2_joined", payload: payload}, state) do
    game_id = state[:game].id
    Logger.info "Player 2 joined game with id #{game_id}"
    {:noreply, %{game: Map.put(state[:game], :user2_id, payload.id), board: state[:board]}}
  end

  # Do nothing for commands sent by this genserver itself
  def handle_info(%{event: "update"}, state) do
    {:noreply, state}
  end
  def handle_info(%{event: "update_arrow"}, state) do
    {:noreply, state}
  end

  defp schedule_timer() do
    Process.send_after self(), :update, game_tick()
  end

  def handle_cast({:change_arrow, x, y, player}, state) do
    game_id = state[:game].id
    Logger.info "Change arrow for game with id #{game_id}"
    board = ChangeDirection.call(x, y, player, state[:board])
    AppWeb.Endpoint.broadcast "game:#{state[:game].id}", "update_arrow", %{arrow: board[:arrows][y][x]}
    {:noreply, Map.put(state, :board, board)}
  end

  def handle_cast({:jump_ball, ball_id, player}, state) do
    game_id = state[:game].id
    Logger.info "Jump ball for game with id #{game_id}"
    board = Jump.call(state[:board], ball_id, player)
    {:noreply, Map.put(state, :board, board)}
  end
end