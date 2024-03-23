defmodule Angen.Account.UserToken do
  @moduledoc """
  # UserToken
  Description here

  ### Attributes

  * `:identifier_code` - The value used to login and auth as the user
  * `:renewal_code` - The value used to renew the token
  """
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: ~w(user_id identifier_code renewal_code expires_at)a}
  schema "account_user_tokens" do
    belongs_to(:user, Teiserver.Account.User, type: Ecto.UUID)

    field(:identifier_code, :string)
    field(:renewal_code, :string)
    field(:context, :string)
    field(:user_agent, :string)
    field(:ip, :string)

    field(:expires_at, :utc_datetime)
    field(:last_used_at, :utc_datetime)

    timestamps()
  end

  @type id :: non_neg_integer()
  @type identifier_code :: String.t()
  @type renewal_code :: String.t()

  @type t :: %__MODULE__{
          id: id(),
          user_id: Teiserver.user_id(),
          user: Teiserver.Account.User.t(),
          identifier_code: identifier_code(),
          renewal_code: renewal_code(),
          context: String.t(),
          user_agent: String.t(),
          ip: String.t(),
          expires_at: DateTime.t(),
          last_used_at: DateTime.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @doc false
  @spec changeset(map()) :: Ecto.Changeset.t()
  @spec changeset(map(), map()) :: Ecto.Changeset.t()
  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(
      attrs,
      ~w(user_id identifier_code renewal_code context user_agent ip expires_at last_used_at)a
    )
    |> validate_required(
      ~w(user_id identifier_code context renewal_code user_agent ip expires_at)a
    )
  end
end
