defmodule Sequences.RemoveDuplicates.Parallel.DivideAndConquer do
  def remove_duplicates(nums, p) do
    :ets.new(:ddup, [:public, :named_table])
    :ets.insert(:ddup, {:data, nums})

    ret=(0..p-1)
    |> Enum.map(fn i ->
      Task.async(fn ->
        input = Keyword.get(:ets.lookup(:ddup, :data), :data)
        Enum.drop(input, i)
        |> Enum.take_every(p)
        |> MapSet.new
      end)
    end)
    |> Task.await_many
    |> Enum.reduce(MapSet.new(), fn (res, acc) ->
      MapSet.union(res, acc)
    end)

    :ets.delete(:ddup)

    Enum.to_list(ret)
  end
end
