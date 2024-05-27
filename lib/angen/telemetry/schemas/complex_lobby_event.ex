defmodule Angen.Telemetry.ComplexLobbyEvent do
  @moduledoc """
  # ComplexLobbyEvent
  A complex event taking place inside a lobby

  ### Attributes

  * `:user_id` - The `Teiserver.Account.User` this event took place for
  * `:match_id` - The match_id of the lobby this took place in
  * `:event_type_id` - The `Angen.Telemetry.EventType` this event belongs to
  * `:inserted_at` - The timestamp the event took place
  * `:details` - A key-value map of the details of the event
  """
  use TeiserverMacros, :schema

  schema "telemetry_complex_lobby_events" do
    belongs_to(:user, Teiserver.Account.User, type: Ecto.UUID)
    belongs_to(:match, Teiserver.Game.Match, type: Ecto.UUID)
    belongs_to(:event_type, Angen.Telemetry.EventType)
    field(:inserted_at, :utc_datetime)

    field(:details, :map)
  end

  @type id :: non_neg_integer()

  @type t :: %__MODULE__{
          user_id: Teiserver.user_id(),
          match_id: Teiserver.match_id(),
          event_type_id: Angen.Telemetry.EventType.id(),
          inserted_at: DateTime.t(),
          details: map()
        }

  @doc false
  @spec changeset(map()) :: Ecto.Changeset.t()
  @spec changeset(map(), map()) :: Ecto.Changeset.t()
  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, ~w(user_id match_id event_type_id inserted_at details)a)
    |> validate_required(~w(user_id match_id event_type_id inserted_at details)a)
  end
end
