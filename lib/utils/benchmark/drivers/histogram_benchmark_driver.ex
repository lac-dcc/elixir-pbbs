defmodule Utils.HistogramBenchmarkDriver do

  def run_benchmark(implementations, processors) do
    IO.inspect(implementations)
    buckets = 1000
    size = 300_000
    data = Utils.Generators.random_sequence(10, size)

    impl_map = %{
      "serial" => fn -> Sequences.Histogram.histogram(data, buckets) end,
      "actors" => fn -> Sequences.Histogram.Parallel.histogram(data, buckets) end,
      "dc" => fn -> Sequences.Histogram.Parallel.DivideAndConquer.histogram(data, buckets, processors) end,
      #"dc_tuples" => fn -> Sequences.Histogram.Parallel.DivideAndConquer.Tuples.histogram(data, buckets) end,
      # TODO: handle implementations that deviate from the default signature (introduce new level of abstraction?)
    }

    to_run = Enum.filter(impl_map, fn ({key, _value}) ->
      IO.puts(key)
      MapSet.member?(implementations, key)
    end)

    Benchee.run(to_run)
  end
end
