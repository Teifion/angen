defmodule Angen.General.OverrideHelperTest do
  @moduledoc false
  use Angen.DataCase, async: true

  alias Angen.Helpers.OverrideHelper

  # A bunch of default functions, we just need to ensure they still exist
  test "functions" do
    assert OverrideHelper.lobby_name_acceptor("test name")
    assert OverrideHelper.user_name_acceptor("test name")
  end
end
