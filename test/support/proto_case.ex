defmodule Angen.ProtoCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a protocol connection.
  """

  use ExUnit.CaseTemplate

  # def _recv_until(socket, timeout \\ 500) do
  #   case :ssl.recv(socket, 0, timeout) do
  #     {:ok, reply} ->
  #       msg = reply |> to_string |> Jason.decode!
  #       [msg | _recv_until(socket, timeout)]
  #     {:error, :timeout} -> :timeout
  #     {:error, :closed} -> :closed
  #   end
  # end

  using do
    quote do
      # Import conveniences for testing with connections
      alias Teiserver.Api
      alias Angen.Helpers.JsonSchemaHelper
      alias Angen.TestSupport.TestConn
      import Angen.ProtoCase
    end
  end

  setup tags do
    Angen.DataCase.setup_sandbox(tags)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  @spec raw_connection() :: %{socket: any()}
  def raw_connection() do
    host = ~c"127.0.0.1"
    port = Application.get_env(:angen, :tls_port)

    {:ok, socket} =
      :ssl.connect(host, port,
        active: false,
        verify: :verify_none
      )

    %{socket: socket}
  end

  @spec auth_connection() :: %{socket: any(), user: Teiserver.Account.User.t()}
  def auth_connection() do
    id = Teiserver.uuid()

    {:ok, user} =
      Teiserver.Account.create_user(%{
        name: id,
        email: "#{id}@test",
        password: "password1"
      })

    auth_connection(user)
  end

  @spec auth_connection(Teiserver.Account.User.t()) :: %{
          socket: any(),
          user: Teiserver.Account.User.t()
        }
  def auth_connection(user) do
    host = ~c"127.0.0.1"
    port = Application.get_env(:angen, :tls_port)

    {:ok, socket} =
      :ssl.connect(host, port,
        active: false,
        verify: :verify_none
      )

    {:ok, token} = Angen.Account.create_user_token(user.id, "unit-test", "UnitTest", "127.0.0.1")

    speak(socket, %{
      name: "auth/login",
      command: %{
        token: token.identifier_code,
        user_agent: "UnitTest"
      }
    })

    response = listen(socket)

    assert response == %{
             "name" => "auth/logged_in",
             "message" => %{
               "user" => %{
                 "id" => user.id,
                 "name" => user.name
               }
             }
           }

    %{socket: socket, user: user, user_id: user.id}
  end

  @spec try_to_host_lobby(any(), Teiserver.Account.User.t(), String.t()) :: Teiserver.Game.Lobby.t()
  defp try_to_host_lobby(socket, user, lobby_name) do
    speak(socket, %{name: "lobby/open", command: %{name: "test-#{lobby_name}"}})

    msgs = listen_all(socket)

    try do
      Teiserver.Api.stream_lobby_summaries()
        |> Enum.filter(fn l -> l.host_id == user.id end)
        |> hd
    rescue
      e ->
        # Bug where we get a failure saying "Client is disconnected"
        # because there are no connections for the client (despite us sending stuff....)
        IO.puts "#{__MODULE__}:#{__ENV__.line}"
        IO.inspect Teiserver.Api.get_client(user.id)
        IO.inspect msgs
        IO.puts ""
        reraise e, __STACKTRACE__
    end
  end

  @spec lobby_host_connection() :: %{
          socket: any(),
          user: Teiserver.Account.User.t(),
          lobby: Teiserver.Game.Lobby.t()
        }
  def lobby_host_connection(user \\ nil) do
    %{socket: socket, user: user} =
      if user do
        auth_connection(user)
      else
        auth_connection()
      end

    # # For some reason the login can happen fast enough the client isn't registered
    # # so we call this just to ensure it is
    # if Teiserver.Api.get_client(user.id) == nil do
    #   # If it doesn't exist we wait a moment and try again, just in case
    #   :timer.sleep(500)
    #   if Teiserver.Api.get_client(user.id) == nil do
    #     raise "Client doesn't exist, cannot create lobby"
    #   end
    # end

    lobby_name = Teiserver.uuid()
    lobby = try_to_host_lobby(socket, user, lobby_name)

    client = Teiserver.Api.get_client(user.id)
    assert client.lobby_host?

    # Clear the socket
    flush_socket(socket)

    %{socket: socket, user: user, user_id: user.id, lobby: lobby, lobby_id: lobby.id}
  end

  @spec speak(any(), map) :: any()
  @spec speak(any(), map, non_neg_integer()) :: any()
  def speak(socket, data, sleep \\ 100) do
    msg = Jason.encode!(data)
    :ok = :ssl.send(socket, msg <> "\n")
    :timer.sleep(sleep)
    socket
  end

  @doc """
  Grabs a message from the socket, if there are multiple messages it will only
  grab the first one
  """
  @spec listen(any()) :: map() | :timeout | :closed
  @spec listen(any(), non_neg_integer()) :: map() | :timeout | :closed
  def listen(socket, timeout \\ 100) do
    case :ssl.recv(socket, 0, timeout) do
      # This sometimes borks because there are two messages in the queue and it gets both
      # will need to refactor this to return a list and update all tests accordingly
      {:ok, reply} ->
        reply |> to_string |> Jason.decode!
        # reply
        # |> to_string
        # |> String.split("\n")
        # |> Enum.map(fn
        #   "" ->
        #     nil
        #   s ->
        #     Jason.decode!(s)
        # end)
        # |> Enum.reject(&(&1 == nil))

      {:error, :timeout} -> :timeout
      {:error, :closed} -> :closed
    end
  end

  @doc """
  Groups the list of responses according to their name
  """
  @spec group_responses([map()]) :: map()
  def group_responses(responses) do
    responses
    |> Enum.group_by(fn r ->
      r["name"]
    end)
  end

  @doc """
  Grabs all messages in the socket
  """
  @spec listen_all(any()) :: any()
  @spec listen_all(any(), non_neg_integer()) :: any()
  def listen_all(socket, timeout \\ 100) do
    case :ssl.recv(socket, 0, timeout) do
      {:ok, reply} ->
        # In theory there should only ever be one message in the socket but we do this because
        # sometimes there are two and then it errors. If you're using listen_all you
        # are already expecting a list so ez pz
        messages = reply
        |> to_string
        |> String.split("\n")
        |> Enum.map(fn
          "" ->
            nil
          s ->
            Jason.decode!(s)
        end)
        |> Enum.reject(&(&1 == nil))

        messages ++ listen_all(socket, timeout)

      {:error, :timeout} ->
        []

      {:error, :closed} ->
        []
    end
  end

  @doc """
  Reads all messages in the socket and discards them.
  """
  @spec flush_socket(any()) :: :ok
  def flush_socket(socket) do
    case :ssl.recv(socket, 0, 5) do
      {:ok, _reply} ->
        flush_socket(socket)

      {:error, :timeout} ->
        :ok

      {:error, :closed} ->
        :ok
    end
  end

  @spec assert_auth_failure(map(), String.t()) :: :ok
  def assert_auth_failure(message, command_name) do
    assert message == %{
             "name" => "system/failure",
             "message" => %{
               "command" => command_name,
               "reason" => "Must be logged in"
             }
           }

    assert Angen.Helpers.JsonSchemaHelper.valid?("response.json", message)

    assert Angen.Helpers.JsonSchemaHelper.valid?(
             "system/failure_message.json",
             message["message"]
           )

    :ok
  end

  # assert_success(msg, "section/command")
  @spec assert_success(map(), String.t()) :: :ok
  def assert_success(message, command_name) do
    assert message == %{
             "name" => "system/success",
             "message" => %{
               "command" => command_name
             }
           }

    assert Angen.Helpers.JsonSchemaHelper.valid?("response.json", message)

    assert Angen.Helpers.JsonSchemaHelper.valid?(
             "system/success_message.json",
             message["message"]
           )

    :ok
  end

  @spec close_all_lobbies() :: :ok
  def close_all_lobbies do
    Teiserver.Game.list_lobby_ids()
    |> Enum.each(fn id ->
      Teiserver.Api.close_lobby(id)
    end)

    # Sleep to ensure they're closed before we do anything else
    :timer.sleep(100)
  end
end
