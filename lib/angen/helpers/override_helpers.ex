defmodule Angen.Helpers.OverrideHelper do
  @moduledoc """
  Overrides for Teiserver functions
  """

  @spec lobby_name_acceptor(String.t()) :: boolean
  def lobby_name_acceptor(_name) do
    true
  end

  @spec user_name_acceptor(String.t()) :: boolean
  def user_name_acceptor(_name) do
    true
  end

  @spec calculate_user_permissions(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  def calculate_user_permissions(changeset) do
    groups = Ecto.Changeset.get_field(changeset, :groups, [])

    permissions =
      groups
      |> Enum.map(&expand_group/1)
      |> List.flatten()
      |> Enum.uniq()

    changeset
    |> Ecto.Changeset.put_change(:permissions, permissions)
  end

  defp expand_group(group_name) do
    roles = Angen.Account.AuthLib.get_roles()

    sub_groups =
      Map.get(roles, group_name, [])
      |> Enum.map(fn sub_group ->
        expand_group(sub_group)
      end)

    [group_name | sub_groups]
  end
end
