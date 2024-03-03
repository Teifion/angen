defmodule Angen.TextProtocol.AuthTest do
  use Angen.ProtoCase

  describe "register and auth" do
    test "register and auth" do
      %{socket: socket} = new_connection()

      # # Login with no user
      # speak(socket, %{
      #   command: "login",
      #   name: "registerTest",
      #   password: "password1"
      # })

      # response = listen(socket)

      # assert response == %{
      #          "command" => "login",
      #          "reason" => "no user",
      #          "result" => "failure"
      #        }

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

      assert response == %{
               "command" => "register",
               "message" => "User 'registerTest' created, you can now login with this user",
               "result" => "success"
             }

      user = Api.get_user_by_name("registerTest")

      # Now login
      speak(socket, %{
        command: "login",
        name: "registerTest",
        password: "password1"
      })

      response = listen(socket)

      assert response == %{
               "command" => "login",
               "message" => "You are now logged in as 'registerTest'",
               "user_id" => user.id,
               "result" => "success"
             }
    end
  end
end
