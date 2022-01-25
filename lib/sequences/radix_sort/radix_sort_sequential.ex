# Description: https://www.cs.cmu.edu/~pbbs/benchmarks/integerSort.html

defmodule Sequences.RadixSort.Sequential do
  def run(args) do
    [processes | input] = args
    list = Utils.Inputs.get_sequence(input)

    if list != [] and Utils.Validators.is_number(processes) do
      IO.puts("Original sequence: ")
      Utils.Lists.print(list)
      radix_sort_sequential(list)
    else
      display_error_message()
    end
  end

  defp radix_sort_sequential(list) do
    {elapsed_time, sorted} = :timer.tc(fn -> radix_sort(list) end)
    IO.puts("\nSorted sequence - Sequential: ")
    Utils.Lists.print(sorted)
    IO.puts("Elapsed time: #{elapsed_time} ms\n")
  end

  defp radix_sort(list) do
    max = abs(Utils.Lists.max(list))
    radix_sort(list, 10, max, 1)
  end

  defp radix_sort(list, _, max, exp) when max < exp, do: list

  defp radix_sort(list, base, max, exp) do
    buckets = get_buckets(list, base, exp)
    sorted = get_list_from_buckets(buckets)
    radix_sort(sorted, base, max, exp * base)
  end

  defp get_empty_buckets(base), do: 0..(base - 1) |> Enum.map(fn _ -> [] end)

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
    get_position(quotient, base, exp / base)
  end

  defp get_list_from_buckets(buckets) do
    almost_sorted = List.flatten(buckets)

    # Treating negative numbers:
    {negatives, positives} = Enum.split_with(almost_sorted, fn x -> x < 0 end)
    Enum.reverse(negatives, positives)
  end

  defp display_error_message() do
    IO.puts("\nSyntax: ")
    IO.puts("escripts pbbs RadixSort p [<m>] n")
    IO.puts("   to sort n values in a range [0, m], if m not given, m = n")
    IO.puts("   p: max number of processes OR\n")
    IO.puts("escripts pbbs RadixSort p IN")
    IO.puts("   IN: input file with numbers to sort (in the PBBS format).")
    IO.puts("   p: max number of processes")
  end
end
