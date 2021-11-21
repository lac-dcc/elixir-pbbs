defmodule Utils.Generators do
  def random_sequence(m, n) when is_integer(m) and is_integer(n) do
    1..n |> Enum.map(fn _ ->
      Enum.random(0..m)
    end)
  end

  def random_sequence(n) when is_integer(n) do
    1..n |> Enum.map(fn _ ->
      Enum.random(0..n)
    end)
  end
end
