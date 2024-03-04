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
      import Angen.ProtoCase
      import Angen.Support.ProtoLib
    end
  end

  setup tags do
    Angen.DataCase.setup_sandbox(tags)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

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

  def auth_connection() do
    {:ok, user} = Teiserver.Account.create_user(%{
      name: Ecto.UUID.generate(),
      email: "#{Ecto.UUID.generate()}@test",
      password: "password1"
    })

    auth_connection(user)
  end

  def auth_connection(user) do
    host = ~c"127.0.0.1"
    port = Application.get_env(:angen, :tls_port)

    {:ok, socket} =
      :ssl.connect(host, port,
        active: false,
        verify: :verify_none
      )

    speak(socket, %{
      name: "auth/login",
      command: %{
        name: user.name,
        password: "password1"
      }
    })

    response = listen(socket)

    assert response == %{
      "name" => "logged_in",
      "message" => %{
        "user" => %{
          "id" => user.id,
          "name" => user.name
        }
      }
    }

    %{socket: socket, user: user}
  end

  @spec speak(any(), map) :: any()
  @spec speak(any(), map, non_neg_integer()) :: any()
  def speak(socket, data, sleep \\ 100) do
    msg = Jason.encode!(data)
    :ok = :ssl.send(socket, msg <> "\n")
    :timer.sleep(sleep)
    socket
  end

  @spec listen(any()) :: any()
  @spec listen(any(), non_neg_integer()) :: any()
  def listen(socket, timeout \\ 500) do
    case :ssl.recv(socket, 0, timeout) do
      {:ok, reply} -> reply |> to_string |> Jason.decode!()
      {:error, :timeout} -> :timeout
      {:error, :closed} -> :closed
    end
  end

  # def listen_until(socket, timeout \\ 500) do
  #   case :ssl.recv(socket, 0, timeout) do
  #     {:ok, reply} ->
  #       msg = reply |> to_string |> Jason.decode!
  #       [msg | listen_until(socket, timeout)]
  #     {:error, :timeout} -> :timeout
  #     {:error, :closed} -> :closed
  #   end
  # end
end
