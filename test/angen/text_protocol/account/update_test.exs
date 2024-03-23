defmodule Angen.TextProtocol.Account.UpdateTest do
  @moduledoc false
  use Angen.ProtoCase, async: false

  test "unauth" do
    %{socket: socket} = raw_connection()

    speak(socket, %{name: "account/update", command: %{password: "123"}})
    msg = listen(socket)

    assert_auth_failure(msg, "account/update")
  end

  test "update" do
    %{socket: socket, user: user} = auth_connection()

    # Bad password
    speak(socket, %{
      name: "account/update",
      command: %{
        password: "password"
      }
    })

    msg = listen(socket)

    assert msg == %{
             "name" => "system/failure",
             "message" => %{
               "command" => "account/update",
               "reason" =>
                 "There was an error changing your details: password_confirmation: Incorrect password"
             }
           }

    assert JsonSchemaHelper.valid?("response.json", msg)
    assert JsonSchemaHelper.valid?("system/failure_message.json", msg["message"])

    # No changes
    speak(socket, %{
      name: "account/update",
      command: %{
        password: "password1"
      }
    })

    msg = listen(socket)
    assert_success(msg, "account/update")

    unchanged_user = Api.get_user_by_id(user.id)
    assert user == unchanged_user

    # Make changes
    speak(socket, %{
      name: "account/update",
      command: %{
        password: "password1",
        name: "update-test-name",
        email: "update-test-email@email"
      }
    })

    msg = listen(socket)
    assert_success(msg, "account/update")

    changed_user = Api.get_user_by_id(user.id)
    assert user != changed_user

    assert changed_user.name == "update-test-name"
    assert changed_user.email == "update-test-email@email"

    # Now try to use the same email as another user
    user2 = create_test_user()

    speak(socket, %{
      name: "account/update",
      command: %{
        password: "password1",
        email: user2.email
      }
    })

    msg = listen(socket)

    assert msg == %{
             "name" => "system/failure",
             "message" => %{
               "command" => "account/update",
               "reason" =>
                 "There was an error changing your details: email: has already been taken"
             }
           }

    assert JsonSchemaHelper.valid?("response.json", msg)
    assert JsonSchemaHelper.valid?("system/failure_message.json", msg["message"])
  end
end
