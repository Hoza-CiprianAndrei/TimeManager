defmodule Tmanager.TimeTracking do

  import Ecto.Query, warn: false
  alias Tmanager.Repo

  alias Tmanager.TimeTracking.Clock

  def get_last_clock_by_user(user_id) do
    parsed_user_id =
      case user_id do
        id when is_integer(id) -> id
        id when is_binary(id) -> String.to_integer(id)
        _ -> nil
      end

    if parsed_user_id do
      from(c in Clock,
        where: c.user_id == ^parsed_user_id,
        order_by: [desc: c.id],
        limit: 1) |> Repo.one()
    else
      nil
    end
  end

  def get_last_clock_in(user_id) do
    user_id = if is_binary(user_id), do: String.to_integer(user_id), else: user_id

    Clock
    |> where([c], c.user_id == ^user_id and c.status == true)
    |> order_by([c], desc: c.inserted_at)
    |> limit(1)
    |> Repo.one()
  end

  def create_clock_for_user(user_id, attrs \\ %{}) do
    attrs_with_user = Map.put(attrs, "user_id", user_id)

    %Clock{} |> Clock.changeset(attrs_with_user) |> Repo.insert()
  end
end
