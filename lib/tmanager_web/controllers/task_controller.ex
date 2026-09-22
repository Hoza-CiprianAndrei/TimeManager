defmodule TodolistWeb.TaskController do
  use TodolistWeb, :controller

  import Ecto.Query, only: [from: 2]
  alias Todolist.Repo
  alias Todolist.Tasks.Task

  def index(conn, _params) do
    tasks = Repo.all(Task)
    json(conn, %{data: tasks})
  end

  def show(conn, %{"id" => id}) do
    case Repo.get(Task, id) do
      nil -> conn |> put_status(:not_found) |> json(%{error: "Task not found"})
      task -> json(conn, %{data: task})
    end
  end

  def create(conn, %{"task" => task_params}) do
    changeset = Task.changeset(%Task{}, task_params)

    case Repo.insert(changeset) do
      {:ok, task} -> conn |> put_status(:created) |> json(%{data: task})
      {:error, _changeset} -> conn |> put_status(:bad_request) |> json(%{error: "Invalid data"})
    end
  end

  def update(conn, %{"id" => id, "task" => task_params}) do
    case Repo.get(Task, id) do
      nil -> conn |> put_status(:not_found) |> json(%{error: "Task not found"})
      task ->
        case Repo.update(Task.changeset(task, task_params)) do
          {:ok, updated_task} -> json(conn, %{data: updated_task})
          {:error, _changeset} -> conn |> put_status(:bad_request) |> json(%{error: "Invalid data"})
        end
    end
  end

  def delete(conn, %{"id" => id}) do
    case Repo.get(Task, id) do
      nil -> conn |> put_status(:not_found) |> json(%{error: "Task not found"})
      task ->
        Repo.delete!(task)
        send_resp(conn, :no_content, "")
    end
  end

  def by_user(conn, %{"idUser" => user_id}) do
    query = from t in Task, where: t.user_id == ^user_id

    case Repo.all(query) do
      [] -> conn |> put_status(:not_found) |> json(%{error: "No tasks found"})
      tasks -> json(conn, %{data: tasks})
    end
  end

end
