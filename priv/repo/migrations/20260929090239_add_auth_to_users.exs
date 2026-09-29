defmodule Todolist.Repo.Migrations.AddAuthToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
    add :password_hash, :string
    add :role_id, references(:roles, on_delete: :nothing)
  end

  create index(:users, [:role_id])
  end
end
