defmodule Angen.TextProtocol.TypeConvertors do
  @moduledoc """
  Converts objects to JSON
  """

  @spec convert(any()) :: map()
  def convert(object), do: convert(object, nil)

  @spec convert(any(), atom) :: map()
  def convert(%Teiserver.Account.User{} = user, _) do
    %{
      id: user.id,
      name: user.name
    }
  end

  def convert(object, _) do
    raise "No handler for object: #{inspect object}"
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
