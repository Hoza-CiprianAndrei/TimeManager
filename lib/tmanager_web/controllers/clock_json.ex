defmodule TmanagerWeb.ClockJSON do
  alias Tmanager.TimeTracking.Clock

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
