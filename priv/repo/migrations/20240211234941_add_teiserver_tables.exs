defmodule Angen.Repo.Migrations.AddTeiserverTables do
  use Ecto.Migration

  def up do
    Teiserver.Migration.up()
  end

  def down do
    Teiserver.Migration.down(version: 2)
  end
end
