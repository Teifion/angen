defmodule Angen.TextProtocol.TypeConvertors do
  @moduledoc """
  Converts objects to JSON
  """

  @spec convert(any()) :: map()
  def convert(object), do: convert(object, nil)

  @spec convert(any(), atom) :: map()
  def convert(object, mode) do
    case do_convert(object, mode) do
      %{} = result -> result
      result -> Jason.decode!(result)
    end
  end

  @spec do_convert(any(), atom) :: map() | String.t()
  def do_convert(%Teiserver.Account.User{} = user, :full), do: Jason.encode!(user) |> Jason.decode!

  def do_convert(%Teiserver.Account.User{} = user, _) do
    %{
      "id" => user.id,
      "name" => user.name
    }
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
