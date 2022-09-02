defmodule HistogramTest do
  use ExUnit.Case

  test "histogram is generated correctly" do
    input = [3,3,3,3,3,3,2,2,2,1,1,1,1,1,1,0,0,0]
    assert Sequences.Histogram.histogram(input, 4) == [3,6,3,6]
  end

  test "histogram is generated correctly for list with a single value" do
    input = List.duplicate(5, 40)
    assert Sequences.Histogram.histogram(input, 6) == [0,0,0,0,0,40]
  end

  test "empty list leads to empty histogram" do
    assert Sequences.Histogram.histogram([], 0) == []
  end

  test "parallel works" do
    input = [3,3,3,3,3,3,2,2,2,1,1,1,1,1,1,0,0,0]
    assert Sequences.Histogram.Parallel.histogram(input, 4) == [3,6,3,6]
  end

  test "large input, single value" do
    size = 100000000
    buckets = 10

    input = List.duplicate(0, size)
    {time, res} = Benchmark.measure(fn -> Sequences.Histogram.Parallel.histogram(input, buckets) end)
    IO.puts("Parallel time: #{time/1000}ms")
    assert res == [size,0,0,0,0,0,0,0,0,0]

    {time, res} = Benchmark.measure(fn -> Sequences.Histogram.histogram(input, buckets) end)
    IO.puts("Sequential time: #{time/1000}ms")
    assert res == [size,0,0,0,0,0,0,0,0,0]
  end

  test "large input, varied values" do
    size = 1000000
    buckets = 10

    input = Enum.flat_map(List.duplicate(Enum.to_list(0..9), size), fn k -> k end)

    {time, res} = Benchmark.measure(fn -> Sequences.Histogram.Parallel.histogram(input, buckets) end)
    IO.puts("Parallel time (varied): #{time/1000}ms")
    assert res == [size, size, size, size, size, size, size, size, size, size]

    {time, res} = Benchmark.measure(fn -> Sequences.Histogram.histogram(input, buckets) end)
    IO.puts("Sequential time (varied): #{time/1000}ms")
    assert res == [size, size, size, size, size, size, size, size, size, size]
  end
end
