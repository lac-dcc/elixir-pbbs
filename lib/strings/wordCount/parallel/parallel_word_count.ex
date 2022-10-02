defmodule Strings.WordCount.Parallel do
  def word_count(string) do
    p = 6
    words = String.split(string)
    size = ceil(length(words) / p)

    0..p
    |> Enum.map(fn idx -> (idx*size) end)
    |> Enum.map(fn start ->
      Task.async(fn ->
        Enum.slice(words, start, size)
        |> IO.inspect
        |> Enum.frequencies
      end)
    end)
    |> Task.await_many
    |> Enum.reduce(%{}, fn (res, acc) ->
      Map.merge(res, acc, fn (_key, v1, v2) -> v1 + v2 end)
    end)
  end
end
