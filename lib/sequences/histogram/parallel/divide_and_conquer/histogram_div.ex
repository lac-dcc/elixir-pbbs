defmodule Sequences.Histogram.Parallel.DivideAndConquer do

  def histogram(nums, buckets, p) do
    result_list = List.duplicate(0, buckets)
    (0..p-1)
    |> Enum.map(fn i ->
      Task.async(fn ->
        Enum.drop(nums, i)
        |> Enum.take_every(p)
        |> frequencies
      end)
    end)
    |> Task.await_many
    |> Enum.reduce(%{}, fn (res, acc) ->
      Map.merge(res, acc, fn (_key, v1, v2) -> v1 + v2 end)
    end)
    |> Enum.reduce(result_list, fn (el, acc) ->
      List.update_at(acc, elem(el, 0), fn _val -> elem(el, 1) end)
    end)
  end

  def frequencies(nums) do
    Enum.reduce(nums, %{}, fn (el, acc) ->
      Map.update(acc, el, 1, fn v -> v+1 end)
    end)
  end
end
