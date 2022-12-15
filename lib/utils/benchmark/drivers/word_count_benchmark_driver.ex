defmodule Utils.Benchmark.Drivers.WordCount do

  def run_benchmark() do
    {:ok, natural_text} = File.read("data/inputs/word_count/text.txt")
    {:ok, dense_text} = File.read("data/inputs/word_count/dense_text.txt")

    plist = [2, 4, 6, 12, 24, 32, 40]

    impl_map = Enum.flat_map(plist, fn p ->
      [
        {"parallel;p=#{p};natural_text", fn () -> PBBS.Strings.WordCount.Parallel.word_count(natural_text, p) end},
        {"parallel;p=#{p};dense_text", fn () -> PBBS.Strings.WordCount.Parallel.word_count(dense_text, p) end},
      ]
    end)
    |> Map.new()
    |> Map.put("serial;natural_text", fn () -> PBBS.Strings.WordCount.Sequential.word_count(natural_text) end)
    |> Map.put("serial;dense_text", fn () -> PBBS.Strings.WordCount.Sequential.word_count(dense_text) end)

    Benchee.run(
      impl_map,
      time: 60,
      formatters: [
        {Benchee.Formatters.CSV, file: "output_wc.csv"}
      ]
    )
  end
end
