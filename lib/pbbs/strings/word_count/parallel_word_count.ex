defmodule PBBS.Strings.WordCount.Parallel do
  def word_count(string, p) do
    workload = 1000

    String.splitter(string, :binary.compile_pattern([" ", "\n", "\t", "\f", "\r"]))
    |> Stream.chunk_every(workload)
    |> Task.async_stream(__MODULE__, :analyze, [], max_concurrency: p, ordered: false)
    |> Stream.map(fn {:ok, v} -> v end)
    |> Enum.reduce(%{}, fn elem, acc ->
      Map.merge(elem, acc, fn _, a, b -> a + b end)
    end)
  end

  def analyze(input) do
    input
    |> Enum.flat_map(fn s -> String.split(s, ~r/[^A-z]+/) end)
    |> Enum.filter(fn s -> s != "" end)
    |> Enum.map(&String.downcase/1)
    |> Enum.frequencies()
  end
end
