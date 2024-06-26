defmodule Angen do
  @moduledoc """

  """

  defmodule ConnState do
    @moduledoc false
    defstruct ~w(ip socket conn_id user_id user lobby_host? party_id lobby_id in_game?)a
  end

  @spec startup_complete?() :: boolean
  def startup_complete?() do
    Cachex.get!(:angen_metadata, :startup_complete)
  end

  @doc """
  Blocks until startup is complete
  """
  @spec wait_for_startup() :: :ok
  def wait_for_startup() do
    if startup_complete?() do
      :ok
    else
      :timer.sleep(50)
      wait_for_startup()
    end
  end

  @type conn_id :: Ecto.UUID.t()
  @type user_id :: Teiserver.user_id()
  @type raw_message :: String.t()
  @type json_message :: map()

  @type handler_response :: {nil | raw_message() | [raw_message()], ConnState.t()}

  # Cluster cache delegation
  @spec invalidate_cache(atom, any) :: :ok
  defdelegate invalidate_cache(table, key_or_keys), to: Teiserver.Helpers.CacheHelper
end
