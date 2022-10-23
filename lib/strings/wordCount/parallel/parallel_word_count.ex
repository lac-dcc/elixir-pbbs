defmodule Strings.WordCount.Parallel do
  def word_count(string, p) do
    :ets.new(:wc, [:public, :named_table])
    :ets.insert(:wc, {:data, string})
    result = (0..p-1)
    |> Enum.map(fn i ->
      Task.async(fn ->
        input = Keyword.get(:ets.lookup(:wc, :data), :data)
        String.split(input, ~r/[^A-z]+/)
        |> Enum.map(&String.downcase/1)
        |> Enum.drop(i)
        |> Enum.take_every(p)
        |> Enum.frequencies
      end)
    end)
    |> Task.await_many(:infinity)
    |> Enum.reduce(%{}, fn (res, acc) ->
      Map.merge(res, acc, fn (_key, v1, v2) -> v1 + v2 end)
    end)

    :ets.delete(:wc)

    result
  end
end
