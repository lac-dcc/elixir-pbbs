defmodule WordCountTest do
  use ExUnit.Case

  test "sequential implementation removes duplicates correctly" do
    input = [0,0,0,1,2,3,1,2,3,4,5,6,4,5,6,7,7,7,8,8,8,9,9,9]
    assert Sequences.RemoveDuplicates.remove_duplicates(input) == [0,1,2,3,4,5,6,7,8,9]
  end

  test "parallel implementation removes duplicates correctly" do
    input = [0,0,0,1,2,3,1,2,3,4,5,6,4,5,6,7,7,7,8,8,8,9,9,9]
    assert Sequences.RemoveDuplicates.Parallel.DivideAndConquer.remove_duplicates(input, 6) == [0,1,2,3,4,5,6,7,8,9]
  end
end
