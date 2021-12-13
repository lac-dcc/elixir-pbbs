defmodule Sequences.RadixSort.Concurrent do
  def run(args) do
    [p | input] = args
    list = Utils.Inputs.get_sequence(input)

    if list != [] and Utils.Validators.is_number(p) do
      IO.puts("Original sequence: ")
      Utils.Lists.print(list)
      radix_sort_concurrent(list)
    else
      display_error_message()
    end
  end

  defp radix_sort_concurrent(list) do
    # Getting the number of digits of max element in list
    max = abs(Utils.Lists.max(list))
    max_length = length(Integer.digits(max))

    {elapsed_time, sorted} =
      :timer.tc(fn -> List.flatten(radix_sort_concurrent(list, 10, 0, max_length)) end)

    IO.puts("\nSorted sequence - Concurrent: ")
    Utils.Lists.print(sorted, true)
    IO.puts("Elapsed time: #{elapsed_time/1000000} s\n")
    sorted
  end

  defp radix_sort_concurrent(list, _, digit, rank) when digit == rank, do: list

  defp radix_sort_concurrent(list, base, digit, rank) do
    string_list =
      Enum.map(list, fn item -> String.pad_leading(Integer.to_string(item), rank, "0") end)

    empty_buckets = List.to_tuple(for _ <- 0..base-1, do: [])
    buckets = Enum.reduce(string_list, empty_buckets, fn x,acc ->
      i = String.to_integer(String.at(x, digit))
      put_elem(acc, i, [x | elem(acc, i)])
    end)

    parent = self()

    # concurrent
    tasks =
      Enum.map(Tuple.to_list(buckets), fn bucket ->
        Task.async(fn ->
          new_list = get_list_from_buckets(bucket)
          radix_sort_concurrent(new_list, base, digit + 1, rank)
        end)
      end)
    Task.await_many(tasks, :infinity)


    ## sequential:
    # Enum.map(Tuple.to_list(buckets), fn bucket ->
    #   new_list = get_list_from_buckets(bucket)
    #   radix_sort_concurrent(new_list, base, digit + 1, rank)
    # end)
  end

  defp get_empty_buckets(base), do: 0..(base - 1) |> Enum.map(fn _ -> [] end)

  defp get_buckets(list, base, digit) do
    get_buckets(list, get_empty_buckets(base), base, digit)
  end

  defp get_buckets([], buckets, _, _), do: buckets

  defp get_buckets([element | remaining], buckets, base, digit) do
    position = String.to_integer(String.at(element, digit))
    left = Enum.slice(buckets, 0, position)
    right = Enum.slice(buckets, position + 1, base - 1)
    new_buckets = left ++ [Enum.at(buckets, position) ++ [element]] ++ right
    get_buckets(remaining, new_buckets, base, digit)
  end

  defp get_list_from_buckets(buckets) do
    List.flatten(buckets)
    |> Enum.map(fn item -> String.to_integer(item) end)
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
