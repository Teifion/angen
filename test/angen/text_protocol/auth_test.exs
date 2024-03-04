defmodule Angen.TextProtocol.AuthTest do
  use Angen.ProtoCase

  describe "register and auth" do
    test "register and auth" do
      %{socket: socket} = raw_connection()

      # Login with no user
      speak(socket, %{
        name: "auth/login",
        command: %{
          name: "registerTest",
          password: "password1"
        }
      })

      response = listen(socket)

      assert response == %{
        "name" => "failure",
        "message" => %{
          "reason" => "No user",
          "command" => "auth/login"
        }
      }

      # Register command
      speak(socket, %{
        name: "register",
        command: %{
          name: "registerTest",
          password: "password1",
          email: "registerTest@registerTest"
        }
      })

      response = listen(socket)
      user = Api.get_user_by_name("registerTest")

      assert response == %{
        "name" => "registered",
        "message" => %{
          "user" => %{
            "id" => user.id,
            "name" => user.name
          }
        }
      }

      # Bad password
      speak(socket, %{
        name: "auth/login",
        command: %{
          name: "registerTest",
          password: "bad-password1"
        }
      })

      response = listen(socket)

      assert response == %{
        "name" => "failure",
        "message" => %{
          "command" => "auth/login",
          "reason" => "No user"
        }
      }

      # Good password
      speak(socket, %{
        name: "auth/login",
        command: %{
          name: "registerTest",
          password: "password1"
        }
      })

      response = listen(socket)

      assert response == %{
        "name" => "logged_in",
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
