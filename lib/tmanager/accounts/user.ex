defmodule Todolist.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :username, :string
    field :email, :string

    has_many :clocks, Todolist.TimeTracking.Clock, on_delete: :delete_all
    has_many :workingtimes, Todolist.TimeTracking.WorkingTime, on_delete: :delete_all

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :email])
    |> validate_required([:username, :email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+\.[^\s]+$/, message: "must have format X@X.X")
  end
end
