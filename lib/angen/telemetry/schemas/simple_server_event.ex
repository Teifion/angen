defmodule Angen.Telemetry.SimpleServerEvent do
  @moduledoc """
  # SimpleServerEvent
  A simple event taking place on the server

  ### Attributes

  * `:user_id` - The user this event took place for
  * `:event_type_id` - The `Angen.Telemetry.EventType` this event belongs to
  * `:inserted_at` - The timestamp the event took place
  """
  use TeiserverMacros, :schema

  schema "telemetry_simple_server_events" do
    belongs_to(:user, Teiserver.Account.User, type: Ecto.UUID)
    belongs_to(:event_type, Angen.Telemetry.EventType)
    field(:inserted_at, :utc_datetime)
  end

  @type id :: non_neg_integer()

  @type t :: %__MODULE__{
          user_id: Teiserver.user_id(),
          event_type_id: Angen.Telemetry.EventType.id(),
          inserted_at: DateTime.t()
        }

  @doc false
  @spec changeset(map()) :: Ecto.Changeset.t()
  @spec changeset(map(), map()) :: Ecto.Changeset.t()
  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, ~w(user_id event_type_id inserted_at)a)
    |> validate_required(~w(event_type_id inserted_at)a)
  end
end
