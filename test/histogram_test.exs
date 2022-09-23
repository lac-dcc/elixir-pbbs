defmodule HistogramTest do
  use ExUnit.Case

  @tag skip: true
  test "histogram is generated correctly" do
    input = [3,3,3,3,3,3,2,2,2,1,1,1,1,1,1,0,0,0]
    assert Sequences.Histogram.histogram(input, 4) == [3,6,3,6]
  end

  @tag skip: true
  test "histogram is generated correctly for list with a single value" do
    input = List.duplicate(5, 40)
    assert Sequences.Histogram.histogram(input, 6) == [0,0,0,0,0,40]
  end

  @tag skip: true
  test "empty list leads to empty histogram" do
    assert Sequences.Histogram.histogram([], 0) == []
  end

  @tag skip: true
  test "parallel works" do
    input = [3,3,3,3,3,3,2,2,2,1,1,1,1,1,1,0,0,0]
    assert Sequences.Histogram.Parallel.histogram(input, 4) == [3,6,3,6]
  end

  @tag skip: true
  test "large input, single value" do
    size = 10000000
    buckets = 10
    p = 6

    input = List.duplicate(0, size)
    tuples_input = Tuple.duplicate(input, p)
    input = Enum.concat(List.duplicate(input, p))

    {time, res} = Benchmark.measure(fn -> Sequences.Histogram.Parallel.histogram(input, buckets) end)
    IO.puts("Parallel time: #{time/1000}ms")
    assert res == [size,0,0,0,0,0,0,0,0,0]

    {time, res} = Benchmark.measure(fn -> Sequences.Histogram.histogram(input, buckets) end)
    IO.puts("Sequential time: #{time/1000}ms")
    assert res == [size,0,0,0,0,0,0,0,0,0]

    {time, res} = Benchmark.measure(fn -> Sequences.Histogram.Parallel.DivideAndConquer.histogram(input, buckets) end)
    IO.puts("Parallel divide and conquer time: #{time/1000}ms")
    assert res == [size,0,0,0,0,0,0,0,0,0]

    {time, res} = Benchmark.measure(fn -> Sequences.Histogram.Parallel.DivideAndConquer.Tuples.histogram(tuples_input, buckets) end)
    IO.puts("Parallel tuples time (varied): #{time/1000}ms")
    assert res == [size,0,0,0,0,0,0,0,0,0]
  end

  test "large input, varied values" do
    size = 100000
    buckets = 10
    p = 6

    input = List.duplicate(Enum.to_list(0..9), size)
    |> Enum.flat_map(&Function.identity/1)

    tuples_input = Tuple.duplicate(input, p)

    input = Enum.concat(List.duplicate(input, p))

    {time, res} = Benchmark.measure(fn -> Sequences.Histogram.Parallel.histogram(input, buckets) end)
    IO.puts("Parallel time (varied): #{time/1000}ms")
    assert res == List.duplicate(p * size, buckets)

    {time, res} = Benchmark.measure(fn -> Sequences.Histogram.histogram(input, buckets) end)
    IO.puts("Sequential time (varied): #{time/1000}ms")
    assert res == List.duplicate(p * size, buckets)

    {time, res} = Benchmark.measure(fn -> Sequences.Histogram.Parallel.DivideAndConquer.histogram(input, buckets) end)
    IO.puts("Parallel divide and conquer time (varied): #{time/1000}ms")
    assert res == List.duplicate(p * size, buckets)

    {time, res} = Benchmark.measure(fn -> Sequences.Histogram.Parallel.DivideAndConquer.Tuples.histogram(tuples_input, buckets) end)
    IO.puts("Parallel tuples time (varied): #{time/1000}ms")
    assert res == List.duplicate(p * size, buckets)
  end

  @tag skip: true
  test "divide and conquer works" do
    input = [3,3,3,3,3,3,2,2,2,1,1,1,1,1,1,0,0,0]
    assert Sequences.Histogram.Parallel.DivideAndConquer.histogram(input, 4) == [3,6,3,6]
  end
end
