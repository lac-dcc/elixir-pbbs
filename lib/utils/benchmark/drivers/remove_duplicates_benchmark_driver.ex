defmodule Utils.RemoveDuplicatesBenchmarkDriver do

  def run_benchmark() do
    dense_buckets = 1000
    dense_list = Utils.Generators.random_sequence(dense_buckets, 1_000_000)

    sparse_buckets = 500_000
    sparse_list = Utils.Generators.random_sequence(sparse_buckets, 1_000_000)

    plist = [2, 4, 6, 12, 24, 32, 40]

    impl_map = Enum.flat_map(plist, fn p ->
      [
        {"parallel;p=#{p};sparse_list", fn () -> Sequences.RemoveDuplicates.Parallel.DivideAndConquer.remove_duplicates(sparse_list, p) end},
        {"parallel;p=#{p};dense_list", fn () -> Sequences.RemoveDuplicates.Parallel.DivideAndConquer.remove_duplicates(dense_list, p) end},
      ]
    end)
    |> Map.new()
    |> Map.put("serial;sparse_list", fn () -> Sequences.RemoveDuplicates.remove_duplicates(sparse_list) end)
    |> Map.put("serial;dense_list", fn () -> Sequences.RemoveDuplicates.remove_duplicates(dense_list) end)

    Benchee.run(
      impl_map,
      time: 60,
      formatters: [
        {Benchee.Formatters.CSV, file: "output_ddup.csv"}
      ]
    )
  end
end
