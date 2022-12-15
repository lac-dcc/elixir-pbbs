defmodule PBBS.Sequences.RemoveDuplicates.Sequential do
  def remove_duplicates(nums) do
    MapSet.new(nums)
    |> Enum.to_list
  end
end
