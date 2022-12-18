defmodule PBBS.Sequences.Histogram.Sequential do
  def histogram(nums, buckets) do
    map = Enum.frequencies(nums)

    Enum.map(0..buckets, fn bucket ->
      Map.get(map, bucket, 0)
    end)
  end

end
