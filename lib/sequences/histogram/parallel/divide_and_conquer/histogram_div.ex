defmodule Sequences.Histogram.Parallel.DivideAndConquer do

  def histogram(nums, buckets, p) do
    :ets.new(:histogram, [:public, :named_table])
    :ets.insert(:histogram, {:data, nums})

    tasks = (0..p-1)
    |> Enum.map(fn i ->
      Task.async(fn ->
        Enum.drop(Keyword.get(:ets.lookup(:histogram, :data), :data), i)
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

    :ets.delete(:histogram)

    Map.merge(result, map)
    |> Enum.to_list
    |> Enum.map(fn ({_k, v}) -> v end)
  end
end
