defmodule PBBS.Strings.WordCount.Parallel do
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
        |> Enum.to_list
      end)
    end)
    |> Task.await_many(:infinity)
    |> :lists.append
    |> Enum.reduce(%{}, fn (({k, v}), acc) ->
      Map.update(acc, k, v, fn old -> old + v end)
    end)

    :ets.delete(:wc)

    result
  end
end
