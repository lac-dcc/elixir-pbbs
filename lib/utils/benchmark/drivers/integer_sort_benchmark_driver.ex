defmodule Utils.IntegerSortBenchmarkDriver do

  def run_benchmark() do
    dense_list = Utils.Generators.random_sequence(50, 1_000_000)
    sparse_list = Utils.Generators.random_sequence(1_000_000)

    p = System.schedulers_online()

    impl_map = Map.new()
    |> Map.put("serial;dense_list", fn () -> Enum.sort(dense_list) end)
    |> Map.put("serial;sparse_list", fn () -> Enum.sort(sparse_list) end)
    |> Map.put("parallel;p=#{p};dense_list", fn () -> Sequences.RadixSort.radix_sort(dense_list) end)
    |> Map.put("parallel;p=#{p};sparse_list", fn () -> Sequences.RadixSort.radix_sort(sparse_list) end)
    |> Map.new()

    Benchee.run(
      impl_map,
      time: 60,
      formatters: [
        {Benchee.Formatters.CSV, file: "output_integer_sort.csv"}
      ]
    )
  end
end
