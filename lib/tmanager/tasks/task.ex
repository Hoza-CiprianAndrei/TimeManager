defmodule Todolist.Tasks.Task do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :title, :description, :status, :user_id, :inserted_at, :updated_at]}
  schema "tasks" do
    field :status, :string
    field :description, :string
    field :title, :string
    belongs_to :user, Todolist.Accounts.User

    timestamps()
  end

  def changeset(task, attrs) do
    task
    |> cast(attrs, [:title, :description, :status, :user_id])
    |> validate_required([:title, :description, :status, :user_id])
  end
end
