defmodule Angen.DevSupport.LobbyHostIdleBotTest do
  @moduledoc false
  use Angen.ProtoCase, async: false

  alias Angen.DevSupport.{LobbyHostIdleBot, ManagerServer}

  describe "echo bot" do
    test "back and forth" do
      close_all_lobbies()

      {:ok, p} = ManagerServer.start_bot(LobbyHostIdleBot, %{})
      send(p, :startup)
      :timer.sleep(1000)

      assert Enum.count(Teiserver.list_lobby_ids()) == 1

      # Stop the bot manually to prevent it doing something while we tear down the test
      ManagerServer.stop_bot(p)
      :timer.sleep(500)
    end
  end
end
