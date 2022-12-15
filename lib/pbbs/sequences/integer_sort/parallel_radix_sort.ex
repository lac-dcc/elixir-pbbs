# Description: https://www.cs.cmu.edu/~pbbs/benchmarks/integerSort.html

defmodule PBBS.Sequences.IntegerSort.Parallel do

  def radix_sort(list, p) do
    max = abs(Enum.max(list))
    max_length = digits(max)

    :ets.new(:IS, [:public, :named_table])
    :ets.insert(:IS, {:data, list})

    result =
      0..(p - 1)
      |> Enum.map(fn i ->
        Task.async(fn ->
          data = Keyword.get(:ets.lookup(:IS, :data), :data)

          Enum.drop(data, i)
          |> Enum.take_every(p)
          |> Enum.map(fn item -> String.pad_leading(Integer.to_string(item), max_length, "0") end)
          |> radix_sort(10, 0, max_length)
          |> :lists.append()
          |> Enum.map(fn item -> String.to_integer(item) end)
        end)
      end)
      |> Task.await_many(:infinity)
      |> :lists.merge()

    :ets.delete(:IS)
    result
  end

  def radix_sort(list, _, digit, rank) when digit == rank, do: [list]

  def radix_sort(list, base, digit, rank) do
    buckets =
      get_buckets(list, base, digit)
      |> Tuple.to_list()
      |> Enum.filter(fn bucket -> bucket != [] end)

    Enum.map(buckets, fn bucket ->
      radix_sort(bucket, base, digit + 1, rank)
      |> :lists.append()
    end)
  end

  defp get_buckets(list, base, digit) do
    empty_buckets = List.to_tuple(for _ <- 0..(base - 1), do: [])

    Enum.reduce(list, empty_buckets, fn x, acc ->
      i = String.to_integer(String.at(x, digit))
      put_elem(acc, i, [x | elem(acc, i)])
    end)
  end

  defp digits(num) do
    if num > 9 do
      1 + digits(div(num, 10))
    else
      1
    end
  end

end
