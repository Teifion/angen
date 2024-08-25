defmodule AngenWeb.Router do
  use AngenWeb, :router

  import AngenWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {AngenWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug(Angen.Account.DefaultsPlug)
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :secure_api do
    plug(:accepts, ["json"])
    plug(Angen.Account.SecureApiPlug)
  end

  scope "/", AngenWeb.General do
    pipe_through [:browser]

    live_session :general_index,
      on_mount: [
        {AngenWeb.UserAuth, :mount_current_user}
      ] do
      live "/", HomeLive
      live "/guest", GuestLive
    end
  end

  scope "/admin", AngenWeb.Admin do
    pipe_through [:browser]

    live_session :admin_index,
      on_mount: [
        {AngenWeb.UserAuth, :ensure_authenticated},
        {AngenWeb.UserAuth, {:authorise, ~w(admin)}}
      ] do
      live "/", HomeLive
    end
  end

  scope "/admin/accounts", AngenWeb.Admin.Account do
    pipe_through [:browser]

    live_session :admin_accounts,
      on_mount: [
        {AngenWeb.UserAuth, :ensure_authenticated},
        {AngenWeb.UserAuth, {:authorise, ~w(admin)}}
      ] do
      live "/", IndexLive
      live "/user/new", NewLive
      live "/user/edit/:user_id", ShowLive, :edit
      live "/user/:user_id", ShowLive
    end
  end

  scope "/admin/game", AngenWeb.Admin.Game do
    pipe_through [:browser]

    live_session :admin_game,
      on_mount: [
        {AngenWeb.UserAuth, :ensure_authenticated},
        {AngenWeb.UserAuth, {:authorise, ~w(admin)}}
      ] do
      live "/", IndexLive
      live "/match/:match_id", ShowLive
    end
  end

  scope "/admin/logging", AngenWeb.Admin.Logging do
    pipe_through [:browser]

    live_session :admin_logging,
      on_mount: [
        {AngenWeb.UserAuth, :ensure_authenticated},
        {AngenWeb.UserAuth, {:authorise, ~w(admin)}}
      ] do
      live "/", HomeLive

      # Special reports
      live "/server/now", Server.NowLive, :index
      live "/server/load", Server.LoadLive, :index

      # Generic log views
      live "/server", Server.IndexLive
      live "/server/:unit", Server.IndexLive
      live "/server/show/:unit/:date", Server.ShowLive, :index
      live "/server/show/:unit/:date/:mode", Server.ShowLive, :index

      # Generic log views
      live "/game", Game.IndexLive
      live "/game/:unit", Game.IndexLive
      live "/game/show/:unit/:date", Game.ShowLive, :index
      live "/game/show/:unit/:date/:mode", Game.ShowLive, :index

      # Audit
      live "/audit", AuditLogLive.Index, :index
      live "/audit/:id", AuditLogLive.Show, :show
    end
  end

  scope "/admin/settings", AngenWeb.Admin do
    pipe_through [:browser]

    live_session :admin_settings,
      on_mount: [
        {AngenWeb.UserAuth, :ensure_authenticated},
        {AngenWeb.UserAuth, {:authorise, ~w(admin)}}
      ] do
      live "/", SettingsLive.Index, :index
    end
  end

  scope "/admin/data", AngenWeb.Admin.Data do
    pipe_through [:browser]

    live_session :admin_data,
      on_mount: [
        {AngenWeb.UserAuth, :ensure_authenticated},
        {AngenWeb.UserAuth, {:authorise, ~w(admin)}}
      ] do
      live "/", IndexLive
      live "/match", MatchLive
      live "/event", EventLive
    end
  end

  # Auth'd events
  scope "/admin/data", AngenWeb.Admin.Data do
    pipe_through([:browser])

    get "/export/:id", ExportController, :download
    get "/export/:id/:type", ExportController, :download
  end

  scope "/", AngenWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{AngenWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/login", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    get "/login/:code", UserSessionController, :login_from_code
    post "/login", UserSessionController, :create
  end

  scope "/", AngenWeb do
    pipe_through [:browser]

    post "/logout", UserSessionController, :delete
    delete "/logout", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{AngenWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end

  # API
  scope "/api", AngenWeb.Api do
    pipe_through([:api])
    post "/request_token", TokenController, :request_token
  end

  # Anon events
  scope "/api", AngenWeb.Api do
    pipe_through([:api])
    post "/events/simple_anon", EventController, :simple_anon
    post "/events/complex_anon", EventController, :complex_anon
  end

  # Auth'd events
  scope "/api", AngenWeb.Api do
    pipe_through([:api, :secure_api])

    get "/ping", TokenController, :ping
    post "/renew_token", TokenController, :renew_token

    post "/account/create_user", AccountController, :create_user

    post "/game/create_match", GameController, :create_match
    post "/game/update_match", GameController, :update_match

    post "/events/simple_match", EventController, :simple_match
    post "/events/complex_match", EventController, :complex_match
    post "/events/simple_clientapp", EventController, :simple_clientapp
    post "/events/complex_clientapp", EventController, :complex_clientapp
  end

  # Enfys
  scope "/api/enfys", AngenWeb.Api do
    pipe_through([:api])
    post("/start", EnfysController, :start)
  end

  scope "/admin", AngenWeb.Admin do
    pipe_through [:browser]
    import Phoenix.LiveDashboard.Router

    live_dashboard("/live_dashboard",
      metrics: Angen.TelemetrySupervisor,
      ecto_repos: [Angen.Repo],
      on_mount: [
        {AngenWeb.UserAuth, :ensure_authenticated},
        {AngenWeb.UserAuth, {:authorise, "admin"}}
      ],
      additional_pages: [
        # live_dashboard_additional_pages
      ]
    )
  end
end
