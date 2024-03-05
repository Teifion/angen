defmodule Angen.Repo.Migrations.CreateUserTokens do
  use Ecto.Migration

  def change do
    create table(:account_user_tokens) do
      add(:user_id, references(:account_users, on_delete: :nothing, type: :uuid), type: :uuid)

      add :identifier_code, :string
      add :renewal_code, :string

      add :user_agent, :string
      add :ip, :string

      add :expires_at, :utc_datetime
      add :last_used_at, :utc_datetime

      timestamps()
    end

    create index(:account_user_tokens, [:identifier_code])
    create index(:account_user_tokens, [:user_id])
  end
end
