defmodule Utils.Lists do
  # Does need to be concurrent?
  def max(list) when is_list(list), do: maximum(list)

  defp maximum([]), do: nil
  defp maximum([head | tail]), do: maximum(head, tail)
  defp maximum(value, []), do: value
  defp maximum(value, [head | tail]) do
    if value > head do
      maximum(value, tail)
    else
      maximum(head, tail)
    end
  end
end
