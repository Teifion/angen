defmodule Angen.TextProtocol.AuthTest do
  @moduledoc false
  use Angen.ProtoCase, async: false

  describe "register and auth" do
    test "register and auth" do
      %{socket: socket} = raw_connection()

      # Bad Register command
      speak(socket, %{
        name: "account/register",
        command: %{
          name: "",
          password: "",
          email: ""
        }
      })

      response = listen(socket)

      assert_failure(
        response,
        "account/register",
        "There was an error registering: name: can't be blank, email: can't be blank, password: can't be blank"
      )

      # Register command
      speak(socket, %{
        name: "account/register",
        command: %{
          name: "registerTest",
          password: "password1",
          email: "registerTest@registerTest"
        }
      })

      response = listen(socket)
      user = Api.get_user_by_name("registerTest")

      assert response == %{
               "name" => "account/registered",
               "message" => %{
                 "user" => %{
                   "id" => user.id,
                   "name" => user.name
                 }
               }
             }

      # No user
      speak(socket, %{
        name: "auth/get_token",
        command: %{
          name: "no-user",
          password: "bad-password1",
          user_agent: "UnitTest"
        }
      })

      response = listen(socket)
      assert_failure(response, "auth/get_token", "Bad authentication")

      # Bad password
      speak(socket, %{
        name: "auth/get_token",
        command: %{
          name: "registerTest",
          password: "bad-password1",
          user_agent: "UnitTest"
        }
      })

      response = listen(socket)
      assert_failure(response, "auth/get_token", "Bad authentication")

      # Good password
      speak(socket, %{
        name: "auth/get_token",
        command: %{
          name: "registerTest",
          password: "password1",
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
                   "name" => "registerTest"
                 }
               }
             }
    end
  end
end
