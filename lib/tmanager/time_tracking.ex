defmodule Todolist.TimeTracking do

  import Ecto.Query, warn: false
  alias Todolist.Repo

  alias Todolist.TimeTracking.Clock

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

  def create_clock_for_user(user_id, attrs \\ %{}) do
    attrs_with_user = Map.put(attrs, "user_id", user_id)

    %Clock{} |> Clock.changeset(attrs_with_user) |> Repo.insert()
  end
end
