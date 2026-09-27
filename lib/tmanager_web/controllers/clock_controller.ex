defmodule TodolistWeb.ClockController do
  use TodolistWeb, :controller

  alias Todolist.TimeTracking
  alias Todolist.TimeTracking.{Clock, WorkingTime}
  alias Todolist.Repo

  def show(conn, %{"userID" => user_id}) do
    case TimeTracking.get_last_clock_by_user(user_id) do
      nil -> 
        conn |> put_status(:ok) |> json(%{data: nil})
      %Clock{} = clock ->
        render(conn, :show, clock: clock)
    end
  end

  def create(conn, %{"userID" => user_id} = params) do
    clock_params = Map.get(params,"clock", params)

    case TimeTracking.create_clock_for_user(user_id, clock_params) do
      {:ok, %Clock{} = clock} ->
        if clock.status == false do
          case TimeTracking.get_last_clock_in(user_id) do
            nil -> :ok
            last_clock_in ->
              working_time_params = %{
                "user_id" => user_id,
                "start" => last_clock_in.time,
                "end" => clock.time
              }

              %WorkingTime{}
              |> WorkingTime.changeset(working_time_params)
              |> Repo.insert()
          end
        end

        conn |> put_status(:created) |> render(:show, clock: clock)
      
      {:error, changeset} ->
        conn |> put_status(:bad_request) |> json(%{errors: format_errors(changeset)})
    end
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
