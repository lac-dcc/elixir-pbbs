defmodule Strings.WordCount.Parallel do
  def word_count(string, p) do
    words = String.split(string)

    (0..p-1)
    |> Enum.map(fn i ->
      Task.async(fn ->
        Enum.drop(words, i)
        |> Enum.take_every(p)
        |> Enum.frequencies
      end)
    end)
    |> Task.await_many
    |> Enum.reduce(%{}, fn (res, acc) ->
      Map.merge(res, acc, fn (_key, v1, v2) -> v1 + v2 end)
    end)
  end
end
