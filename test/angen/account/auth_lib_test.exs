defmodule Angen.Account.AuthLibTest do
  @moduledoc false
  use Angen.DataCase, async: true

  alias Angen.Account.AuthLib

  describe "functions" do
    test "get_roles/0" do
      roles = AuthLib.get_roles()
      assert is_map(roles)
    end

    test "allow?/2" do
      assert AuthLib.allow?(["perm1", "perm2"], "perm1")
      assert AuthLib.allow?(["perm1", "perm3"], "perm1")
      refute AuthLib.allow?(["perm3", "perm2"], "perm1")
    end
  end
end
