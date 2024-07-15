defmodule Angen.Repo.Migrations.AddDBClusterTables do
  use Ecto.Migration

  def up do
    DBCluster.Migration.up()
  end

  def down do
    DBCluster.Migration.down(version: 1)
  end
end
