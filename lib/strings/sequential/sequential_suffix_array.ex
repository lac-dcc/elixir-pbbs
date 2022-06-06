defmodule SequentialSuffixArray do
  def naive(string) do
    len = String.length(string)
    suffixes_start_indexes = 0..(len - 1)

    suffixes = Enum.map(
      suffixes_start_indexes,
      fn start -> {start, String.slice(string, start..len)} end
    )

    Enum.sort_by(suffixes, &elem(&1, 1))
    |> Enum.map(&elem(&1, 0))
    |> IO.inspect
  end
end
