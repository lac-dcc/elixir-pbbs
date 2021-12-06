defmodule Sequences.RadixSort.Concurrent do
  def run(args) do
    [p | input] = args
    list = Utils.Inputs.get_sequence(input)

    if list != [] and Utils.Validators.is_number(p) do
      IO.puts("Original sequence: ")
      Utils.Lists.print(list)
      radix_sort_concurrent(list, String.to_integer(p))
    else
      display_error_message()
    end
  end

  defp radix_sort_concurrent(list, p) do
    parts = Utils.Lists.chunk_uniformly(list, p)
    parent = self()

    refs =
      Enum.map(parts, fn elements ->
        ref = make_ref()

        spawn_link(fn ->
          send(parent, {:sort, ref, [elements, 1]})
        end)

        ref
      end)

    sorted_by_digit =
      Enum.map(refs, fn _ ->
        receive do
          {:sort, _, [list, digit]} -> radix_sort(list, digit)
        end
      end)

    Enum.each(0..(length(sorted_by_digit) - 1), fn i ->
      send(parent, {:rearrange, Enum.at(refs, i), [refs, Enum.at(sorted_by_digit, i)]})
    end)

    # Enum.map(refs, fn _ ->
    #   receive do
    #     {:sort, ref, [list, digit]} ->
    #       send(parent, {:rearrange, ref, [radix_sort(list, digit)]})
    #   end
    # end)

    rearranged_lists =
      Enum.map(refs, fn _ ->
        receive do
          {:rearrange, ref, [refs, list]} -> rearrange(list, ref, refs)
        end
      end)

    Utils.Lists.print(sorted_by_digit)
  end

  def rearrange(list, ref, refs) do
    # IO.inspect(refs)
    IO.inspect(ref)
    IO.inspect(list)
  end

  def radix_sort(list, digit) do
    buckets = get_buckets(list, 10, digit)
    sorted_by_digit = get_list_from_buckets(buckets)
    sorted_by_digit
  end

  defp get_list_from_buckets(buckets) do
    almost_sorted = List.flatten(buckets)

    # Treating negative numbers:
    {negatives, positives} = Enum.split_with(almost_sorted, fn x -> x < 0 end)
    Enum.reverse(negatives, positives)
  end

  defp get_empty_buckets(base), do: 0..(base - 1) |> Enum.map(fn _ -> [] end)

  defp get_buckets([], _, buckets, _, _), do: buckets

  defp get_buckets(list, base, exp) do
    get_buckets(list, base, get_empty_buckets(base), 0, exp)
  end

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

  def master_listener() do
    IO.puts("MASTER ESCUTANDO")

    receive do
      {:ok, result} ->
        IO.puts("bom")

      _ ->
        IO.puts("ruim")
        # receiver_loop(results, results_expected)
    end
  end

  def worker_listener() do
    IO.puts("WORKER ESCUTANDO")

    receive do
      {master_pid, {:sort, [list, digit]}} ->
        send(master_pid, sort(list, digit))

      _ ->
        :error
    end
  end

  def sort(list, digit) do
    IO.puts("sort")
    {:ok, radix_sort(list, digit)}
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
