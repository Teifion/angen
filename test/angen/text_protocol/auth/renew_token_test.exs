defmodule Angen.TextProtocol.Auth.RenewTokenTest do
  @moduledoc false
  use Angen.ProtoCase

  alias Angen.Account

  test "renew token" do
    user = create_test_user()
    %{socket: socket} = raw_connection()

    {:ok, token} = Account.create_user_token(user.id, "text-protocol", "test", "127.0.0.1")
    assert Enum.count(Account.list_user_tokens(where: [user_id: user.id])) == 1

    # Bad identifier
    speak(socket, %{
      name: "auth/renew",
      command: %{
        identifier_code: "123456",
        renewal_code: token.renewal_code
      }
    })

    response = listen(socket)

    assert response == %{
              "name" => "system/failure",
              "message" => %{
                "command" => "auth/renew",
                "reason" =>
                  "No token"
              }
            }

    # Bad renewal
    speak(socket, %{
      name: "auth/renew",
      command: %{
        identifier_code: token.identifier_code,
        renewal_code: "123456"
      }
    })

    response = listen(socket)

    assert response == %{
              "name" => "system/failure",
              "message" => %{
                "command" => "auth/renew",
                "reason" =>
                  "No token"
              }
            }

    # Now correctly
    speak(socket, %{
      name: "auth/renew",
      command: %{
        identifier_code: token.identifier_code,
        renewal_code: token.renewal_code
      }
    })

    response = listen(socket)
    new_token = Angen.Account.get_user_token(nil, where: [user_id: user.id])

    assert response == %{
              "name" => "auth/token",
              "message" => %{
                "token" => %{
                  "user_id" => user.id,
                  "identifier_code" => new_token.identifier_code,
                  "renewal_code" => new_token.renewal_code,
                  "expires_at" => Jason.encode!(new_token.expires_at) |> Jason.decode!()
                }
              }
            }

    assert new_token.identifier_code != token.identifier_code
    assert new_token.renewal_code != token.renewal_code

    # Assert the old token is gone
    assert Enum.count(Account.list_user_tokens(where: [user_id: user.id])) == 1
  end
end
