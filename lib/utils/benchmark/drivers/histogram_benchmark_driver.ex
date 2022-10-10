defmodule Utils.HistogramBenchmarkDriver do

  def run_benchmark(implementations, processors) do
    IO.inspect(implementations)
    buckets = 1000

    impl_map = %{
      "serial" => fn ({data, _p}) -> Sequences.Histogram.histogram(data, buckets) end,
      "actors" => fn ({data, _p}) -> Sequences.Histogram.Parallel.histogram(data, buckets) end,
      "dc" => fn ({data, p}) -> Sequences.Histogram.Parallel.DivideAndConquer.histogram(data, buckets, p) end,
      # TODO: handle implementations that deviate from the default signature (introduce new level of abstraction?)
    }

    inputs = %{
      "large list, p=1" => {Utils.Generators.random_sequence(buckets, 1_000_000), 1},
      "large list, p=2" => {Utils.Generators.random_sequence(buckets, 1_000_000), 2},
      "large list, p=4" => {Utils.Generators.random_sequence(buckets, 1_000_000), 4},
      "large list, p=6" => {Utils.Generators.random_sequence(buckets, 1_000_000), 6},
      "large list, p=12" => {Utils.Generators.random_sequence(buckets, 1_000_000), 12},
      "large list, p=24" => {Utils.Generators.random_sequence(buckets, 1_000_000), 24},
      "large list, p=32" => {Utils.Generators.random_sequence(buckets, 1_000_000), 32},
      "large list, p=40" => {Utils.Generators.random_sequence(buckets, 1_000_000), 40},
    }

    to_run = Enum.filter(impl_map, fn ({key, _value}) ->
      IO.puts(key)
      MapSet.member?(implementations, key)
    end)

    Benchee.run(
      to_run,
      inputs: inputs,
      formatters: [
        {Benchee.Formatters.CSV, file: "output.csv"}
      ]
    )
  end
end
