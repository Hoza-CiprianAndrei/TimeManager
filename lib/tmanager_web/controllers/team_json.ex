defmodule TmanagerWeb.TeamJSON do
  def index(%{teams: teams}) do
    %{data: for(team <- teams, do: data(team))}
  end

  def show(%{team: team}) do
    %{data: data(team)}
  end

  defp data(team) do
    %{
      id: team.id,
      name: team.name
    }
  end
end
