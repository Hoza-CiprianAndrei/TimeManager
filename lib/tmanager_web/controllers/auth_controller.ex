defmodule TmanagerWeb.AuthController do
  use TmanagerWeb, :controller
  alias Tmanager.Repo
  alias Tmanager.Accounts.User
  alias Tmanager.Token

  def login(conn, %{"email" => email, "password" => password}) do
    user = Repo.get_by(User, email: email) |> Repo.preload(:role)

    if user && Bcrypt.verify_pass(password, user.password_hash) do

      csrf_token = Plug.CSRFProtection.get_csrf_token()

      claims = %{
        "user_id" => user.id,
        "role" => user.role.name,
        "csrf_token" => csrf_token
      }

      {:ok, jwt, _claims} = Token.generate_and_sign(claims)

      conn
      |> put_resp_cookie("jwt", jwt, http_only: true, secure: false)
      |> json(%{
        message: "Login successful",
        csrf_token: csrf_token,
        user: %{
          id: user.id,
          email: user.email,
          username: user.username,
          role: user.role.name
        }
      })
    else
      conn
      |> put_status(:unauthorized)
      |> json(%{error: "Invalid email or password"})
    end
  end
end
