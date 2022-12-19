defmodule PBBS.Sequences.IntegerSort.Sequential do
  def radix_sort([], _), do: []

  def radix_sort(list) do
    max = abs(Enum.max_by(list, &abs(&1)))
    sorted_list = radix_sort(list, max, 1)

    {negative, positive} = Enum.split_with(sorted_list, &(&1 < 0))
    Enum.reverse(negative, positive)
  end

  defp radix_sort(list, max, m) when max < m, do: list

  defp radix_sort(list, max, m) do
    buckets = List.to_tuple(for _ <- 0..9, do: [])

    buckets =
      Enum.reduce(list, buckets, fn item, acc ->
        index = abs(item) |> div(m) |> rem(10)
        put_elem(acc, index, [item | elem(acc, index)])
      end)

    sorted_by_digit = Enum.reduce(9..0, [], fn i, acc -> Enum.reverse(elem(buckets, i), acc) end)

    radix_sort(sorted_by_digit, max, m * 10)
  end
end
