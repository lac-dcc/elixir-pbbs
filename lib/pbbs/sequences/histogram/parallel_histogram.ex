defmodule PBBS.Sequences.Histogram.Parallel do

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

    result = Tuple.duplicate(0, buckets)

    map = Task.await_many(tasks)
    |> Enum.reduce(%{}, fn (res, acc) ->
      Map.merge(res, acc, fn (_key, v1, v2) -> v1 + v2 end)
    end)

    :ets.delete(:histogram)

    result = Enum.reduce(map, result, fn {num, frequency}, acc ->
      put_elem(acc, num, frequency)
    end)

    Tuple.to_list(result)
  end
end
