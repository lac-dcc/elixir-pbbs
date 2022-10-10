defmodule Sequences.RemoveDuplicates.Parallel.DivideAndConquer do
  def remove_duplicates(nums, p) do
    size = div(length(nums), p)

    0..p
    |> Enum.map(fn idx -> (idx*size) end)
    |> Enum.map(fn start ->
      Task.async(fn ->
        Enum.slice(nums, start, size)
        |> Enum.uniq
      end)
    end)
    |> Task.await_many
    |> Enum.reduce([], fn (res, acc) ->
      Enum.uniq(acc ++ res)
    end)
  end
end
