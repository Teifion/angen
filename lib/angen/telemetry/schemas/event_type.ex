defmodule Angen.Telemetry.EventType do
  @moduledoc """
  # EventType
  A name lookup for events to prevent us having to store a string for every single row.

  ### Attributes

  * `:category` - The category
  * `:name` - The name of the event
  """
  use TeiserverMacros, :schema

  schema "telemetry_event_types" do
    field(:category, :string)
    field(:name, :string)
  end

  @type id :: non_neg_integer()

  @type t :: %__MODULE__{
          id: id(),
          name: String.t()
        }

  @doc false
  @spec changeset(map()) :: Ecto.Changeset.t()
  @spec changeset(map(), map()) :: Ecto.Changeset.t()
  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, ~w(category name)a)
    |> validate_required(~w(category name)a)
  end
end
