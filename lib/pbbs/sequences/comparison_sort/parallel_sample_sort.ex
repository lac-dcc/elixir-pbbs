# Description: https://www.cs.cmu.edu/~pbbs/benchmarks/comparisonSort.html

defmodule PBBS.Sequences.ComparisonSort.Parallel do
  def sample_sort(_, []), do: []

  def sample_sort(lower_limit, list) when length(list) <= lower_limit,
    do: Utils.InsertionSort.run(list)

  def sample_sort(lower_limit, list) do
    if length(Enum.uniq(list)) > 1 do
      # Step 1: Choose the pivots in list. We will choose the pivots numbers based on CPU cores
      pivots = get_pivots_from_list(list)

      if length(pivots) > 1 do
        # Step 2: Sorting my pivots
        sorted_pivots = Utils.InsertionSort.run(pivots)

        # Step 3: Split list into buckets by pivots
        buckets =
          get_buckets(list, sorted_pivots)
          |> Tuple.to_list()
          |> Enum.filter(fn bucket -> bucket != [] end)

        # Step 4: Sort which bucket concurrently
        tasks =
          Enum.map(buckets, fn bucket ->
            Task.async(fn ->
              sample_sort(lower_limit, bucket)
            end)
          end)

        List.flatten(Task.await_many(tasks, :infinity))
      else
        Utils.InsertionSort.run(list)
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

  defp get_pivots_from_list(list) do
    uniq_list = Enum.uniq(list)
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
end
