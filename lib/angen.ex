defmodule Angen do
  @moduledoc """

  """

  defmodule ConnState do
    @moduledoc false
    defstruct [:user_id, :socket]
  end

  @type raw_message :: String.t()
  @type json_message :: map()

  @type handler_response :: {nil | raw_message() | [raw_message()], ConnState.t()}
end
