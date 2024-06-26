defmodule Angen.General.StylingHelpersTest do
  use Angen.DataCase, async: true

  alias Angen.Helper.StylingHelper

  test "icon" do
    params =
      ~w(report up back list show search new edit delete export structure documentation chat admin moderation overview detail user filter summary chart day week month quarter year logging server_activity game_activity audit)a

    for p <- params do
      "fa-" <> _ = StylingHelper.icon(p)
      "fa-solid fa-" <> _ = StylingHelper.icon(p, "solid")
    end
  end
end
