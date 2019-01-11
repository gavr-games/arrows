defmodule App.Game do
  use Ecto.Schema
  import Ecto.Changeset

  schema "games" do
    field :state, :map
    field :status, :integer
    belongs_to :user1, App.User
    belongs_to :user2, App.User

    timestamps()
  end

  @doc false
  def changeset(game, attrs \\ %{}) do
    game
    |> cast(attrs, [:status, :state, :user1_id, :user2_id])
    |> validate_required([:status, :user1_id])
  end
end
