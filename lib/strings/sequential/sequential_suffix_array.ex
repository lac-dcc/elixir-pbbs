defmodule SequentialSuffixArray do
  def suffix_array(string) do
    len = String.length(string)
    suffixes_start_indexes = 0..(len - 1)

    suffixes = Enum.map(
      suffixes_start_indexes,
      fn s -> {s, binary_part(string, s, len - s)} end
    )

    Enum.sort_by(suffixes, &elem(&1, 1))
    |> Enum.map(&elem(&1, 0))
  end
end
