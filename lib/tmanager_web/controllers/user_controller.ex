defmodule TodolistWeb.UserController do
    use TodolistWeb, :controller

    alias Todolist.Accounts.User
    alias Todolist.Repo

    def index(conn, _param) do
        users = Repo.all(User)
        render(conn, :index, users: users)
    end

    def show(conn, %{"id" => id}) do
        case Repo.get(User, id) do
            nil ->
                conn |> put_status(:not_found) |> json(%{error: "User not found"})
            user ->
                render(conn, :show, user: user)
        end
    end

    def create(conn, %{"user" => user_params}) do
        changeset = User.changeset(%User{}, user_params)

        case Repo.insert(changeset) do
            {:ok, user} ->
                conn |> put_status(:created) |> render(:show, user: user)
            {:error, changeset} ->
                conn |> put_status(:bad_request) |> json(%{errors: format_errors(changeset)})                
        end
    end

    def update(conn, %{"id" => id, "user" => user_params}) do
        case Repo.get(User, id) do
            nil ->
                conn |> put_status(:not_found) |> json(%{error: "User not found"})
            user ->
                changeset = User.changeset(user, user_params)
                
            case Repo.update(changeset) do
                {:ok, updated_user} ->
                    render(conn, :show, user: updated_user)
                {:error, changeset} ->
                    conn |> put_status(:bad_request) |> json(%{errors: format_errors(changeset)})                    
            end
        end
    end

    def delete(conn, %{"id" => id}) do
        case Repo.get(User, id) do
            nil ->
                conn |> put_status(:not_found) |> json(%{error: "User not found"})
            user -> 
                {:ok, _user} = Repo.delete(user)
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