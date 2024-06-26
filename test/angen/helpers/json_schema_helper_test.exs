defmodule Angen.General.JsonSchemaHelperTest do
  @moduledoc false
  use Angen.DataCase, async: true

  alias Angen.Helpers.JsonSchemaHelper

  test "getting keys" do
    {:ok, keys} = JsonSchemaHelper.cache_keys()
    assert is_list(keys)
  end
end
