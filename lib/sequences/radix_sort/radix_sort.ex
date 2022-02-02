# Description: https://www.cs.cmu.edu/~pbbs/benchmarks/integerSort.html

defmodule Sequences.RadixSort do
  def run(args) do
    [p | input] = args
    list = Utils.Inputs.get_sequence(input)

    if list != [] and Utils.Validators.is_number(p) do
      IO.puts("Original sequence: ")
      Utils.Lists.print(list)
      radix_sort(list)
    else
      display_error_message()
    end
  end

  defp radix_sort(list) do
    max = abs(Utils.Lists.max(list))
    max_length = length(Integer.digits(max))

    string_list =
      Enum.map(list, fn item -> String.pad_leading(Integer.to_string(item), max_length, "0") end)

    {elapsed_time, sorted_string} =
      :timer.tc(fn -> List.flatten(radix_sort(string_list, 10, 0, max_length)) end)

    sorted = Enum.map(sorted_string, fn item -> String.to_integer(item) end)

    IO.puts("\nSorted sequence: ")
    Utils.Lists.print(sorted)
    IO.puts("Elapsed time: #{elapsed_time / 1_000_000} s\n")
    sorted
  end

  defp radix_sort(list, _, digit, rank) when digit == rank, do: list

  defp radix_sort(list, base, digit, rank) do
    buckets =
      get_buckets(list, base, digit)
      |> Tuple.to_list()
      |> Enum.filter(fn bucket -> bucket != [] end)

    tasks =
      Enum.map(buckets, fn bucket ->
        Task.async(fn ->
          radix_sort(bucket, base, digit + 1, rank)
        end)
      end)

    Task.await_many(tasks, :infinity)
  end

  defp get_buckets(list, base, digit) do
    empty_buckets = List.to_tuple(for _ <- 0..(base - 1), do: [])

    Enum.reduce(list, empty_buckets, fn x, acc ->
      i = String.to_integer(String.at(x, digit))
      put_elem(acc, i, [x | elem(acc, i)])
    end)
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
