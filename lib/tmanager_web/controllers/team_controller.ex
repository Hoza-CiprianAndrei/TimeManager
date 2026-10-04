defmodule TmanagerWeb.TeamController do
  use TmanagerWeb, :controller

  alias Tmanager.Repo
  alias Tmanager.Accounts.{Team, User}

  def index(conn, _params) do
    teams = Repo.all(Team)
    render(conn, :index, teams: teams)
  end

  def create(conn, %{"team" => team_params}) do
    changeset = Team.changeset(%Team{}, team_params)

    case Repo.insert(changeset) do
      {:ok, team} ->
        conn
        |> put_status(:created)
        |> render(:show, team: team)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(json: TmanagerWeb.ErrorJSON)
        |> render(:errors, changeset: changeset)
    end
  end

  def add_user(conn, %{"id" => team_id, "user_id" => user_id}) do
    team = Repo.get!(Team, team_id) |> Repo.preload(:users)
    user = Repo.get!(User, user_id)

    is_member = Enum.any?(team.users, fn u -> u.id == user.id end)

    if is_member do
      send_resp(conn, :bad_request, "User is already in this team")
    else
      changeset =
        team
        |> Ecto.Changeset.change()
        |> Ecto.Changeset.put_assoc(:users, [user | team.users])

      case Repo.update(changeset) do
        {:ok, _team} ->
          send_resp(conn, :ok, "User added to team")
        {:error, _changeset} ->
          send_resp(conn, :bad_request, "Failed to add user")
      end
    end
  end
end
