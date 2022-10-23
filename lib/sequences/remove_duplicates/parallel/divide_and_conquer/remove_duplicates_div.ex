defmodule Sequences.RemoveDuplicates.Parallel.DivideAndConquer do
  def remove_duplicates(nums, p) do
    ret=(0..p-1)
    |> Enum.map(fn i ->
      Task.async(fn ->
        Enum.drop(nums, i)
        |> Enum.take_every(p)
        |> MapSet.new
      end)
    end)
    |> Task.await_many
    |> Enum.reduce(MapSet.new(), fn (res, acc) ->
      MapSet.union(res, acc)
    end)

    Enum.to_list(ret)
  end
end
