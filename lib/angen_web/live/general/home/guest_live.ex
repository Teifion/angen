defmodule AngenWeb.General.HomeLive.Guest do
  use AngenWeb, :live_view

  alias Angen.Account

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:allow_guests, Application.get_env(:angen, :allow_guest_accounts))
      |> assign(:allow_registration, Application.get_env(:angen, :allow_web_register))
      |> assign(user_agent: get_connect_info(socket, :user_agent))
      |> assign(address: get_connect_info(socket, :peer_data) |> Map.get(:address))

    if socket.assigns.current_user do
      {:ok, redirect(socket, to: ~p"/")}
    else
      {:ok, socket}
    end
  end

  @impl true
  def handle_event("guest-account", _, socket) do
    if Application.get_env(:angen, :allow_guest_accounts) do
      name = Account.generate_guest_name()

      {:ok, user} = Angen.Account.create_user(%{
        "name" => name,
        "email" => "#{String.replace(name, " ", "")}@somedomain",
        "password" => Angen.Account.generate_password()
      })

      user_agent = socket.assigns.user_agent
      ip = socket.assigns.address |> Tuple.to_list() |> Enum.join(".")

      {:ok, token} = Account.create_user_token(user.id, "web", user_agent, ip)

      code = Ecto.UUID.generate()
      Cachex.put(:one_time_login_code, code, token.id)

      {:noreply, redirect(socket, to: ~p"/login/#{code}")}
    else
      {:noreply, socket}
    end
  end
end
