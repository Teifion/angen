defmodule Angen.TextProtocol.ExternalDispatchTest do
  use Angen.DataCase

  alias Angen.TextProtocol.ExternalDispatch

  describe "module lookup" do
    test "lookup" do
    {:ok, module_list} = :application.get_key(:angen, :modules)

    command_modules =
      module_list
      |> Enum.filter(fn m ->
        Code.ensure_loaded(m)

        # Get all modules implementing the relevant macro
        case m.__info__(:attributes)[:behaviour] do
          [] -> false
          nil -> false
          b ->
            Enum.member?(b, Angen.TextProtocol.CommandHandlerMacro)
        end
      end)
      |> Enum.each(fn m ->
        command_string = m.command()
        assert ExternalDispatch.lookup(command_string) == m
      end)
    end
  end
end
