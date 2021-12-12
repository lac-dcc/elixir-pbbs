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
    Utils.Lists.print(sorted)
    IO.puts("Elapsed time: #{elapsed_time} ms\n")
    sorted
  end

  defp radix_sort_concurrent(list, _, digit, rank) when digit == rank, do: list

  defp radix_sort_concurrent(list, base, digit, rank) do
    string_list =
      Enum.map(list, fn item -> String.pad_leading(Integer.to_string(item), rank, "0") end)

    buckets = get_buckets(string_list, base, digit)

    parent = self()

    ## concurrent
    # refs =
    #   Enum.map(buckets, fn bucket ->
    #     ref = make_ref()

    #     spawn_link(fn ->
    #       new_list = get_list_from_buckets(bucket)

    #       send(
    #         parent,
    #         {:sort, ref, radix_sort_concurrent(new_list, base, digit + 1, rank)}
    #       )
    #     end)

    #     ref
    #   end)

    ## sequential:
    # sorted =
    #   Enum.map(buckets, fn bucket ->
    #     new_list = get_list_from_buckets(bucket)
    #     radix_sort_concurrent(new_list, base, digit + 1, rank)
    #   end)

    ## concurrent 1:
    # sorted =
    #   Enum.map(refs, fn _ ->
    #     receive do
    #       {:sort, ref, [list, base, digit, rank]} ->
    #         radix_sort_concurrent(list, base, digit, rank)
    #     end
    #   end)

    sorted = []
    # Enum.map(refs, fn _ ->
    #   receive do
    #     {:sort, ref, list} -> list
    #   end
    # end)

    # IO.puts("dale")
    # Utils.Lists.print(sorted)
    sorted
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
