defmodule Angen.TextProtocol.Account.ChangePasswordTest do
  @moduledoc false
  use Angen.ProtoCase, async: false

  alias Angen.Account

  test "unauth" do
    %{socket: socket} = raw_connection()

    speak(socket, %{
      name: "account/change_password",
      command: %{current_password: "123", new_password: "456"}
    })

    msg = listen(socket)

    assert_auth_failure(msg, "account/change_password")
  end

  test "change" do
    %{socket: socket, user: user} = auth_connection()
    assert Enum.count(Account.list_user_tokens(where: [user_id: user.id])) == 1

    # Incorrect existing password
    speak(socket, %{
      name: "account/change_password",
      command: %{
        current_password: "123",
        new_password: "password2"
      }
    })

    msg = listen(socket)

    assert_failure(
      msg,
      "account/change_password",
      "There was an error changing your password: existing: Incorrect password"
    )

    # Bad new password
    speak(socket, %{
      name: "account/change_password",
      command: %{
        current_password: "password1",
        new_password: "1"
      }
    })

    msg = listen(socket)

    assert_failure(
      msg,
      "account/change_password",
      "There was an error changing your password: password: Passwords must be at least 6 characters long"
    )

    # Now good password
    speak(socket, %{
      name: "account/change_password",
      command: %{
        current_password: "password1",
        new_password: "password123"
      }
    })

    assert listen(socket) == :timeout

    # Ensure our socket is a not working
    speak(socket, %{
      name: "system/ping",
      command: %{}
    })

    assert listen(socket) == :timeout
    assert Enum.empty?(Account.list_user_tokens(where: [user_id: user.id]))

    # Now try to re-auth, first with old password
    %{socket: socket} = raw_connection()

    speak(socket, %{
      name: "auth/get_token",
      command: %{
        id: user.id,
        password: "password1",
        user_agent: "UnitTest"
      }
    })

    response = listen(socket)
    assert_failure(response, "auth/get_token", "Bad authentication")

    # Now with a the new password
    speak(socket, %{
      name: "auth/get_token",
      command: %{
        id: user.id,
        password: "password123",
        user_agent: "UnitTest"
      }
    })

    response = listen(socket)
    token = Angen.Account.get_user_token(nil, where: [user_id: user.id])

    assert response == %{
             "name" => "auth/token",
             "message" => %{
               "token" => %{
                 "user_id" => user.id,
                 "identifier_code" => token.identifier_code,
                 "renewal_code" => token.renewal_code,
                 "expires_at" => Jason.encode!(token.expires_at) |> Jason.decode!()
               }
             }
           }
  end
end
