defmodule PBBS.Sequences.Histogram.Sequential do
  def histogram(nums, buckets) do
    frequencies(nums, buckets)
  end

  def frequencies(nums, buckets) do
    map = Enum.frequencies(nums)
    result = List.duplicate(0, buckets)
    |> Enum.with_index
    |> Enum.map(fn ({k, v}) -> ({v, k}) end)
    |> Map.new

    Map.merge(result, map)
    |> Enum.to_list
    |> Enum.map(fn ({_k, v}) -> v end)
  end
end
