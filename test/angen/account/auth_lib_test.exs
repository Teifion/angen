defmodule Angen.Account.AuthLibTest do
  @moduledoc false
  use Angen.DataCase, async: true

  alias Angen.Account.AuthLib

  @perm_list ["perm1", "perm2"]

  describe "roles" do
    test "get_roles/0" do
      roles = AuthLib.get_roles()
      assert is_map(roles)
    end
  end

  describe "allow" do
    test "allow?/2 short-circuit functions" do
      # Denied
      refute AuthLib.allow?(nil, [])
      refute AuthLib.allow?(nil, ["perm1"])

      # Allowed
      assert AuthLib.allow?([], nil)
      assert AuthLib.allow?(["not-the-right-perm"], nil)
      assert AuthLib.allow?([], "")
      assert AuthLib.allow?(["not-the-right-perm"], "")
      assert AuthLib.allow?([], [])
      assert AuthLib.allow?(["not-the-right-perm"], [])
    end

    test "permissions must be string" do
      assert_raise(RuntimeError, fn ->
        AuthLib.allow?(@perm_list, [:perm2])
      end)

      assert_raise(RuntimeError, fn ->
        AuthLib.allow?(@perm_list, :perm2)
      end)
    end

    test "allow_all?/2" do
      assert AuthLib.allow_all?(@perm_list, ["perm1", "perm2"])
      refute AuthLib.allow_all?(@perm_list, ["perm1", "perm3"])
      refute AuthLib.allow_all?(@perm_list, ["perm4", "perm3"])
    end

    test "allow_any?/2" do
      assert AuthLib.allow_any?(@perm_list, ["perm1", "perm2"])
      assert AuthLib.allow_any?(@perm_list, ["perm1", "perm3"])
      refute AuthLib.allow_any?(@perm_list, ["perm4", "perm3"])
    end

    test "Conn.Plug" do
      conn = %Plug.Conn{assigns: %{current_user: %{permissions: @perm_list}}}
      assert AuthLib.allow_any?(conn, ["perm1", "perm2"])
      assert AuthLib.allow_any?(conn, ["perm1", "perm3"])
      refute AuthLib.allow_any?(conn, ["perm4", "perm3"])

      assert AuthLib.allow_all?(conn, ["perm1", "perm2"])
      refute AuthLib.allow_all?(conn, ["perm1", "perm3"])
      refute AuthLib.allow_all?(conn, ["perm4", "perm3"])
    end

    test "Phoenix.LiveView.Socket" do
      conn = %Phoenix.LiveView.Socket{assigns: %{current_user: %{permissions: @perm_list}}}
      assert AuthLib.allow_any?(conn, ["perm1", "perm2"])
      assert AuthLib.allow_any?(conn, ["perm1", "perm3"])
      refute AuthLib.allow_any?(conn, ["perm4", "perm3"])

      assert AuthLib.allow_all?(conn, ["perm1", "perm2"])
      refute AuthLib.allow_all?(conn, ["perm1", "perm3"])
      refute AuthLib.allow_all?(conn, ["perm4", "perm3"])
    end
  end
end
