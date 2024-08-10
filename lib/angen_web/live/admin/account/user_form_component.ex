defmodule AngenWeb.Account.UserFormComponent do
  @moduledoc false
  use AngenWeb, :live_component
  # import Angen.Helper.ColourHelper, only: [rgba_css: 2]

  alias Teiserver.Account

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h3>
        <%= @title %>
      </h3>

      <.form for={@form} phx-target={@myself} phx-change="validate" phx-submit="save" id="user-form">
        <div class="row mb-4">
          <%!-- Core properties --%>
          <div class="col-md-12 col-lg-6">
            <label for="user_name" class="control-label">Name:</label>
            <.input field={@form[:name]} type="text" autofocus="autofocus" phx-debounce="100" />
            <br />

            <label for="user_email" class="control-label">Email:</label>
            <.input field={@form[:email]} type="text" phx-debounce="100" />
            <br />

            <div :if={@user.id == nil}>
              <label for="user_password" class="control-label">Password:</label>
              <.input field={@form[:password]} type="password" phx-debounce="100" autocomplete="off" />
              <br />
            </div>

            <label for="groups" class="control-label">Groups:</label>
            (separate with spaces) <.input field={@form[:groups]} type="text" phx-debounce="100" />
            <br />

            <label for="groups" class="control-label">Restrictions:</label>
            (separate with spaces)
            <.input field={@form[:restrictions]} type="text" phx-debounce="100" />
            <br />

            <label for="groups" class="control-label">Restricted until:</label>
            <.input field={@form[:restricted_until]} type="datetime-local" phx-debounce="100" />
            <br />
          </div>

          <%!-- Less important properties --%>
          <div class="col-md-12 col-lg-6">
            <label for="user_behaviour_score" class="control-label">Behaviour score:</label>
            <.input field={@form[:behaviour_score]} type="text" phx-debounce="100" />
            <br />

            <label for="user_trust_score" class="control-label">Trust score:</label>
            <.input field={@form[:trust_score]} type="text" phx-debounce="100" />
            <br />

            <label for="user_social_score" class="control-label">Social score:</label>
            <.input field={@form[:social_score]} type="text" phx-debounce="100" />
            <br />

            <label for="user_shadow_banned?" class="control-label">Shadow banned?:</label>
            <.input field={@form[:shadow_banned?]} type="checkbox" phx-debounce="100" />
            <br />

            <label for="user_smurf_of_id" class="control-label">Smurf of:</label>
            <.input field={@form[:smurf_of_id]} type="text" phx-debounce="100" />
            <br />
          </div>
        </div>

        <%= if @user.id do %>
          <div class="row">
            <div class="col">
              <a href={~p"/admin/accounts/user/#{@user.id}"} class="btn btn-secondary btn-block">
                Cancel
              </a>
            </div>
            <div class="col">
              <button class="btn btn-primary btn-block" type="submit">Update user</button>
            </div>
          </div>
        <% else %>
          <div class="row">
            <div class="col">
              <a href={~p"/admin/accounts"} class="btn btn-secondary btn-block">
                Cancel
              </a>
            </div>
            <div class="col">
              <button class="btn btn-primary btn-block" type="submit">Create user</button>
            </div>
          </div>
        <% end %>
      </.form>
    </div>
    """
  end

  @impl true
  def update(%{user: user} = assigns, socket) do
    changeset = Account.change_user(user)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    user_params = convert_params(user_params)

    changeset =
      socket.assigns.user
      |> Account.change_user(user_params)
      |> Map.put(:action, :validate)

    notify_parent({:updated_changeset, changeset})

    {:noreply,
     socket
     |> assign_form(changeset)}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    user_params = convert_params(user_params)

    save_user(socket, socket.assigns.action, user_params)
  end

  defp save_user(socket, :edit, user_params) do
    case Account.update_user(socket.assigns.user, user_params) do
      {:ok, user} ->
        notify_parent({:saved, user})

        {:noreply,
         socket
         |> put_flash(:info, "User updated successfully")
         |> redirect(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_user(socket, :new, user_params) do
    user_params =
      Map.merge(user_params, %{
        "userer_id" => socket.assigns.current_user.id
      })

    case Account.create_user(user_params) do
      {:ok, user} ->
        notify_parent({:saved, user})

        {:noreply,
         socket
         |> put_flash(:info, "User created successfully")
         |> redirect(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp convert_params(params) do
    params
    |> Map.merge(%{
      "groups" => String.split(params["groups"]),
      "restrictions" => String.split(params["restrictions"])
    })
  end
end
