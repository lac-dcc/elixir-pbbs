# Description: https://www.cs.cmu.edu/~pbbs/benchmarks/comparisonSort.html

defmodule Sequences.SampleSort do
  def run(args) do
    if is_valid_args(args) do
      [processes_number | [lower_limit | list_inputs]] = args
      list = Utils.Inputs.get_sequence(list_inputs)

      if list != [] and Utils.Validators.is_number(processes_number) and
           Utils.Validators.is_number(lower_limit) do
        if String.to_integer(processes_number) <= length(list) do
          # IO.puts("\nOriginal sequence: ")
          # Utils.Lists.print(list)

          {elapsed_time, sorted_list} =
            :timer.tc(fn ->
              sample_sort(
                String.to_integer(processes_number),
                String.to_integer(lower_limit),
                list
              )
            end)

          # IO.puts("Sorted sequence: ")
          # Utils.Lists.print(sorted_list)
          # IO.puts("Elapsed time: #{elapsed_time / 1_000_000} s\n")
          IO.puts(elapsed_time / 1_000_000)
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

  defp sample_sort(_, _, []), do: []

  defp sample_sort(_, lower_limit, list) when length(list) <= lower_limit,
    do: Sequences.InsertionSort.run(list)

  # need to use the processes number
  defp sample_sort(processes_number, lower_limit, list) do
    if length(Enum.uniq(list)) > 1 do
      # Step 1: Choose the pivots in list. We will choose the pivots numbers based on CPU cores
      pivots = get_pivots_from_list(list, processes_number)

      if length(pivots) > 1 do
        # Step 2: Sorting my pivots
        sorted_pivots = Sequences.InsertionSort.run(pivots)

        # Step 3: Split list into buckets by pivots
        buckets =
          get_buckets(list, sorted_pivots)
          |> Tuple.to_list()
          |> Enum.filter(fn bucket -> bucket != [] end)

        # Step 4: Sort which bucket concurrently
        tasks =
          Enum.map(buckets, fn bucket ->
            Task.async(fn ->
              sample_sort(processes_number, lower_limit, bucket)
            end)
          end)

        List.flatten(Task.await_many(tasks, :infinity))
      else
        Sequences.InsertionSort.run(list)
      end
    else
      list
    end
  end

  defp get_buckets(list, pivots) do
    empty_buckets = List.to_tuple(for _ <- 0..length(pivots), do: [])

    Enum.reduce(list, empty_buckets, fn x, acc ->
      element =
        Enum.find(pivots, fn pivot ->
          x < pivot
        end)

      i =
        if element == nil do
          length(pivots)
        else
          Enum.find_index(pivots, fn pivot -> pivot == element end)
        end

      put_elem(acc, i, [x | elem(acc, i)])
    end)
  end

  defp get_pivots_from_list(list, _) do
    uniq_list = Enum.uniq(list)
    # need use the processes_number? hmm
    available_cores = System.schedulers_online()

    pivots_number =
      if length(uniq_list) > available_cores do
        available_cores
      else
        # can be improved?
        floor(length(uniq_list) / 2)
      end

    0..(pivots_number - 1) |> Enum.map(fn i -> Enum.at(uniq_list, i) end)
  end

  defp display_error_message() do
    IO.puts("\nSyntax: ")
    IO.puts("escript pbbs SampleSort p ll [<m>] n")
    IO.puts("   to sort n values in a range [0, m], if m not given, m = n")
    IO.puts("   p: max number of processes")
    IO.puts("   ll: lower limit. Sample sort will be applied up to arrays of size > ll OR\n")
    IO.puts("escript pbbs SampleSort p ll  IN")
    IO.puts("   IN: input file with numbers to sort (in the PBBS format).")
    IO.puts("   p: max number of processes")
    IO.puts("   ll: lower limit. Sample sort will be applied up to arrays of size > ll")
  end
end
