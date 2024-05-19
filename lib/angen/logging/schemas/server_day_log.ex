defmodule Angen.Logging.ServerDayLog do
  @moduledoc """
  # ServerDayLog
  A log of the activity for that day on the server.

  ### Attributes

  * `:date` - The date this log refers to
  * `:node` - The node this log refers to or "all" if for all nodes combined
  * `:data` - The data included
  """
  use TeiserverMacros, :schema

  @primary_key false
  schema "logging_server_day_logs" do
    field(:date, :date, primary_key: true)
    field(:node, :string, primary_key: true)
    field(:data, :map)
  end

  @type t :: %__MODULE__{
          date: Date.t(),
          data: map()
        }

  @doc false
  @spec changeset(map()) :: Ecto.Changeset.t()
  @spec changeset(map(), map()) :: Ecto.Changeset.t()
  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, ~w(date node ata)a)
    |> validate_required(~w(date node data)a)
  end
end
