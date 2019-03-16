defmodule AppWeb.AiGameController do
  use AppWeb, :controller
  alias App.Board.Operations.{Init, Update}
  require Logger

  plug AppWeb.Plugs.AiApiAllowed
  
  def init(conn, _params) do
      board = Init.call(%{user1_id: 1, user2_id: 2})
      json conn, board
  end

  def move(conn, params) do
    board = Update.call(snake_case_map(params))
    json conn, board
  end

  defp snake_case_map(map) when is_map(map) do
    Enum.reduce(map, %{}, fn {key, value}, result ->
      case Integer.parse(key) do
        {int_key, ""} -> Map.put(result, int_key, snake_case_map(value))
        _ -> Map.put(result, String.to_atom(key), snake_case_map(value))
      end
    end)
  end
  defp snake_case_map(list) when is_list(list), do: Enum.map(list, &snake_case_map/1)
  defp snake_case_map(value), do: value
end