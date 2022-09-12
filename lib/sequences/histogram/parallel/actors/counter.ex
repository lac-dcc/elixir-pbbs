defmodule Sequences.Histogram.Parallel.Counter do

  def start(id) do
    spawn(__MODULE__, :loop, [id, 0])
  end

  def loop(id, counts) do
    receive do
      {:get, sender} ->
          send(sender, {id, counts})
          loop(id, counts)
      {:increment} ->
        loop(id, counts + 1)
    end
  end
end
