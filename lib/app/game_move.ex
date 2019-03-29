defmodule App.GameMove do
  use Ecto.Schema
  import Ecto.Changeset

  schema "game_moves" do
    field :move, :map
    field :turn, :integer
    belongs_to :game, App.Game

    timestamps()
  end

  @doc false
  def changeset(game_move, attrs \\ %{}) do
    game_move
    |> cast(attrs, [:turn, :move, :game_id])
    |> validate_required([:turn, :move, :game_id])
  end
end