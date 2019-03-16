defmodule App.Ball.Operations.ChangeDirection do

  def call(board, ball) do
    Map.put(ball, :direction, get_new_ball_direction(board, ball))
  end

  defp get_new_ball_direction(board, ball) do
    case get_in(board, [:arrows, ball[:y], ball[:x]]) do
      nil -> ball[:direction]
      arrow -> case arrow[:direction] do
        nil -> ball[:direction]
        dir -> case arrow[:player] == ball[:player] && ! ball[:jump] do
          true -> dir
          false -> ball[:direction]
        end
      end
    end
  end
  
end