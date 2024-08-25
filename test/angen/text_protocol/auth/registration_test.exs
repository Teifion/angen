defmodule Angen.TextProtocol.RegistrationTest do
  @moduledoc false
  use Angen.ProtoCase, async: false

  describe "register" do
    test "bad arguments" do
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
    end

    test "no validation" do
      %{socket: socket} = raw_connection()

      Teiserver.set_server_setting_value("user_verification_mode", "None")
      uuid = Teiserver.uuid()

      # Register command
      speak(socket, %{
        name: "account/register",
        command: %{
          name: uuid,
          password: "password1",
          email: "#{uuid}@#{uuid}"
        }
      })

      response = listen(socket)
      user = Teiserver.get_user_by_name(uuid)
      assert Angen.Account.verified?(user.id)

      assert response == %{
               "name" => "account/registered",
               "message" => %{
                 "user" => %{
                   "id" => user.id,
                   "name" => user.name
                 }
               }
             }
    end

    test "with validation" do
      %{socket: socket} = raw_connection()

      Teiserver.set_server_setting_value("user_verification_mode", "Manual")
      uuid = Teiserver.uuid()

      # Register command
      speak(socket, %{
        name: "account/register",
        command: %{
          name: uuid,
          password: "password1",
          email: "#{uuid}@#{uuid}"
        }
      })

      response = listen(socket)
      user = Teiserver.get_user_by_name(uuid)
      refute Angen.Account.verified?(user.id)

      assert response == %{
               "name" => "account/registered",
               "message" => %{
                 "user" => %{
                   "id" => user.id,
                   "name" => user.name
                 }
               }
             }

      Angen.Account.verify_user(user.id)

      user = Teiserver.get_user_by_name(uuid)
      assert Angen.Account.verified?(user.id)
    end
  end
end
