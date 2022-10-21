defmodule Sequences.RemoveDuplicates.Parallel.DivideAndConquer do
  def remove_duplicates(nums, p) do
    (0..p-1)
    |> Enum.map(fn i ->
      Task.async(fn ->
        Enum.drop(nums, i)
        |> Enum.take_every(p)
        |> Enum.uniq
      end)
    end)
    |> Task.await_many
    |> Enum.reduce([], fn (res, acc) ->
      Enum.uniq(acc ++ res)
    end)
  end
end
