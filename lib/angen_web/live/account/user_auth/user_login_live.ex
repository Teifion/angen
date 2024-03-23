defmodule AngenWeb.UserLoginLive do
  use AngenWeb, :live_view

  # use Phoenix.LiveView, layout: {AngenWeb.Layouts, :blank}

  def render(assigns) do
    ~H"""
    <div class="row" style="padding-top: 15vh;" id="login-div">
      <div class="col-sm-12 col-md-10 offset-md-1 col-lg-8 offset-lg-2 col-xl-6 offset-xl-3 col-xxl-4 offset-xxl-4">
        <div class="card mb-3">
          <div class="card-header">
            <h3>
              <img
                src={~p"/images/favicon.png"}
                height="42"
                style="margin-right: 5px;"
                class="d-inline align-top"
              /> Sign In
            </h3>
          </div>
          <div class="card-body">
            <.simple_form for={@form} id="login_form" action={~p"/login"} phx-update="ignore">
              <.input field={@form[:email]} type="email" label="Email" autofocus="autofocus" required />
              <.input field={@form[:password]} type="password" label="Password" required />

              <:actions>
                <.button phx-disable-with="Signing in..." class="btn btn-primary float-end">
                  Login <span aria-hidden="true">→</span>
                </.button>
              </:actions>
              <:actions>
                <.input field={@form[:remember_me]} type="checkbox" label="Keep me logged in" />

                <.link href={~p"/users/reset_password"} class="sm">
                  Forgot your password?
                </.link>
              </:actions>
            </.simple_form>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = live_flash(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")

    {:ok, assign(socket, form: form),
     temporary_assigns: [form: form], layout: {AngenWeb.Layouts, :blank}}
  end
end
