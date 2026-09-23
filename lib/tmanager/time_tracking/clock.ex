defmodule Todolist.TimeTracking.Clock do
  use Ecto.Schema
  import Ecto.Changeset

  schema "clocks" do
    field :status, :boolean, default: false
    field :time, :naive_datetime
    
    belongs_to :user, Todolist.Accounts.User

    timestamps()
  end

  def changeset(clock, attrs) do
    clock
    |> cast(attrs, [:time, :status, :user_id])
    |> validate_required([:time, :status, :user_id])
  end
end
