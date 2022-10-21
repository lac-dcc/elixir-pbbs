defmodule Utils.WordCountBenchmarkDriver do

  def run_benchmark(implementations, processors) do
    Strings.WordCount.Parallel
    IO.inspect(implementations)

    impl_map = %{
      "serial" => fn ({data, _p}) -> Strings.WordCount.word_count(data) end,
      "parallel" => fn ({data, p}) -> Strings.WordCount.Parallel.word_count(data, p) end,
    }

    {:ok, text} = File.read("text.txt")

    inputs = %{
      "text, p=1" => {text, 1},
      "text, p=2" => {text, 2},
      "text, p=4" => {text, 4},
      "text, p=6" => {text, 6},
      "text, p=12" => {text, 12},
      "text, p=24" => {text, 24},
      "text, p=32" => {text, 32},
      "text, p=40" => {text, 40},
    }

    to_run = Enum.filter(impl_map, fn ({key, _value}) ->
      IO.puts(key)
      MapSet.member?(implementations, key)
    end)

    Benchee.run(
      to_run,
      time: 30,
      inputs: inputs,
      formatters: [
        {Benchee.Formatters.CSV, file: "output_wc.csv"}
      ]
    )
  end
end
