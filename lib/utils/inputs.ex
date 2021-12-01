defmodule Utils.Inputs do
  def get_sequence([n]) when is_binary(n) do
    if Utils.Validators.is_number(n) do
      Utils.Generators.random_sequence(String.to_integer(n))
    else
      Utils.Files.get_pbbs_sequence(n)
    end
  end

  def get_sequence([m, n]) when is_binary(m) and is_binary(n) do
    if Utils.Validators.is_number(m) and Utils.Validators.is_number(n) do
      Utils.Generators.random_sequence(String.to_integer(m), String.to_integer(n))
    else
      []
    end
  end
end
