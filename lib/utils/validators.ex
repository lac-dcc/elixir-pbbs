defmodule Utils.Validators do
  def is_string_a_number(string) do
    case Integer.parse(string) do
      {_, ""} -> true
      _ -> false
    end
  end

  def is_valid_pbbs_file(input) do
    # todo
    true
  end
end
