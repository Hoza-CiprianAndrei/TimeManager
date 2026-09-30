defmodule TmanagerWeb.Plugs.AuthPlug do
  import Plug.Conn
  import Phoenix.Controller, only: [json: 2, put_status: 2]

  def init(default), do: default

  def call(conn, _default) do
    conn = fetch_cookies(conn)
    jwt = conn.cookies["jwt"]

    csrf_header = get_req_header(conn, "x-csrf-token") |> List.first()

    if is_nil(jwt) or is_nil(csrf_header) do
      unauthorized(conn, "Missing authentication tokens")
    else
      case Tmanager.Token.verify_and_validate(jwt) do
        {:ok, claims} ->
          if claims["csrf_token"] == csrf_header do

            conn
            |> assign(:current_user_id, claims["user_id"])
            |> assign(:current_user_role, claims["role"])
          else
            unauthorized(conn, "CSRF token mismatch")
          end

        {:error, _reason} ->
          unauthorized(conn, "Invalid or expired token")
      end
    end
  end

  defp unauthorized(conn, message) do
    conn
    |> put_status(:unauthorized)
    |> json(%{error: message})
    |> halt()
  end
end
