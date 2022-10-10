defmodule Sequences.RemoveDuplicates do
  def remove_duplicates(nums) do
    Enum.uniq(nums)
  end
end
