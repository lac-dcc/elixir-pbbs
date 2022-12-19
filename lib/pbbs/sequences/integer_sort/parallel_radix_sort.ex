# Description: https://www.cs.cmu.edu/~pbbs/benchmarks/integerSort.html

defmodule PBBS.Sequences.IntegerSort.Parallel do
  def radix_sort(list, p) do
    chunk_size = 20000

    Stream.chunk_every(list, chunk_size)
    |> Task.async_stream(
      fn elements ->
        PBBS.Sequences.IntegerSort.Sequential.radix_sort(elements)
      end,
      max_parallelism: p - 1,
      ordered: false,
      timeout: :infinity
    )
    |> Stream.map(fn {:ok, v} -> v end)
    |> Enum.reduce([], fn item, acc ->
      [item | acc]
    end)
    |> :lists.merge()
  end
end
