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
    input = [3,3,3,3,3,3,2,2,2,1,1,1,1,1,1,0,0,0,0]
    assert Sequences.Histogram.Parallel.histogram(input, 4) == [4,6,3,6]
  end

  test "divide and conquer works" do
    input = [3,3,3,3,3,3,2,2,2,1,1,1,1,1,1,0,0,0]
    assert Sequences.Histogram.Parallel.DivideAndConquer.histogram(input, 4, 6) == [3,6,3,6]
  end
end
