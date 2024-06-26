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
    # plug(Angen.Plugs.CachePlug)
  end

  pipeline :api do
    plug :accepts, ["json"]
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

  scope "/admin/logging", AngenWeb.Admin.Logging do
    pipe_through [:browser]

    live_session :logging_index,
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

      # Audit
      live "/audit", AuditLogLive.Index, :index
      live "/audit/:id", AuditLogLive.Show, :show
    end
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

    delete "/logout", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{AngenWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end

  scope "/api/enfys", AngenWeb.Api, as: :ts do
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
