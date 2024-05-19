defmodule AngenWeb.UserRegistrationLive do
  use AngenWeb, :live_view

  alias Teiserver.Account
  alias Teiserver.Account.User

  def render(assigns) do
    ~H"""
    <div class="row" style="padding-top: 15vh;" id="registration-div">
      <div class="col-sm-12 col-md-10 offset-md-1 col-lg-8 offset-lg-2 col-xl-6 offset-xl-3 col-xxl-4 offset-xxl-4">
        <div class="card mb-3">
          <div class="card-body">
            <.header class="text-center">
              <img
                src={~p"/images/favicon.png"}
                height="42"
                style="margin-right: 5px;"
                class="d-inline align-top"
              />
              Register for an account
              <:subtitle>
                Already registered?
                <.link navigate={~p"/login"} class="font-semibold text-brand hover:underline">
                  Sign in
                </.link>
                to your account now.
              </:subtitle>
            </.header>

            <.simple_form
              for={@form}
              id="registration_form"
              phx-submit="save"
              phx-change="validate"
              phx-trigger-action={@trigger_submit}
              action={~p"/login?_action=registered"}
              method="post"
            >
              <.error :if={@check_errors}>
                Oops, something went wrong! Please check the errors below.
              </.error>

              <.input field={@form[:email]} type="email" label="Email" class={"mt-2"} required autofocus />
              <br />

              <.input field={@form[:name]} type="text" label="Display name" class={"mt-2"} required />
              <br />

              <.input field={@form[:password]} type="password" label="Password" class={"mt-2"} required />
              <br />

              <:actions>
                <.link class="btn btn-secondary float-start w-40" href="/">Cancel</.link>
              </:actions>

              <:actions>
                <.button phx-disable-with="Creating account..." class="btn-primary float-end w-40">
                  Create an account
                  <span aria-hidden="true">→</span>
                </.button>
              </:actions>
            </.simple_form>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    if Application.get_env(:angen, :allow_web_register) do
      changeset = Account.change_user(%User{})

      socket =
        socket
        |> assign(trigger_submit: false, check_errors: false)
        |> assign_form(changeset)

      {:ok, socket, temporary_assigns: [form: nil], layout: {AngenWeb.Layouts, :blank}}
    else
      {:ok, redirect(socket, to: ~p"/")}
    end
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Account.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Angen.Account.deliver_user_confirmation_instructions(
            user,
            &url(~p"/users/confirm/#{&1}")
          )

        changeset = Account.change_user(user)
        {:noreply, socket |> assign(trigger_submit: true) |> assign_form(changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Account.change_user(%User{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
