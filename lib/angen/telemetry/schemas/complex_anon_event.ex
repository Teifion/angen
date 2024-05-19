defmodule Angen.Telemetry.ComplexAnonEvent do
  @moduledoc """
  # ComplexAnonEvent
  A complex event taking place on a Client application but without a user_id to link it to.

  ### Attributes

  * `:hash_id` - A hash value representing the anonymous user allowing events from the same person to be grouped without linking them to a specific user profile
  * `:event_type_id` - The `Angen.Telemetry.EventType` this event belongs to
  * `:inserted_at` - The timestamp the event took place
  * `:details` - A key-value map of the details of the event
  """
  use TeiserverMacros, :schema

  schema "telemetry_complex_anon_events" do
    field(:hash_id, Ecto.UUID)
    belongs_to(:event_type, Angen.Telemetry.EventType)
    field(:inserted_at, :utc_datetime)

    field(:details, :map)
  end

  @type id :: non_neg_integer()

  @type t :: %__MODULE__{
          hash_id: Ecto.UUID.t(),
          event_type_id: Angen.Telemetry.EventType.id(),
          inserted_at: DateTime.t(),
          details: map()
        }

  @doc false
  @spec changeset(map()) :: Ecto.Changeset.t()
  @spec changeset(map(), map()) :: Ecto.Changeset.t()
  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, ~w(hash_id event_type_id inserted_at details)a)
    |> validate_required(~w(hash_id event_type_id inserted_at details)a)
  end
end
