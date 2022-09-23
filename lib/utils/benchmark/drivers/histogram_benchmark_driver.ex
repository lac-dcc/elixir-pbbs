defmodule Utils.HistogramBenchmarkDriver do
  def run_benchmark(implementations, processors) do
    impl_map = %{
      "serial" => fn (data, buckets) -> Sequences.Histogram.histogram(data, buckets) end,
      "actors" => fn (data, buckets) -> Sequences.Histogram.Parallel.histogram(data, buckets) end,
      "dc" => fn (data, buckets) -> Sequences.Histogram.Parallel.DivideAndConquer.histogram(data, buckets, processors) end,
      #"dc_tuples" => &Sequences.Histogram.Parallel.DivideAndConquer.Tuples.histogram/2
      # TODO: handle implementations that deviate from the default signature (introduce new level of abstraction?)
    }

    times = Enum.map(implementations, fn impl ->
      {impl, exec_benchmark(impl_map[impl])}
    end)

    IO.inspect(times)
  end

  defp exec_benchmark(fun) do
    buckets = 10
    size = 30_000_000

    input = Utils.Generators.random_sequence(10, size)

    {time, _ret} = Benchmark.measure(fn -> fun.(input, buckets) end)
    time / 1000 # ms
  end
end
