defmodule Angen.Logging.ServerQuarterLog do
  @moduledoc """
  # ServerQuarterLog
  A log of the activity for that quarter on the server.

  ### Attributes

  * `:date` - The date this log refers to
  * `:year` - The year this log refers to
  * `:quarter` - The quarter this log refers to
  * `:data` - The data included
  """
  use TeiserverMacros, :schema

  @primary_key false
  schema "logging_server_quarter_logs" do
    field(:year, :integer, primary_key: true)
    field(:quarter, :integer, primary_key: true)
    field(:date, :date)
    field(:data, :map)
  end

  @type t :: %__MODULE__{
          date: Date.t(),
          year: non_neg_integer(),
          quarter: non_neg_integer(),
          data: map()
        }

  @doc false
  @spec changeset(map()) :: Ecto.Changeset.t()
  @spec changeset(map(), map()) :: Ecto.Changeset.t()
  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, ~w(year quarter date data)a)
    |> validate_required(~w(year quarter date data)a)
  end
end
