defmodule Angen.Logging.MatchMinuteLog do
  @moduledoc """
  # MatchMinuteLog
  A log of the activity for that minute on the server.

  ### Attributes

  * `:timestamp` - The timestamp this log refers to
  * `:node` - The node this log refers to or "all" if for all nodes combined
  * `:data` - The data included
  """
  use TeiserverMacros, :schema

  @primary_key false
  schema "logging_match_minute_logs" do
    field(:timestamp, :utc_datetime, primary_key: true)
    field(:node, :string, primary_key: true)
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
    |> cast(attrs, ~w(timestamp node data)a)
    |> validate_required(~w(timestamp node data)a)
  end
end
