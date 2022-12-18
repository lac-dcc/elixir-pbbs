defmodule PBBS.Sequences.RemoveDuplicates.Parallel do
  def remove_duplicates(nums, p) do
    chunk_size = 20000

    Stream.chunk_every(nums, chunk_size)
    |> Task.async_stream(
      fn elements ->
        MapSet.new(elements)
      end,
      max_parallelism: p - 1,
      ordered: false,
      timeout: :infinity
    )
    |> Stream.map(fn {:ok, v} -> v end)
    |> Enum.reduce(MapSet.new(), fn res, acc ->
      MapSet.union(res, acc)
    end)
    |> Enum.to_list
  end
end
