# Used only in Sample Sort
defmodule Utils.InsertionSort do
  def run(list) when is_list(list), do: run(list, [])

  def run([], sorted), do: sorted
  def run([h | t], sorted), do: run(t, insert(h, sorted))

  defp insert(x, []), do: [x]
  defp insert(x, sorted) when x < hd(sorted), do: [x | sorted]
  defp insert(x, [h | t]), do: [h | insert(x, t)]
end
