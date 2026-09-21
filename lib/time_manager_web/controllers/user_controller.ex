defmodule TodolistWeb.UserController do
  use TodolistWeb, :controller

  alias Todolist.Repo
  alias Todolist.User

  def index(conn, _params) do
    users = Repo.all(User)
    json(conn, %{data: users})
  end

  def show(conn, %{"id" => id}) do
    case Repo.get(User, id) do
      nil -> conn |> put_status(:not_found) |> json(%{error: "User not found"})
      user -> json(conn, %{data: user})
    end
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.changeset(%User{}, user_params)

    case Repo.insert(changeset) do
      {:ok, user} -> conn |> put_status(:created) |> json(%{data: user})
      {:error, _changeset} -> conn |> put_status(:bad_request) |> json(%{error: "Invalid data"})
    end
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Repo.get!(User, id)
    changeset = User.changeset(user, user_params)

    case Repo.update(changeset) do
      {:ok, updated_user} -> json(conn, %{data: updated_user})
      {:error, _changeset} -> conn |> put_status(:bad_request) |> json(%{error: "Invalid data"})
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    Repo.delete!(user)
    send_resp(conn, :no_content, "")
  end
end
