defmodule Angen.Logging.ServerMonthLog do
  @moduledoc """
  # ServerMonthLog
  A log of the activity for that month on the server.

  ### Attributes

  * `:date` - The date this log refers to
  * `:year` - The year this log refers to
  * `:month` - The month this log refers to
  * `:data` - The data included
  """
  use TeiserverMacros, :schema

  @primary_key false
  schema "logging_server_month_logs" do
    field(:year, :integer, primary_key: true)
    field(:month, :integer, primary_key: true)
    field(:date, :date)
    field(:data, :map)
  end

  @type t :: %__MODULE__{
          date: Date.t(),
          year: non_neg_integer(),
          month: non_neg_integer(),
          data: map()
        }

  @doc false
  @spec changeset(map()) :: Ecto.Changeset.t()
  @spec changeset(map(), map()) :: Ecto.Changeset.t()
  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, ~w(year month date data)a)
    |> validate_required(~w(year month date data)a)
  end
end
