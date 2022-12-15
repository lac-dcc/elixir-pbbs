defmodule Utils.Benchmark.Benchmark do
  def measure(function) do
    function
    |> :timer.tc
  end
end
