# Used only in Sample Sort
defmodule Sequences.QuickSort do
  def run(list) when is_list(list), do: run(list)

  defp qsort([]), do: []
  defp qsort([pivot | []]), do: [pivot]

  defp qsort([pivot | tail]) do
    lower = Enum.filter(tail, fn n -> n < pivot end)
    higher = Enum.filter(tail, fn n -> n > pivot end)
    qsort(lower) ++ [pivot] ++ qsort(higher)
  end
end
