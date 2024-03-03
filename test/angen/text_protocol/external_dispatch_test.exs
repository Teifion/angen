defmodule Angen.TextProtocol.ExternalDispatchTest do
  use Angen.DataCase

  alias Angen.TextProtocol.ExternalDispatch
  alias Angen.Helpers.JsonSchemaHelper

  describe "module lookup" do
    test "lookup" do
      {:ok, module_list} = :application.get_key(:angen, :modules)

      module_list
      |> Enum.filter(fn m ->
        Code.ensure_loaded(m)

        # Get all modules implementing the relevant macro
        case m.__info__(:attributes)[:behaviour] do
          [] ->
            false

          nil ->
            false

          b ->
            Enum.member?(b, Angen.TextProtocol.CommandHandlerMacro)
        end
      end)
      |> Enum.each(fn m ->
        command_name = m.name()

        # Assert the lookup for this module exists
        assert ExternalDispatch.lookup(command_name) == m, msg: "No lookup for module #{m} with name #{command_name}"

        # Assert we have a relevant response schema
        schema_name = "#{command_name}_command.json"
        assert JsonSchemaHelper.resolve_root(schema_name) != nil, message: "No schema for #{m} with schema_name #{schema_name}"
      end)
    end
  end
end
