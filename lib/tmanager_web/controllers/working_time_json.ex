defmodule TodolistWeb.WorkingTimeJSON do
    def index(%{workingtimes: workingtimes}) do
        %{data: for(wt <- workingtimes, do: data(wt))}
    end

    def show(%{working_time: wt}) do
        %{data: data(wt)}
    end

    defp data(wt) do
        %{
            id: wt.id,
            start: wt.start,
            end: wt.end,
            user: wt.user_id
        }
    end
end