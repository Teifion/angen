defmodule Mix.Tasks.Angen.Gen.Command do
  @moduledoc """
  mix angen.gen.request section name

  e.g.
    mix angen.gen.request auth login
  """
  use Mix.Task

  @template_module_path "priv/templates/request/module.txt"
  @template_schema_path "priv/templates/request/schema.json"

  @module_output_path "lib/angen/text_protocol/command_handlers"
  @schema_output_path "priv/static/schema/commands"

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
    output_file =
      "#{@module_output_path}/#{template_data.lower_section}/#{template_data.lower_name}_command.ex"

    Mix.Generator.copy_template(@template_module_path, output_file, template_data)
  end

  defp do_schema(template_data) do
    output_file =
      "#{@schema_output_path}/#{template_data.lower_section}/#{template_data.lower_name}_command.json"

    Mix.Generator.copy_template(@template_schema_path, output_file, template_data)
  end
end
