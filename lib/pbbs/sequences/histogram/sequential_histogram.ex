defmodule PBBS.Sequences.Histogram.Sequential do
  def histogram(nums, buckets) do
    map = Enum.frequencies(nums)

    result = Tuple.duplicate(0, buckets)

    result = Enum.reduce(map, result, fn {num, frequency}, acc ->
      put_elem(acc, num, frequency)
    end)

    Tuple.to_list(result)
  end
end
