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
    pipe_through :browser

    live_session :general_index,
      on_mount: [
        # {AngenWeb.UserAuth, :ensure_authenticated}
        {AngenWeb.UserAuth, :mount_current_user}
      ] do
      live "/", HomeLive.Index, :index

      # These will be replaced later, for now we
      # live "/login", HomeLive.Index, :index
      # live "/profile", HomeLive.Index, :index
      # live "/logout", HomeLive.Index, :index
    end
  end

  scope "/admin", AngenWeb.Admin do
    pipe_through :browser

    live_session :admin_index,
      on_mount: [
        {AngenWeb.UserAuth, :ensure_authenticated}
      ] do
      live "/", HomeLive.Index, :index

      # These will be replaced later, for now we
      # live "/login", HomeLive.Index, :index
      # live "/profile", HomeLive.Index, :index
      # live "/logout", HomeLive.Index, :index
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

  # Other scopes may use custom stacks.
  # scope "/api", AngenWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:angen, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: AngenWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
