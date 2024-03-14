defmodule Angen.Helpers.JsonSchemaHelper do
  @moduledoc false
  require Logger

  # "/apps/teiserver/lib/teiserver-0.1.0/priv/tachyon/schema_v1/*/*/*.json"

  def load() do
    base_path = Application.get_env(:angen, :json_schema_path)

    [
      # Types we have to load in a certain order
      "#{base_path}/types/account/user.json",
      "#{base_path}/types/*.json",
      "#{base_path}/types/*/*.json",
      "#{base_path}/commands/*/*.json",
      "#{base_path}/messages/*/*.json",
      "#{base_path}/*.json"
    ]
    |> Enum.map(&load_path/1)
    |> List.flatten()
  end

  defp load_path(path) do
    path
    |> Path.wildcard()
    |> Enum.map(fn file_path ->
      contents =
        file_path
        |> File.read!()
        |> Jason.decode!()

      root =
        try do
          ExJsonSchema.Schema.resolve(contents)
        rescue
          e ->
            Logger.error("Error resolving schema for path #{file_path}")
            reraise e, __STACKTRACE__
        end

      Cachex.put(:protocol_schemas, root.schema["$id"], root)

      root
    end)
  end

  @spec resolve_schema(String.t()) :: map | nil
  def resolve_schema(p) do
    case resolve_root(p) do
      nil ->
        nil

      root ->
        root.schema
    end
  end

  @spec resolve_root(String.t()) :: map | nil
  def resolve_root(p) do
    Cachex.get!(:protocol_schemas, p)
  end

  @spec cache_keys() :: {:ok, list}
  def cache_keys() do
    Cachex.keys(:protocol_schemas)
  end

  @spec validate(String.t(), map) :: :ok | {:error, any()}
  def validate(schema_name, object) do
    case resolve_root(schema_name) do
      nil ->
        raise "No root for '#{schema_name}'"

      root ->
        ExJsonSchema.Validator.validate(root, object)
    end
  end

  @spec valid?(String.t(), map) :: boolean
  def valid?(schema_name, object) do
    case validate(schema_name, object) do
      :ok -> true
      {:error, _} -> false
    end
  end
end
