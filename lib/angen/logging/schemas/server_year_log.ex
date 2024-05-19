defmodule Angen.Logging.ServerYearLog do
  @moduledoc """
  # ServerYearLog
  A log of the activity for that year on the server.

  ### Attributes

  * `:date` - The date this log refers to
  * `:year` - The year this log refers to
  * `:node` - The node this log refers to or "all" if for all nodes combined
  * `:data` - The data included
  """
  use TeiserverMacros, :schema

  @primary_key false
  schema "logging_server_year_logs" do
    field(:year, :integer, primary_key: true)
    field(:node, :string, primary_key: true)
    field(:date, :date)
    field(:data, :map)
  end

  @type t :: %__MODULE__{
          date: Date.t(),
          year: non_neg_integer(),
          data: map()
        }

  @doc false
  @spec changeset(map()) :: Ecto.Changeset.t()
  @spec changeset(map(), map()) :: Ecto.Changeset.t()
  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, ~w(year date node data)a)
    |> validate_required(~w(year date node data)a)
  end
end
