defmodule TodolistWeb.WorkingTimeController do
    use TodolistWeb, :controller

    import Ecto.Query
    alias Todolist.Repo
    alias Todolist.TimeTracking.WorkingTime


    def show(conn, %{"userID" => userid, "id" => id}) do
        case Repo.get_by(WorkingTime, id: id, userID: userid) do
            nil ->
                conn |> put_status(:not_found) |> json(%{error: "Working time not found for this user!"})
            working_time ->
                render(conn, :show, working_time: working_time)
        end
    end

    def index(conn, %{"userID" => userid} = params) do
        user_id = if is_binary(userid), do: String.to_integer(userid), else: userid

        query =
          from w in WorkingTime,
            where: w.user_id == ^user_id,
            order_by: [asc: w.start]
        
        query =
          case Map.get(params, "start") do
            nil -> query
            "" -> query
            start_time -> from w in query, where: w.start >= ^start_time
          end

          query =
            case Map.get(params, "end") do
              nil -> query
              "" -> query
            end_time -> from w in query, where: w.end <= ^end_time
            end

          workingtimes = Repo.all(query)
          render(conn, :index, workingtimes: workingtimes)
    end

  def create(conn, %{"userID" => user_id, "working_time" => working_time_params}) do
    params_with_user = Map.put(working_time_params, "user_id", user_id)
    changeset = WorkingTime.changeset(%WorkingTime{}, params_with_user)

    case Repo.insert(changeset) do
      {:ok, working_time} ->
        conn |> put_status(:created) |> render(:show, working_time: working_time)

      {:error, changeset} ->
        conn |> put_status(:bad_request) |> json(%{errors: format_errors(changeset)})
    end
  end

  def update(conn, %{"id" => id, "working_time" => working_time_params}) do
    case Repo.get(WorkingTime, id) do
      nil ->
        conn |> put_status(:not_found) |> json(%{error: "Working time not found"})

      working_time ->
        changeset = WorkingTime.changeset(working_time, working_time_params)

        case Repo.update(changeset) do
          {:ok, updated_working_time} ->
            render(conn, :show, working_time: updated_working_time)

          {:error, changeset} ->
            conn |> put_status(:bad_request) |> json(%{errors: format_errors(changeset)})
        end
    end
  end

  def delete(conn, %{"id" => id}) do
    case Repo.get(WorkingTime, id) do
      nil ->
        conn |> put_status(:not_found) |> json(%{error: "Working time not found"})

      working_time ->
        {:ok, _working_time} = Repo.delete(working_time)
        send_resp(conn, :no_content, "")
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
