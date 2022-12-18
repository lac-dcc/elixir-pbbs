# Description: https://www.cs.cmu.edu/~pbbs/benchmarks/integerSort.html

defmodule PBBS.Sequences.IntegerSort.Parallel do
  def radix_sort(list, p) do
    chunk_size = 20000

    Stream.chunk_every(list, chunk_size)
    |> Task.async_stream(
      fn elements ->
        radix_sort_internal(elements)
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

  def radix_sort_internal([], _), do: []

  def radix_sort_internal(list) do
    max = abs(Enum.max_by(list, &abs(&1)))
    sorted_list = radix_sort_internal(list, max, 1)

    {negative, positive} = Enum.split_with(sorted_list, &(&1 < 0))
    Enum.reverse(negative, positive)
  end

  defp radix_sort_internal(list, max, m) when max < m, do: list

  defp radix_sort_internal(list, max, m) do
    buckets = List.to_tuple(for _ <- 0..9, do: [])

    buckets =
      Enum.reduce(list, buckets, fn item, acc ->
        index = abs(item) |> div(m) |> rem(10)
        put_elem(acc, index, [item | elem(acc, index)])
      end)

    sorted_by_digit = Enum.reduce(9..0, [], fn i, acc -> Enum.reverse(elem(buckets, i), acc) end)

    radix_sort_internal(sorted_by_digit, max, m * 10)
  end
end
