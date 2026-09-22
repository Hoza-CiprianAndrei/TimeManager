defmodule Todolist.TimeTrackingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Todolist.TimeTracking` context.
  """

  @doc """
  Generate a clock.
  """
  def clock_fixture(attrs \\ %{}) do
    {:ok, clock} =
      attrs
      |> Enum.into(%{
        status: true,
        time: ~N[2026-09-21 08:46:00]
      })
      |> Todolist.TimeTracking.create_clock()

    clock
  end

  @doc """
  Generate a clock.
  """
  def clock_fixture(attrs \\ %{}) do
    {:ok, clock} =
      attrs
      |> Enum.into(%{
        status: true,
        time: ~N[2026-09-21 08:47:00]
      })
      |> Todolist.TimeTracking.create_clock()

    clock
  end

  @doc """
  Generate a working_time.
  """
  def working_time_fixture(attrs \\ %{}) do
    {:ok, working_time} =
      attrs
      |> Enum.into(%{
        end: ~N[2026-09-21 08:47:00],
        start: ~N[2026-09-21 08:47:00]
      })
      |> Todolist.TimeTracking.create_working_time()

    working_time
  end

  @doc """
  Generate a clock.
  """
  def clock_fixture(attrs \\ %{}) do
    {:ok, clock} =
      attrs
      |> Enum.into(%{
        status: true,
        time: ~N[2026-09-21 09:10:00]
      })
      |> Todolist.TimeTracking.create_clock()

    clock
  end

  @doc """
  Generate a working_time.
  """
  def working_time_fixture(attrs \\ %{}) do
    {:ok, working_time} =
      attrs
      |> Enum.into(%{
        end: ~N[2026-09-21 09:11:00],
        start: ~N[2026-09-21 09:11:00]
      })
      |> Todolist.TimeTracking.create_working_time()

    working_time
  end
end
