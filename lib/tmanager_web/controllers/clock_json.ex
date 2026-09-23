defmodule TodolistWeb.ClockJSON do
  alias Todolist.TimeTracking.Clock

  def show(%{clock: clock}) do
    %{data: data(clock)}
  end

  defp data(%Clock{} = clock) do
    %{
      id: clock.id,
      time: clock.time,
      status: clock.status,
      user: clock.user_id
    }
  end
end
