defmodule App.Board.Operations.Update do
  alias App.Cell.Operations.CountPerPlayer
  alias App.Ball.Operations.{ Move, StartJump, StopJump, ChangeDirection }

  def call(board) do
    board
      |> inc_turn()
      |> move_balls()
      |> generate_balls()
      |> stop_jumps()
      |> detect_collisions()
      |> detect_base_collisions()
      |> capture_arrows()
      |> change_balls_directions()
      |> start_jumps()
      |> merge_balls()
  end

  defp inc_turn(board) do
    Map.put(board, :turn, board[:turn] + 1)
  end

  defp move_balls(board) do
    balls = for {k, v} <- board[:balls], into: %{}, do: {k, Move.call(v)}
    board
      |> Map.put(:balls, balls)
  end

  defp start_jumps(board) do
    balls = for {k, v} <- board[:balls], into: %{}, do: {k, StartJump.call(v)}
    board
      |> Map.put(:balls, balls)
  end

  defp stop_jumps(board) do
    balls = for {k, v} <- board[:balls], into: %{}, do: {k, StopJump.call(v)}
    board
      |> Map.put(:balls, balls)
  end

  defp detect_collisions(board) do
    balls = board[:balls]
    balls = Enum.reduce(balls, board[:balls], fn {k, ball}, resulting_balls ->
      case Map.has_key?(resulting_balls, k) do
        true  ->
          case Enum.find(resulting_balls, fn {k2, ball2} -> k != k2 && ball[:x] == ball2[:x] && ball[:y] == ball2[:y] && ball2[:player] != ball[:player] && ball[:jump] != true && ball2[:jump] != true end) do
            {collision_key, collision_ball} ->
              resulting_balls = case ball[:health] - collision_ball[:health] <= 0 do
                true -> 
                  Map.drop(resulting_balls, [k])
                false -> put_in(resulting_balls[k][:health], ball[:health] - collision_ball[:health])
              end
              resulting_balls = case collision_ball[:health] - ball[:health] <= 0 do
                true -> 
                  Map.drop(resulting_balls, [collision_key])
                false -> put_in(resulting_balls[collision_key][:health], collision_ball[:health] - ball[:health])
              end
              resulting_balls
            nil -> resulting_balls
          end
        false -> resulting_balls
      end
    end)
    Map.put(board, :balls, balls)
  end

  defp capture_arrows(board) do
    balls = Enum.filter(board[:balls], fn {_, ball} -> 
      case get_in(board, [:arrows, ball[:y], ball[:x]]) do
        nil -> false
        _arrow -> true
      end
    end)
    arrows = balls
      |> Enum.map(fn {_, ball} -> capture_arrow(board, ball) end)
      |> Enum.reduce(board[:arrows], fn arrow, acc ->
          put_in(acc[arrow[:y]][arrow[:x]], arrow)
         end)
    board
      |> Map.put(:arrows, arrows)
  end

  defp capture_arrow(board, ball) do
    arrow = get_in(board, [:arrows, ball[:y], ball[:x]])
    case arrow[:player] == ball[:player] || ball[:jump] do
      true -> arrow
      false -> 
        arrow = arrow 
          |> Map.put(:player, ball[:player])
          |> Map.put(:direction, ball[:direction])
        config = board[:config]
        cond do
          arrow[:y] == 0 && arrow[:player] == board[:player1] && arrow[:direction] == 0 -> 
            Map.put(arrow, :direction, 1) # >
          arrow[:y] == 0 && arrow[:player] == board[:player2] && arrow[:direction] == 0 -> 
            Map.put(arrow, :direction, 3) # <
          arrow[:x] == 0 && arrow[:player] == board[:player1] && arrow[:direction] == 3 -> 
            Map.put(arrow, :direction, 2) # \/
          arrow[:x] == 0 && arrow[:player] == board[:player2] && arrow[:direction] == 3 -> 
            Map.put(arrow, :direction, 0) # ^
          arrow[:y] == config[:rows] * config[:cell_width] && arrow[:player] == board[:player1] && arrow[:direction] == 2 -> 
            Map.put(arrow, :direction, 1) # >
          arrow[:y] == config[:rows] * config[:cell_width] && arrow[:player] == board[:player2] && arrow[:direction] == 2 -> 
            Map.put(arrow, :direction, 3) # <
          arrow[:x] == config[:cols] * config[:cell_width] && arrow[:player] == board[:player1] && arrow[:direction] == 1 -> 
            Map.put(arrow, :direction, 2) # \/
          arrow[:x] == config[:cols] * config[:cell_width] && arrow[:player] == board[:player2] && arrow[:direction] == 1 -> 
            Map.put(arrow, :direction, 0) # ^
          true -> arrow
        end
    end
  end

  defp generate_balls(board) do
    case rem(board[:turn], board[:config][:new_ball_period]) == 0 do
      false -> board
      true  ->
        ball = %{
          x: 0,
          y: 0,
          health: CountPerPlayer.call(board[:player1], board) + 1,
          player: board[:player1],
          direction: board[:arrows][0][0][:direction],
          speed: board[:config][:ball_speed],
          jump: false,
          want_jump: false,
          jump_cooldown: 0
        }
        ball2 = %{
          x: board[:config][:cols] * board[:config][:cell_width],
          y: board[:config][:rows] * board[:config][:cell_width],
          health: CountPerPlayer.call(board[:player2], board) + 1,
          player: board[:player2],
          direction: board[:arrows][board[:config][:rows] * board[:config][:cell_width]][board[:config][:cols] * board[:config][:cell_width]][:direction],
          speed: board[:config][:ball_speed],
          jump: false,
          want_jump: false,
          jump_cooldown: 0
        }
        board = put_in board[:balls]["#{board[:turn]}_p1"], ball
        board = put_in board[:balls]["#{board[:turn]}_p2"], ball2
        board
    end
  end

  defp detect_base_collisions(board) do
    board = Enum.reduce(board[:balls], board, fn {k, ball}, resulting_board ->
      cond do
        ball[:x] == 0 && ball[:y] == 0 && ball[:player] != board[:player1] ->
          resulting_board = put_in resulting_board[:bases][0][:health], resulting_board[:bases][0][:health] - ball[:health]
          balls = Map.drop(resulting_board[:balls], [k])
          Map.put(resulting_board, :balls, balls)
        ball[:x] == board[:config][:cols] * board[:config][:cell_width] && ball[:y] == board[:config][:rows] * board[:config][:cell_width] && ball[:player] != board[:player2] ->
          resulting_board = put_in resulting_board[:bases][1][:health], resulting_board[:bases][1][:health] - ball[:health]
          balls = Map.drop(resulting_board[:balls], [k])
          Map.put(resulting_board, :balls, balls)
        true -> resulting_board
      end
    end)
    board
  end

  defp change_balls_directions(board) do
    balls = for {k, v} <- board[:balls], into: %{}, do: {k, ChangeDirection.call(board, v)}
    board
      |> Map.put(:balls, balls)
  end

  defp merge_balls(board) do
    balls = board[:balls]
    balls = Enum.reduce(balls, board[:balls], fn {k, ball}, resulting_balls ->
      case Map.has_key?(resulting_balls, k) do
        true  ->
          case Enum.find(resulting_balls, fn {k2, ball2} -> k != k2 && ball[:x] == ball2[:x] && ball[:y] == ball2[:y] && ball2[:player] == ball[:player] && ball[:jump] != true && ball2[:jump] != true && ball[:direction] == ball2[:direction] end) do
            {collision_key, collision_ball} ->
              resulting_balls = put_in(resulting_balls[k][:health], ball[:health] + collision_ball[:health])
              Map.drop(resulting_balls, [collision_key])
            nil -> resulting_balls
          end
        false -> resulting_balls
      end
    end)
    Map.put(board, :balls, balls)
  end
end