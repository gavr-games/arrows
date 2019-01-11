defmodule App.Game.Helper do
  @new_game_status 0
  @running_game_status 1
  @finished_game_status 2
  @tick 1000
  @rows 8
  @cols 8
  @base_health 10
  @cell_width 10
  @ball_speed 5
  @new_ball_period 4

  def game_status_code(s) do
    case s do
      "running" -> @running_game_status
      "finished" -> @finished_game_status
      _ -> @new_game_status
    end
  end

  def game_tick() do
    @tick
  end

  def game_rows() do
    @rows
  end

  def game_cols() do
    @cols
  end

  def game_base_health() do
    @base_health
  end

  def game_cell_width() do
    @cell_width
  end

  def game_ball_speed() do
    @ball_speed
  end

  def game_new_ball_period() do
    @new_ball_period
  end
end