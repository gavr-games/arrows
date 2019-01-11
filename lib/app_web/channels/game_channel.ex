defmodule AppWeb.GameChannel do
  use Phoenix.Channel
  alias App.Repo
  alias App.Game
  require Logger

  def join("game:" <> game_id, _params, socket) do
    game = Repo.get!(Game, game_id)
    user_id = socket.assigns.user_id
    if game.user1_id == user_id || game.user2_id == user_id do
      {g_id, _} = Integer.parse(game_id)
      {:ok, assign(socket, :game_id, g_id)}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("change_arrow", %{"x" => x, "y" => y}, socket) do
    case GenServer.whereis(ref(socket.assigns.game_id)) do
      nil -> nil
      process -> 
        GenServer.cast(process, {:change_arrow, x, y, socket.assigns.user_id})
    end
    {:noreply, socket}
  end

  defp ref(game_id) do
    {:global, {:game_server, game_id}}
  end
end
