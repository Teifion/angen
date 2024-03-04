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
        "name" => "system/failure",
        "message" => %{
          "reason" => "No user",
          "command" => "auth/login"
        }
      }

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

      assert response == %{
        "name" => "system/failure",
        "message" => %{
          "command" => "account/register",
          "reason" => "There was an error registering: name: can't be blank, email: can't be blank, password: can't be blank"
        }
      }

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
        "name" => "system/failure",
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
