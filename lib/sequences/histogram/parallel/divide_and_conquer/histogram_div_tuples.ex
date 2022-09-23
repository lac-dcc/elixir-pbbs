defmodule Sequences.Histogram.Parallel.DivideAndConquer.Tuples do
  # num_tuples: p tuples of lists, where p is the level of parallelism desired
  # (generally the number of processors of the machine)
  def histogram(nums_tuples, buckets) do
    result_list = List.duplicate(0, buckets)
    Enum.map(0..tuple_size(nums_tuples) - 1, fn i ->
      nums = elem(nums_tuples, i)
      Task.async(fn -> frequencies(nums) end)
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
      old = Map.get(acc, el, 0)
      Map.put(acc, el, old + 1)
    end)
  end
end
