defmodule Utils.ComparisonSortBenchmarkDriver do

  def run_benchmark() do
    dense_list = Utils.Generators.random_sequence(50, 1_000_000)
    sparse_list = Utils.Generators.random_sequence(1_000_000)

    p = System.schedulers_online()

    impl_map = Map.new()
    |> Map.put("serial;dense_list", fn () -> Enum.sort(dense_list) end)
    |> Map.put("serial;sparse_list", fn () -> Enum.sort(sparse_list) end)
    |> Map.put("parallel;p=#{p};dense_list", fn () -> Sequences.SampleSort.sample_sort(256, dense_list) end)
    |> Map.put("parallel;p=#{p};sparse_list", fn () -> Sequences.SampleSort.sample_sort(256, sparse_list) end)
    |> Map.new()

    Benchee.run(
      impl_map,
      time: 60,
      formatters: [
        {Benchee.Formatters.CSV, file: "output_comparison_sort.csv"}
      ]
    )
  end
end
