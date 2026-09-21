defmodule Todolist.Repo do
  use Ecto.Repo,
    otp_app: :tmanager,
    adapter: Ecto.Adapters.Postgres
end
