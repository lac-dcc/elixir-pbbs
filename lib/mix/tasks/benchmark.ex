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
      "histogram" => &Utils.Benchmark.Drivers.Histogram.run_benchmark/0,
      "word_count" => &Utils.Benchmark.Drivers.WordCount.run_benchmark/0,
      "remove_duplicates" => &Utils.Benchmark.Drivers.RemoveDuplicates.run_benchmark/0,
      "ray_cast" => &Utils.Benchmark.Drivers.RayCast.run_benchmark/0,
      "convex_hull" => &Utils.Benchmark.Drivers.ConvexHull.run_benchmark/0,
      "suffix_array" => &Utils.Benchmark.Drivers.SuffixArray.run_benchmark/0,
      "integer_sort" => &Utils.Benchmark.Drivers.IntegerSort.run_benchmark/0,
      "comparison_sort" => &Utils.Benchmark.Drivers.ComparisonSort.run_benchmark/0,
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
