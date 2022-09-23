defmodule Mix.Tasks.Benchmark do
  @moduledoc """
    Task to benchmark different implementations of an algorithm.
    The different implementations will be run and the running times
    will be reported in stdout.

    Parameters:
    --algorithm (-a) - the algorithm to benchmark (required)
    --impl (-i) - the implementations that must be included in the benchmark. Default: all available implementations.
    --processors (-p) - the number of processors to use. This parameter will be forwarded to the algorithms
      whose level of parallelism is configurable. Default: System.schedulers
  """

  use Mix.Task

  @impl Mix.Task
  def run(args) do
    parsed_args = OptionParser.parse(args, aliases: [
      a: :algorithm,
      i: :impl,
      p: :processors
    ], strict: [
      algorithm: :string,
      impl: :keep,
      processors: :integer
    ])
    parsed = elem(parsed_args, 0)

    processors = Keyword.get(parsed, :processors, System.schedulers())
    algorithm = Keyword.get(parsed, :algorithm)
    implementations = Keyword.get_values(parsed, :impl)

    if algorithm == nil do
      usage()
    else
      execute(algorithm, implementations, processors)
    end
  end

  defp execute(algorithm, implementations, processors) do
    impl_map = %{
      "histogram" => MapSet.new([
        "serial",
        "actors",
        "dc",
        #"dc_tuples"
      ]),
    }
    drivers = %{
      "histogram" => &Utils.HistogramBenchmarkDriver.run_benchmark/2,
    }

    available_implementations = impl_map[algorithm]
    if implementations == [] do
      implementations = available_implementations
      drivers[algorithm].(implementations, processors)
    else
      implementations = MapSet.intersection(MapSet.new(implementations), available_implementations)
      drivers[algorithm].(implementations, processors)
    end
  end

  defp usage() do
    IO.puts(Mix.Task.moduledoc(Mix.Tasks.Benchmark))
  end
end
