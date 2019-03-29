defmodule App.GameState do
  use Ecto.Schema
  import Ecto.Changeset

  schema "game_states" do
    field :state, :map
    field :turn, :integer
    belongs_to :game, App.Game

    timestamps()
  end

  @doc false
  def changeset(game_state, attrs \\ %{}) do
    game_state
    |> cast(attrs, [:turn, :state, :game_id])
    |> validate_required([:turn, :state, :game_id])
  end
end