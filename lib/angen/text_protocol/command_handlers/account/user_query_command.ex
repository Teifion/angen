defmodule Angen.TextProtocol.Account.UserQueryCommand do
  @moduledoc false

  use Angen.TextProtocol.CommandHandlerMacro
  alias TextProtocol.Account.UserListResponse

  @impl true
  @spec name :: String.t()
  def name, do: "account/user_query"

  @impl true
  @spec handle(Angen.json_message(), Angen.ConnState.t()) :: Angen.handler_response()
  def handle(_, %{user_id: nil} = state) do
    FailureResponse.generate({name(), "Must be logged in"}, state)
  end

  def handle(%{"filters" => raw_filters} = msg, state) do
    filters = parse_filters(raw_filters)

    if filters == %{} do
      FailureResponse.generate({name(), "Must provide at least 1 filter"}, state)
    else
      limit = String.to_integer(Map.get(msg, "limit", "50"))

      users =
        Teiserver.Account.list_users([where: filters, limit: limit])
        |> Enum.to_list()

      UserListResponse.generate(users, state)
    end
  end

  defp parse_filters(filters) do
    [
      {:id, Map.get(filters, "id", nil)},
      {:name, Map.get(filters, "name", nil)}
    ]
    |> Enum.reject(fn {_, v} -> v == nil end)
    |> Map.new
  end
end
