defmodule Sequences.Histogram do
  def histogram(nums, buckets) do
    frequencies(nums, buckets)
  end

  def frequencies(nums, buckets) do
    map = Enum.frequencies(nums)
    result = List.duplicate(0, buckets)
    Enum.reduce(map, result, fn (el, acc) ->
      List.update_at(acc, elem(el, 0), fn _val -> Map.get(map, elem(el, 0), 0) end)
    end)
  end
end
