defmodule Angen.DevSupport.LobbyHostBotTest do
  @moduledoc false
  use Angen.ProtoCase, async: false

  alias Angen.DevSupport.{LobbyHostBot, ManagerServer}

  describe "echo bot" do
    test "back and forth" do
      assert Enum.empty?(Api.list_lobby_ids())

      {:ok, p} = ManagerServer.start_bot(LobbyHostBot, %{})
      send(p, :startup)
      :timer.sleep(1000)

      assert Enum.count(Api.list_lobby_ids()) == 1
    end
  end
end
