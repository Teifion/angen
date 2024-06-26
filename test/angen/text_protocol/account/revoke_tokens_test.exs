defmodule Angen.TextProtocol.Account.RevokeTokensTest do
  @moduledoc false
  use Angen.ProtoCase, async: false

  alias Angen.Account

  test "unauth" do
    %{socket: socket} = raw_connection()

    speak(socket, %{name: "account/revoke_tokens", command: %{}})
    msg = listen(socket)

    assert_auth_failure(msg, "account/revoke_tokens")
  end

  test "revoke" do
    user = create_test_user()
    %{socket: socket1} = auth_connection(user: user)
    %{socket: socket2} = auth_connection(user: user)

    {:ok, _extra_token} = Account.create_user_token(user.id, "text-protocol", "test", "127.0.0.1")

    assert Enum.count(Account.list_user_tokens(where: [user_id: user.id])) == 3

    # Now correctly
    speak(socket1, %{
      name: "account/revoke_tokens",
      command: %{}
    })

    assert Enum.empty?(Account.list_user_tokens(where: [user_id: user.id]))

    :timer.sleep(50)

    assert listen(socket1) == :timeout
    assert listen(socket2) == :closed

    # Socket 1 times out, what happens if we try to say something?
    # we want to ensure it's not still connected (why it shows as timeout instead
    # of closed I'm not sure, the key part is it's not an auth'd connection)
    speak(socket1, %{
      name: "system/ping",
      command: %{}
    })

    assert listen(socket1) == :timeout
  end
end
