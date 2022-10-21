defmodule Utils.RemoveDuplicatesBenchmarkDriver do

  def run_benchmark(implementations, processors) do
    IO.inspect(implementations)

    impl_map = %{
      "serial" => fn ({data, _p}) -> Sequences.RemoveDuplicates.remove_duplicates(data) end,
      "parallel" => fn ({data, p}) -> Sequences.RemoveDuplicates.Parallel.DivideAndConquer.remove_duplicates(data, p) end,
      "fast_parallel" => fn ({data, p}) -> Sequences.RemoveDuplicates.Parallel.DivideAndConquer.remove_duplicates2(data, p) end,
    }

    large_list = Utils.Generators.random_sequence(1_000_000)

    inputs = %{
      "large list, p=1" => {large_list, 1},
      "large list, p=2" => {large_list, 2},
      "large list, p=4" => {large_list, 4},
      "large list, p=6" => {large_list, 6},
      "large list, p=12" => {large_list, 12},
      "large list, p=24" => {large_list, 24},
      "large list, p=32" => {large_list, 32},
      "large list, p=40" => {large_list, 40},
    }

    to_run = Enum.filter(impl_map, fn ({key, _value}) ->
      IO.puts(key)
      MapSet.member?(implementations, key)
    end)

    Benchee.run(
      to_run,
      inputs: inputs,
      formatters: [
        {Benchee.Formatters.CSV, file: "output_ddup.csv"}
      ]
    )
  end
end
