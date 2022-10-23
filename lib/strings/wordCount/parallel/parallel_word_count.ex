defmodule Strings.WordCount.Parallel do
  def word_count(string, p) do
    :eprof.start_profiling([self()])
    ret = (0..p-1)
    |> Enum.map(fn i ->
      Task.async(fn ->
        String.split(string, ~r/[^A-z]+/)
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

    :eprof.stop_profiling()
    :eprof.analyze()

    ret
  end
end
