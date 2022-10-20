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

  def remove_duplicates2(nums, p) do
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
