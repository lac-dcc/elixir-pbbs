# Description: https://www.cs.cmu.edu/~pbbs/benchmarks/comparisonSort.html

defmodule Sequences.SampleSort do
  def run(args) do
    if is_valid_args(args) do
      [processes_number | [lower_limit | list_inputs]] = args
      list = Utils.Inputs.get_sequence(list_inputs)

      if list != [] and Utils.Validators.is_number(processes_number) and
           Utils.Validators.is_number(lower_limit) do
        if String.to_integer(processes_number) <= length(list) do
          {elapsed_time, sorted_list} =
            :timer.tc(fn ->
              sample_sort(
                String.to_integer(processes_number),
                String.to_integer(lower_limit),
                list
              )
            end)

          IO.puts("Original sequence: ")
          Utils.Lists.print(list, true)
          IO.puts("Sorted sequence: ")
          Utils.Lists.print(sorted_list, true)
          IO.puts("Elapsed time: #{elapsed_time} ms\n")
        else
          IO.puts("p must be smaller than the list size")
        end
      else
        display_error_message()
      end
    else
      display_error_message()
    end
  end

  def is_valid_args(args) do
    case length(args) do
      3 -> true
      4 -> true
      _ -> false
    end
  end

  # need to use the processes number
  def sample_sort(processes_number, lower_limit, list) do
    if length(list) > lower_limit do
      # Step 1: Choose the pivots in list. We will choose the pivots numbers based on CPU cores
      pivots = get_pivots_from_list(list, processes_number)

      # Step 2: Sorting my pivots
      sorted_pivots = Sequences.InsertionSort.run(pivots)

      # Step 3: Split list into buckets by pivots
      empty_buckets = get_empty_buckets(length(sorted_pivots) + 1)
      buckets = get_buckets(list, empty_buckets, sorted_pivots, 0, 0)

      # Step 4: Sort which bucket concurrently
      tasks =
        Enum.map(buckets, fn bucket ->
          Task.async(fn ->
            sample_sort(processes_number, lower_limit, bucket)
          end)
        end)

      List.flatten(Task.await_many(tasks, :infinity))
    else
      # Small lists will be sorted with insertion sort
      Sequences.InsertionSort.run(list)
    end
  end

  defp get_buckets(list, buckets, _, list_index, _) when list_index >= length(list), do: buckets

  defp get_buckets(list, buckets, pivots, list_index, pivots_index)
       when pivots_index > length(pivots) do
    list_value = Enum.at(list, list_index)
    bucket_value = Enum.at(buckets, pivots_index + 1)
    List.replace_at(buckets, length(pivots) + 1, [list_value | bucket_value])
  end

  defp get_buckets(list, buckets, pivots, list_index, pivots_index) do
    list_value = Enum.at(list, list_index)
    pivot_value = Enum.at(pivots, pivots_index)
    bucket_value = Enum.at(buckets, pivots_index)

    if list_value <= pivot_value do
      new_buckets = List.replace_at(buckets, pivots_index, [list_value | bucket_value])
      get_buckets(list, new_buckets, pivots, list_index + 1, 0)
    else
      get_buckets(list, buckets, pivots, list_index, pivots_index + 1)
    end
  end

  defp get_empty_buckets(n), do: 1..n |> Enum.map(fn _ -> [] end)

  defp get_pivots_from_list(list, _) do
    # need use the processes_number? hmm
    available_cores = System.schedulers_online()

    pivots_number =
      if length(list) > available_cores do
        available_cores
      else
        # can be improved?
        floor(length(list) / 2)
      end

    0..(pivots_number - 1) |> Enum.map(fn i -> Enum.at(list, i) end)
  end

  defp display_error_message() do
    IO.puts("\nSyntax: ")
    IO.puts("escripts pbbs SampleSort p ll [<m>] n")
    IO.puts("   to sort n values in a range [0, m], if m not given, m = n")
    IO.puts("   p: max number of processes")
    IO.puts("   ll: lower limit. Sample sort will be applied up to arrays of size > ll OR\n")
    IO.puts("escripts pbbs SampleSort p IN")
    IO.puts("   IN: input file with numbers to sort (in the PBBS format).")
    IO.puts("   p: max number of processes")
  end
end
