defmodule NaiveParallelSuffixArray do
  def suffix_array(string) do
    len = String.length(string)

    size = div(len, 11)
    parts = 0..(len-1)//size

    tasks = Enum.map(parts, fn start ->
      Task.async(fn ->
        start_indexes = start..(min(start + size - 1, len - 1))
        suffixes = Enum.map(
          start_indexes,
          fn s -> {s, binary_part(string, s, len - s)} end
        )
        sorted = Enum.sort_by(suffixes, &elem(&1, 1))

        Enum.map(sorted, fn ({index, suffix}) -> {suffix, index} end)
      end)
    end)
    results = Task.await_many(tasks, :infinity)
    merged = :lists.merge(results)

    merged
    |> Enum.map(&elem(&1, 1))
  end
end
