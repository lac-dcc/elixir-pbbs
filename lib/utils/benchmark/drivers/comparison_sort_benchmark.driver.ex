defmodule Utils.Benchmark.Drivers.ComparisonSort do

  def run_benchmark() do
    dense_list = Utils.Generators.random_sequence(50, 1_000_000)
    sparse_list = Utils.Generators.random_sequence(1_000_000)

    plist = [2, 4, 6, 12, 24, 32, 40]

    impl_map = Enum.flat_map(plist, fn p ->
      [
        {"parallel;p=#{p};dense_list", fn () -> PBBS.Sequences.ComparisonSort.Parallel.merge_sort(dense_list, p) end},
        {"parallel;p=#{p};sparse_list", fn () -> PBBS.Sequences.ComparisonSort.Parallel.merge_sort(sparse_list, p) end},
      ]
    end)
    |> Map.new()
    |> Map.put("serial;dense_list", fn () -> Enum.sort(dense_list) end)
    |> Map.put("serial;sparse_list", fn () -> Enum.sort(sparse_list) end)

    Benchee.run(
      impl_map,
      time: 60,
      formatters: [
        {Benchee.Formatters.CSV, file: "output_comparison_sort.csv"}
      ]
    )
  end
end
