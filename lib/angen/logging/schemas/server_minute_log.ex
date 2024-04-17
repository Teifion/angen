defmodule Angen.Logging.ServerMinuteLog do
  @moduledoc """
  # ServerMinuteLog
  A log of the activity for that minute on the server.

  ### Attributes

  * `:timestamp` - The timestamp this log refers to
  * `:data` - The data included
  """
  use TeiserverMacros, :schema

  @primary_key false
  schema "logging_server_minute_logs" do
    field(:timestamp, :utc_datetime, primary_key: true)
    field(:data, :map)
  end

  @type t :: %__MODULE__{
          timestamp: DateTime.t(),
          data: map()
        }

  @doc false
  @spec changeset(map()) :: Ecto.Changeset.t()
  @spec changeset(map(), map()) :: Ecto.Changeset.t()
  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, ~w(timestamp data)a)
    |> validate_required(~w(timestamp data)a)
  end
end
