defmodule AngenWeb.UserAuth do
  @moduledoc false
  use AngenWeb, :verified_routes

  import Plug.Conn
  import Phoenix.Controller

  alias Angen.Account

  @spec init(list()) :: list()
  def init(opts) do
    opts
  end

  @spec call(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def call(conn, :ensure_authenticated) do
    conn = fetch_current_user(conn, %{})

    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, "You must log in to access this page.")
      |> redirect(to: ~p"/login")
      |> halt
    end
  end

  def call(conn, {:authorise, permissions}) do
    if Account.AuthLib.allow?(conn.assigns.current_user, permissions) do
      conn
    else
      conn
      |> put_flash(:error, "You do not have permission to view that page.")
      |> redirect(to: ~p"/")
      |> halt
    end
  end

  # Make the remember me cookie valid for 60 days.
  # If you want bump or reduce this value, also change
  # the token expiry itself in UserToken.
  @max_age 60 * 60 * 24 * 60
  @remember_me_cookie "_Angen_user_remember_me"
  @remember_me_options [sign: true, max_age: @max_age, same_site: "Lax"]

  @doc """
  Logs the user in.

  It renews the session ID and clears the whole session
  to avoid fixation attacks. See the renew_session
  function to customize this behaviour.

  It also sets a `:live_socket_id` key in the session,
  so LiveView sessions are identified and automatically
  disconnected on log out. The line can be safely removed
  if you are not using LiveView.
  """
  def log_in_user(conn, user, params \\ %{}) do
    ip = get_ip_from_conn(conn) |> Tuple.to_list() |> Enum.join(".")

    user_agent =
      case List.keyfind(conn.req_headers, "user-agent", 0) do
        {_, agent} -> agent
        _ -> nil
      end

    {:ok, token} = Angen.Account.create_user_token(user.id, "web", user_agent, ip)
    Angen.Account.update_user_token(token, %{last_used_at: Timex.now()})

    user_return_to = get_session(conn, :user_return_to)

    conn
    |> renew_session()
    |> put_token_in_session(token)
    |> maybe_write_remember_me_cookie(token, params)
    |> redirect(to: user_return_to || signed_in_path(conn))
  end

  def log_in_with_token(conn, %Angen.Account.UserToken{} = token, params \\ %{}) do
    user_return_to = get_session(conn, :user_return_to)

    Angen.Account.update_user_token(token, %{last_used_at: Timex.now()})

    conn
    |> renew_session()
    |> put_token_in_session(token)
    |> maybe_write_remember_me_cookie(token, params)
    |> redirect(to: user_return_to || signed_in_path(conn))
  end

  defp maybe_write_remember_me_cookie(conn, token, %{"remember_me" => "true"}) do
    put_resp_cookie(conn, @remember_me_cookie, token, @remember_me_options)
  end

  defp maybe_write_remember_me_cookie(conn, _token, _params) do
    conn
  end

  # This function renews the session ID and erases the whole
  # session to avoid fixation attacks. If there is any data
  # in the session you may want to preserve after log in/log out,
  # you must explicitly fetch the session data before clearing
  # and then immediately set it after clearing, for example:
  #
  #     defp renew_session(conn) do
  #       preferred_locale = get_session(conn, :preferred_locale)
  #
  #       conn
  #       |> configure_session(renew: true)
  #       |> clear_session()
  #       |> put_session(:preferred_locale, preferred_locale)
  #     end
  #
  defp renew_session(conn) do
    delete_csrf_token()

    conn
    |> configure_session(renew: true)
    |> clear_session()
  end

  @doc """
  Logs the user out.

  It clears all session data for safety. See renew_session.
  """
  def log_out_user(conn) do
    user_token_identifier = get_session(conn, :user_token)
    cached_user_token = Account.get_user_token_by_identifier(user_token_identifier)
    user_token = cached_user_token && Account.get_user_token(cached_user_token.id)

    user_token && Account.delete_user_token(user_token)

    cached_user_token &&
      Angen.invalidate_cache(:user_token_identifier_cache, cached_user_token.identifier_code)

    if live_socket_id = get_session(conn, :live_socket_id) do
      AngenWeb.Endpoint.broadcast(live_socket_id, "disconnect", %{})
    end

    conn
    |> renew_session()
    |> delete_resp_cookie(@remember_me_cookie)
    |> redirect(to: ~p"/")
  end

  @doc """
  Authenticates the user by looking into the session
  and remember me token.
  """
  def fetch_current_user(conn, _opts) do
    {user_token_identifier, conn} = ensure_user_token(conn)
    token = user_token_identifier && Account.get_user_token_by_identifier(user_token_identifier)
    user = token && Account.get_user_by_id(token.user_id)
    assign(conn, :current_user, user)
  end

  defp ensure_user_token(conn) do
    if token = get_session(conn, :user_token) do
      {token, conn}
    else
      conn = fetch_cookies(conn, signed: [@remember_me_cookie])

      if token = conn.cookies[@remember_me_cookie] do
        {token, put_token_in_session(conn, token)}
      else
        {nil, conn}
      end
    end
  end

  @doc """
  Handles mounting and authenticating the current_user in LiveViews.

  ## `on_mount` arguments

    * `:mount_current_user` - Assigns current_user
      to socket assigns based on user_token, or nil if
      there's no user_token or no matching user.

    * `:ensure_authenticated` - Authenticates the user from the session,
      and assigns the current_user to socket assigns based
      on user_token.stop_execu
      defmodule AngenWeb.PageLive do
        use AngenWeb, :live_view

        on_mount {AngenWeb.UserAuth, :mount_current_user}
        ...
      end

  Or use the `live_session` of your router to invoke the on_mount callback:

      live_session :authenticated, on_mount: [{AngenWeb.UserAuth, :ensure_authenticated}] do
        live "/profile", ProfileLive, :index
      end
  """
  def on_mount(:mount_current_user, _params, session, socket) do
    {:cont, mount_current_user(socket, session)}
  end

  def on_mount(:ensure_authenticated, _params, session, socket) do
    socket = mount_current_user(socket, session)

    if socket.assigns.current_user do
      {:cont, socket}
    else
      socket =
        socket
        |> Phoenix.LiveView.put_flash(:error, "You must log in to access this page.")
        |> Phoenix.LiveView.redirect(to: ~p"/login")

      {:halt, socket}
    end
  end

  def on_mount(:redirect_if_user_is_authenticated, _params, session, socket) do
    socket = mount_current_user(socket, session)

    if socket.assigns.current_user do
      {:halt, Phoenix.LiveView.redirect(socket, to: signed_in_path(socket))}
    else
      {:cont, socket}
    end
  end

  def on_mount({:authorise, permissions}, _params, _session, socket) do
    if Account.AuthLib.allow?(socket.assigns.current_user, permissions) do
      {:cont, socket}
    else
      socket =
        socket
        |> Phoenix.LiveView.put_flash(:error, "You do not have permission to view that page.")
        |> Phoenix.LiveView.redirect(to: ~p"/")

      {:halt, socket}
    end
  end

  defp mount_current_user(socket, session) do
    Phoenix.Component.assign_new(socket, :current_user, fn ->
      case Account.get_user_from_token_identifier(session["user_token"]) do
        nil ->
          nil

        %Teiserver.Account.User{} = user ->
          user
      end
    end)
  end

  @doc """
  Used for routes that require the user to not be authenticated.
  """
  def redirect_if_user_is_authenticated(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
      |> redirect(to: signed_in_path(conn))
      |> halt()
    else
      conn
    end
  end

  @doc """
  Used for routes that require the user to be authenticated.

  If you want to enforce the user email is confirmed before
  they use the application at all, here would be a good place.
  """
  def require_authenticated_user(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_flash(:error, "You must log in to access this page.")
      |> maybe_store_return_to()
      |> redirect(to: ~p"/login")
      |> halt()
    end
  end

  defp put_token_in_session(conn, token) do
    conn
    |> put_session(:user_token, token.identifier_code)
    |> put_session(:live_socket_id, "users_sessions:#{Base.url_encode64(token.identifier_code)}")
  end

  defp maybe_store_return_to(%{method: "GET"} = conn) do
    put_session(conn, :user_return_to, current_path(conn))
  end

  defp maybe_store_return_to(conn), do: conn

  defp signed_in_path(_conn), do: ~p"/"

  @spec convert_from_x_real_ip(String.t()) :: Tuple.t()
  def convert_from_x_real_ip(ip) do
    if String.contains?(ip, ":") do
      ip
      |> String.split(":")
      |> List.to_tuple()
    else
      ip
      |> String.split(".")
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()
    end
  end

  @spec get_ip_from_conn(Conn.t()) :: tuple() | nil
  def get_ip_from_conn(conn) do
    case List.keyfind(conn.req_headers, "x-real-ip", 0) do
      {_, ip} -> convert_from_x_real_ip(ip)
      nil -> conn.remote_ip
      _ -> nil
    end
  end
end
