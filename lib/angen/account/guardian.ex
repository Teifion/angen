defmodule Angen.Account.Guardian do
  @moduledoc false
  use Guardian, otp_app: :angen

  alias Teiserver.Account

  def subject_for_token(user, _claims) do
    {:ok, to_string(user.id)}
  end

  def resource_from_claims(%{"sub" => id} = _claims) do
    case Account.get_user(id) do
      nil -> {:error, :resource_not_found}
      user -> {:ok, user}
    end
  end
end
