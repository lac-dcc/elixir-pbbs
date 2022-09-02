defmodule Sequences.Histogram.Parallel do
  def histogram(nums, buckets) do
    {time, counters} = Benchmark.measure(fn -> Enum.map(0..buckets, fn i ->
      Sequences.Histogram.Parallel.Counter.start(i)
    end)
    |> Enum.with_index
    |> Map.new(fn {k, v} -> {v, k} end)
    end)

    IO.puts("Time to create counters: #{time/1000}ms")

    {time, _ok} = Benchmark.measure(fn -> Enum.each(nums, fn num ->
      send(counters[num], {:increment})
    end) end)

    IO.puts("Time to send messages: #{time/1000}ms")

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

    IO.puts("Done waiting")

    result = List.duplicate(0, buckets)

    {time, res} = Benchmark.measure(fn -> Enum.reduce(results, result, fn (el, acc) ->
        List.update_at(acc, elem(el, 0), fn _val -> Map.get(results, elem(el, 0), 0) end)
      end)
    end)
    IO.inspect(time)

    res
  end
end
