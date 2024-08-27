defmodule Angen.Account.AuthLib do
  @moduledoc false
  require Logger

  @roles %{
    # Server authority
    "admin" => ~w(moderator),
    "moderator" => ~w()
  }

  @spec get_roles() :: %{String.t() => [String.t()]}
  def get_roles(), do: @roles

  @doc """
  Tests if the user or user in the connection is allowed to access any the required permissions.
  """
  @spec allow_any?(Map.t() | Plug.Conn.t() | [String.t()], String.t() | [String.t()]) :: boolean
  def allow_any?(conn, perms) do
    Enum.any?(
      perms
      |> Enum.map(fn p -> allow?(conn, p) end)
    )
  end

  @doc """
  Overload of `allow?/2`
  """
  @spec allow_all?(Map.t() | Plug.Conn.t() | [String.t()], String.t() | [String.t()]) :: boolean
  def allow_all?(conn, perms) do
    allow?(conn, perms)
  end

  @doc """
  Tests if the user or user in the connection is allowed to access all the required permissions.
  """
  @spec allow?(Map.t() | Plug.Conn.t() | [String.t()], String.t() | [String.t()]) :: boolean
  # If you don't need permissions then lets not bother checking
  def allow?(nil, []), do: false
  def allow?(_, nil), do: true
  def allow?(_, ""), do: true
  def allow?(_, []), do: true

  # Handle conn
  def allow?(%Plug.Conn{} = conn, permission_required) do
    allow?(conn.assigns[:current_user], permission_required)
  end

  # Socket
  def allow?(%Phoenix.LiveView.Socket{} = socket, permission_required) do
    allow?(socket.assigns[:current_user], permission_required)
  end

  # This allows us to use something with permissions in it
  def allow?(%{permissions: permissions}, permission_required) do
    allow?(permissions, permission_required)
  end

  # Handle users
  def allow?(%{} = user, permission_required) do
    allow?(user.permissions, permission_required)
  end

  def allow?(permissions_held, permission_required) when is_list(permission_required) do
    Enum.all?(
      permission_required,
      fn p ->
        allow?(permissions_held, p)
      end
    )
  end

  def allow?(_, permission_required) when is_atom(permission_required) do
    raise "permission_required must be a string, it was given as an atom (#{inspect(permission_required)})"
  end

  def allow?(permissions_held, permission_required) do
    Logger.debug(
      "Permission test, has: #{Kernel.inspect(permissions_held)}, needs: #{Kernel.inspect(permission_required)}"
    )

    cond do
      permissions_held == nil ->
        Logger.debug("AuthLib.allow?() -> No permissions held")
        false

      # Developers always have permission
      Enum.member?(permissions_held, "admin.dev.developer") && permission_required != "debug" ->
        true

      Enum.member?(permissions_held, "Server") && permission_required != "debug" ->
        true

      # Standard "do you have permission" response
      Enum.member?(permissions_held, permission_required) ->
        true

      # Default to not having permission
      true ->
        Logger.debug(
          "AuthLib.allow?() -> Permission not found: #{permission_required}, looked in #{inspect(permissions_held)}"
        )

        false
    end
  end

  @doc """
  Allows us to perform an auth check and force a redirect
  """
  @spec mount_require_all(Plug.Conn.t() | Phoenix.LiveView.Socket.t(), String.t() | [String.t()]) ::
          Phoenix.LiveView.Socket
  def mount_require_all(obj, requirements) do
    if do_require(obj, List.flatten([requirements]), :all) do
      obj
    else
      obj
      |> Phoenix.LiveView.put_flash(:warning, "You do not have permission to view this page.")
      |> Phoenix.LiveView.redirect(to: "/")
    end
  end

  @spec mount_require_any(
          Map.t() | Plug.Conn.t() | Phoenix.LiveView.Socket.t(),
          String.t() | [String.t()]
        ) :: Phoenix.LiveView.Socket
  def mount_require_any(obj, requirements) do
    if do_require(obj, List.flatten([requirements]), :any) do
      obj
    else
      obj
      |> Phoenix.LiveView.put_flash(:warning, "You do not have permission to view this page.")
      |> Phoenix.LiveView.redirect(to: "/")
    end
  end

  defp do_require(%Plug.Conn{} = conn, requirements, all_or_any) do
    do_require(conn.assigns[:current_user].permissions, requirements, all_or_any)
  end

  # Socket
  defp do_require(%Phoenix.LiveView.Socket{} = socket, requirements, all_or_any) do
    do_require(socket.assigns[:current_user].permissions, requirements, all_or_any)
  end

  defp do_require(permissions_held, requirements, :all) do
    Enum.all?(
      requirements,
      fn p ->
        allow?(permissions_held, p)
      end
    )
  end

  defp do_require(permissions_held, requirements, :any) do
    Enum.any?(
      requirements,
      fn p ->
        allow?(permissions_held, p)
      end
    )
  end

  # This is used as part of the permission system getting the current user
  # @spec current_user(Plug.Conn.t()) :: User.t() | nil
  # def current_user(conn) do
  #   conn.assigns[:current_user]
  # end
end
