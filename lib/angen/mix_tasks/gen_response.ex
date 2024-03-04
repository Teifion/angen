defmodule Mix.Tasks.Angen.Gen.Response do
  @moduledoc """
  mix angen.gen.response section name

  e.g.
    mix angen.gen.response auth login
  """
  use Mix.Task

  @template_module_path "priv/templates/response/module.txt"
  @template_schema_path "priv/templates/response/schema.json"

  @module_output_path "lib/angen/text_protocol/responses"
  @schema_output_path "priv/static/schema/messages"

  def run([]) do
    raise "You need to provide a name"
  end

  def run([section, name]) do
    template_data = make_template_data(section, name)

    do_module(template_data)
    do_schema(template_data)
  end

  defp make_template_data(section, name) do
    %{
      cap_name: String.capitalize(name),
      lower_name: String.downcase(name),
      cap_section: String.capitalize(section),
      lower_section: String.downcase(section)
    }
  end

  defp do_module(template_data) do
    output_file = "#{@module_output_path}/#{template_data.lower_section}/#{template_data.lower_name}_response.ex"
    Mix.Generator.copy_template(@template_module_path, output_file, template_data)
  end

  defp do_schema(template_data) do
    output_file = "#{@schema_output_path}/#{template_data.lower_section}/#{template_data.lower_name}_message.json"
    Mix.Generator.copy_template(@template_schema_path, output_file, template_data)
  end
end
