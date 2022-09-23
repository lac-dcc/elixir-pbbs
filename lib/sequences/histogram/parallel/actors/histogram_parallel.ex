defmodule Sequences.Histogram.Parallel do
  def histogram(nums, buckets) do
    counters = Enum.map(0..buckets, fn i ->
      Sequences.Histogram.Parallel.Counter.start(i)
    end)
    |> Enum.with_index
    |> Map.new(fn {k, v} -> {v, k} end)

    Enum.each(nums, fn num ->
      send(counters[num], {:increment})
    end)

    tasks = Enum.map(counters, fn {_index, counter_pid} ->
      Task.async(fn ->
        send(counter_pid, {:get, self()})
        receive do
          {id, counts} ->
            {id, counts}
        end
      end)
    end)

    results = Task.await_many(tasks)
    |> Map.new

    result = List.duplicate(0, buckets)

    Enum.reduce(results, result, fn (el, acc) ->
        List.update_at(acc, elem(el, 0), fn _val -> Map.get(results, elem(el, 0), 0) end)
    end)
  end
end
