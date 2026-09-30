defmodule TmanagerWeb.Router do
  use TmanagerWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :authenticated do
    plug TmanagerWeb.Plugs.AuthPlug
  end

  scope "/api", TmanagerWeb do
    pipe_through :api

    post "/login", AuthController, :login
    post "/users", UserController, :create
  end

  scope "/api", TmanagerWeb do
    pipe_through [:api, :authenticated]

    scope "/users" do
      get "/", UserController, :index
      get "/:userID", UserController, :show
      put "/:userID", UserController, :update
      delete "/:userID", UserController, :delete
    end

    get "/workingtimes/:userID", WorkingTimeController, :index

    scope "/workingtime" do
      get "/:userID/:id", WorkingTimeController, :show
      post "/:userID", WorkingTimeController, :create
      put "/:id", WorkingTimeController, :update
      delete "/:id", WorkingTimeController, :delete
    end

    scope "/clocks" do
      get "/:userID", ClockController, :show
      post "/:userID", ClockController, :create
    end

    scope "/tasks" do
      get "/", TaskController, :index
      get "/:id", TaskController, :show
      post "/", TaskController, :create
      put "/:id", TaskController, :update
      delete "/:id", TaskController, :delete
      get "/users/:idUser", TaskController, :get_tasks_by_user
    end
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:tmanager, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: TmanagerWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
