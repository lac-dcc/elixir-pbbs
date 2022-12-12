defmodule Mix.Tasks.Benchmark do
  @moduledoc """
    Task to benchmark different implementations of an algorithm.
    The different implementations will be run and the running times
    will be reported in stdout.

    Parameters:
    --algorithm (-a) - the algorithm to benchmark (required)
  """

  use Mix.Task

  @impl Mix.Task
  def run(args) do
    parsed_args = OptionParser.parse(args, aliases: [
      a: :algorithm,
    ], strict: [
      algorithm: :string,
    ])
    parsed = elem(parsed_args, 0)

    algorithm = Keyword.get(parsed, :algorithm)

    if algorithm == nil do
      usage()
    else
      execute(algorithm)
    end
  end

  defp execute(algorithm) do
    drivers = %{
      "histogram" => &Utils.HistogramBenchmarkDriver.run_benchmark/0,
      "word_count" => &Utils.WordCountBenchmarkDriver.run_benchmark/0,
      "remove_duplicates" => &Utils.RemoveDuplicatesBenchmarkDriver.run_benchmark/0,
      "ray_cast" => &Utils.RayCastBenchmarkDriver.run_benchmark/0,
      "convex_hull" => &Utils.ConvexHullBenchmarkDriver.run_benchmark/0,
      "suffix_array" => &Utils.SuffixArrayBenchmarkDriver.run_benchmark/0,
      "integer_sort" => &Utils.IntegerSortBenchmarkDriver.run_benchmark/0,
      "comparison_sort" => &Utils.ComparisonSortBenchmarkDriver.run_benchmark/0,
    }

    driver = drivers[algorithm]
    if driver != nil do
      driver.()
    else
      IO.puts("Unknown algorithm: #{algorithm}")
    end
  end

  defp usage() do
    IO.puts(Mix.Task.moduledoc(Mix.Tasks.Benchmark))
  end
end
