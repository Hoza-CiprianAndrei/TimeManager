defmodule Tmanager.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :username, :string
    field :email, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    belongs_to :role, Tmanager.Role

    has_many :clocks, Tmanager.TimeTracking.Clock, on_delete: :delete_all
    has_many :workingtimes, Tmanager.TimeTracking.WorkingTime, on_delete: :delete_all

    many_to_many :teams, Tmanager.Accounts.Team, join_through: "users_teams"

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :email, :password, :role_id])
    |> validate_required([:username, :email, :role_id])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+\.[^\s]+$/, message: "must have format X@X.X")
    |> default_role()
    |> validate_password_if_new()
    |> put_password_hash()
  end

  defp default_role(changeset) do
    if get_field(changeset, :role_id) == nil do
      put_change(changeset, :role_id, 2)
    else
      changeset
    end
  end

  defp validate_password_if_new(changeset) do
    if get_field(changeset, :password_hash) == nil do
      validate_required(changeset, [:password])
    else
      changeset
    end
  end

  def put_password_hash(changeset) do
    case get_change(changeset, :password) do
      nil -> changeset
      password -> put_change(changeset, :password_hash, Bcrypt.hash_pwd_salt(password))
    end
  end
end
