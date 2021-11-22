defmodule Utils.Validators do
  def is_number(x) do
    case Integer.parse(x) do
      {_, ""} -> true
      _ -> false
    end
  end
end
