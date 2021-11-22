# Description: https://www.cs.cmu.edu/~pbbs/benchmarks/integerSort.html

defmodule Sequences.RadixSort do
  @p 10 # number of processes, need to be moved to input

  def run([n]) when is_binary(n) do
    if Utils.Validators.is_number(n) do
      run(String.to_integer(n))
    else
      list = Utils.Files.get_pbbs_sequence(n)
      if list != [] do
        radix_sort(list)
      else
        display_error_message()
      end
    end
  end

  def run(n) when is_integer(n) do
    list = Utils.Generators.random_sequence(n)
    radix_sort(list)
  end

  def run([m, n]) when is_binary(m) and is_binary(n) do
    if Utils.Validators.is_number(m) and Utils.Validators.is_number(n) do
      run(String.to_integer(m), String.to_integer(n))
    else
      display_error_message()
    end
  end

  def run(m, n) when is_integer(m) and is_integer(n) do
    list = Utils.Generators.random_sequence(m, n)
    radix_sort(list)
  end

  defp radix_sort(list), do: radix_sort(list, 10)

  defp radix_sort([], _), do: []

  defp radix_sort(list, base) do
    max = abs(Utils.Lists.max(list))
    sorted = radix_sort(list, base, max, 1, @p)
    IO.puts("\nOriginal sequence: ")
    IO.inspect(list, limit: :infinity)
    IO.puts("\nSorted sequence: ")
    IO.inspect(sorted, limit: :infinity)
    sorted
  end

  defp radix_sort(list, _, max, exp, _) when max < exp, do: list

  defp radix_sort(list, base, max, exp, depth) do
    buckets = get_buckets(list, base, exp)
    sorted = get_list_from_buckets(buckets)
    # Concurrency (work in progress):
    # split my list into 2, call 2 processes link to sort each side recursively and join at the end
    radix_sort(sorted, base, max, exp*base, depth - 1)
  end

  defp get_empty_buckets(base), do: 0..base-1 |> Enum.map(fn _ -> [] end)

  defp get_buckets(list, base, exp) do
    get_buckets(list, base, get_empty_buckets(base), 0, exp)
  end

  defp get_buckets([], _, buckets, _, _), do: buckets

  defp get_buckets([element | remaining], base, buckets, index, exp) do
    position = get_position(abs(element), base, exp)
    left = Enum.slice(buckets, 0, position)
    right = Enum.slice(buckets, position + 1, base - 1)
    new_buckets = left ++ [Enum.at(buckets, position) ++ [element]] ++ right
    get_buckets(remaining, base, new_buckets, index + 1, exp)
  end

  defp get_position(element, base, exp) when exp <= 1, do: rem(element, base)

  defp get_position(element, base, exp) do
    quotient = div(element, base)
    get_position(quotient, base, exp/base)
  end

  defp get_list_from_buckets(buckets) do
    almost_sorted = List.flatten(buckets)

    # Treating negative numbers:
    {negatives, positives} = Enum.split_with(almost_sorted, fn x -> x < 0 end)
    Enum.reverse(negatives, positives)
  end

  defp display_error_message() do
    # Doubt: Did I need to check the number of threads?
    IO.puts("\nSyntax: ")
    IO.puts("escripts pbbs RadixSort [<m>] n")
    IO.puts("   to sort n values in a range [0, m] OR\n")
    IO.puts("escripts pbbs RadixSort IN")
    IO.puts("   IN: input file with numbers to sort (in the PBBS format).")
  end
end
