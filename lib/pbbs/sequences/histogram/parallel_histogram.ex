defmodule PBBS.Sequences.Histogram.Parallel do

  def histogram(nums, buckets, p) do
    chunk_size = 20000

    map = Stream.chunk_every(nums, chunk_size)
    |> Task.async_stream(
      fn elements ->
        Enum.frequencies(elements)
      end,
      max_parallelism: p - 1,
      ordered: false,
      timeout: :infinity
    )
    |> Stream.map(fn {:ok, v} -> v end)
    |> Enum.reduce(%{}, fn (res, acc) ->
      Map.merge(res, acc, fn (_key, v1, v2) -> v1 + v2 end)
    end)

    Enum.map(0..buckets, fn bucket ->
      Map.get(map, bucket, 0)
    end)
  end
end
