defmodule Sequences.Histogram.Parallel.DivideAndConquer do

  def histogram(nums, buckets, p) do
    tasks = (0..p-1)
    |> Enum.map(fn i ->
      Task.async(fn ->
        Enum.drop(nums, i)
        |> Enum.take_every(p)
        |> Enum.frequencies
      end)
    end)

    result = List.duplicate(0, buckets)
    |> Enum.with_index
    |> Enum.map(fn ({k, v}) -> ({v, k}) end)
    |> Map.new

    map = Task.await_many(tasks)
    |> Enum.reduce(%{}, fn (res, acc) ->
      Map.merge(res, acc, fn (_key, v1, v2) -> v1 + v2 end)
    end)

    Map.merge(result, map)
    |> Enum.to_list
    |> Enum.map(fn ({_k, v}) -> v end)
  end
end
