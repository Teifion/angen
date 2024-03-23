defmodule Angen do
  @moduledoc """

  """

  defmodule ConnState do
    @moduledoc false
    defstruct ~w(ip socket user_id user lobby_host? party_id lobby_id in_game?)a
  end

  @type raw_message :: String.t()
  @type json_message :: map()

  @type handler_response :: {nil | raw_message() | [raw_message()], ConnState.t()}
end
