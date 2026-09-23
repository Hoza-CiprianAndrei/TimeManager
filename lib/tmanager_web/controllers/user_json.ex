defmodule TodolistWeb.UserJSON do

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
            email: user.email
        }
    end
end