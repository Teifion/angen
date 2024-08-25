defmodule Angen.TextProtocol.AuthTest do
  @moduledoc false
  use Angen.ProtoCase, async: false

  describe "auth" do
    test "no user" do
      %{socket: socket} = raw_connection()

      # No user
      speak(socket, %{
        name: "auth/get_token",
        command: %{
          id: "5383b1f8-393e-4dc5-8798-dcce8fa67a00",
          password: "bad-password1",
          user_agent: "UnitTest"
        }
      })

      response = listen(socket)
      assert_failure(response, "auth/get_token", "Bad authentication")
    end

    test "bad password" do
      %{socket: socket} = raw_connection()
      user = create_test_user()

      speak(socket, %{
        name: "auth/get_token",
        command: %{
          id: user.id,
          password: "bad-password1",
          user_agent: "UnitTest"
        }
      })

      response = listen(socket)
      assert_failure(response, "auth/get_token", "Bad authentication")
    end

    test "unverified user" do
      %{socket: socket} = raw_connection()
      user = create_test_user()
      Teiserver.Account.UserLib.restrict_user(user, "unverified")

      speak(socket, %{
        name: "auth/get_token",
        command: %{
          id: user.id,
          password: "password1",
          user_agent: "UnitTest"
        }
      })

      response = listen(socket)
      assert_failure(response, "auth/get_token", "Unable to generate token")
    end

    test "good auth" do
      %{socket: socket} = raw_connection()
      user = create_test_user()

      speak(socket, %{
        name: "auth/get_token",
        command: %{
          id: user.id,
          password: "password1",
          user_agent: "UnitTest"
        }
      })

      response = listen(socket)
      token = Angen.Account.get_user_token(nil, where: [user_id: user.id])

      assert token

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

      # Now login with the token
      # first a bad password
      speak(socket, %{
        name: "auth/login",
        command: %{
          token: "bad-token",
          user_agent: "UnitTest"
        }
      })

      response = listen(socket)
      assert_failure(response, "auth/login", "Bad token")

      # And valid
      speak(socket, %{
        name: "auth/login",
        command: %{
          token: token.identifier_code,
          user_agent: "UnitTest"
        }
      })

      response = listen(socket)

      assert response == %{
               "name" => "auth/logged_in",
               "message" => %{
                 "user" => %{
                   "id" => user.id,
                   "name" => user.name
                 }
               }
             }
    end
  end
end
