defmodule Sequences.RemoveDuplicates do
  def remove_duplicates(nums) do
    MapSet.new(nums)
    |> Enum.to_list
  end
end
