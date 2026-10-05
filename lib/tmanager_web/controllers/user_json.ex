defmodule TmanagerWeb.UserJSON do

    def index(%{users: users}) do
        %{data: for(user <- users, do: data(user))}
    end

    def show(%{user: user}) do
        %{data: data(user)}
    end

    defp data(user) do
        %{
            id: user.id,
            username: user.username,
            email: user.email,
            role_id: user.role_id,
            teams: Enum.map(user.teams || [], fn team -> %{id: team.id, name: team.name} end)
        }
    end
end
