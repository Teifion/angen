defmodule Angen.TextProtocol.TypeConvertors do
  @moduledoc """
  Converts objects to JSON
  """

  @spec convert(any()) :: map()
  def convert(object), do: convert(object, nil)

  @spec convert(any(), atom) :: map()
  def convert(objects, mode) when is_list(objects) do
    objects
    |> Enum.map(fn o ->
      convert(o, mode)
    end)
  end

  def convert(object, mode) do
    case do_convert(object, mode) do
      %{} = result -> result
      result -> Jason.decode!(result)
    end
  end

  @spec do_convert(any(), atom) :: map() | String.t()
  def do_convert(%Teiserver.Account.User{} = user, :full),
    do: Jason.encode!(user) |> Jason.decode!()

  def do_convert(%Teiserver.Account.User{} = user, _) do
    ~w(id name)a
    |> Map.new(fn key ->
      {to_string(key), Map.get(user, key)}
    end)
  end

  def do_convert(%Teiserver.Connections.Client{} = client, :full),
    do: Jason.encode!(client) |> Jason.decode!()

  def do_convert(%Teiserver.Connections.Client{} = client, :partial) do
    ~w(id party_id connected? last_disconnected afk? in_game? lobby_id)a
    |> Map.new(fn key ->
      {to_string(key), Map.get(client, key)}
    end)
  end

  def do_convert(object, _) do
    case Jason.encode(object) do
      {:ok, str} ->
        Jason.decode!(str)

      {:error, err} ->
        raise "No handler for object: #{inspect(object)}, err: #{inspect(err)}"
    end
  end

  @spec map_convert([any()]) :: [map()]
  def map_convert(object), do: map_convert(object, nil)

  @spec map_convert([any()], atom) :: [map()]
  def map_convert(objects, a) do
    objects
    |> Enum.map(fn o ->
      convert(o, a)
    end)
  end
end
