defmodule Utils.Lists do
  # Does need to be concurrent?
  def max(list) when is_list(list), do: maximum(list)
  defp maximum([]), do: nil
  defp maximum([head | tail]), do: maximum(head, tail)
  defp maximum(value, []), do: value

  defp maximum(value, [head | tail]) do
    if value > head do
      maximum(value, tail)
    else
      maximum(head, tail)
    end
  end

  def split(list) do
    Enum.split(list, div(length(list), 2))
  end

  def split_at(array, at), do: split_at(array, at, 0, [], [])

  def split_at([], _, _, l, r), do: {reverse(l), reverse(r)}

  def split_at([h | t], at, index, l, r) do
    if index < at do
      split_at(t, at, index + 1, [h | l], r)
    else
      split_at(t, at, index + 1, l, [h | r])
    end
  end

  defp reverse(l), do: reverse(l, [])
  defp reverse([], r), do: r
  defp reverse([h | t], r), do: reverse(t, [h | r])

  def print(list), do: IO.inspect(list, charlists: :as_lists)
  def print(list, true), do: IO.inspect(list, charlists: :as_lists, limit: :infinity)

  def chunk_uniformly(list, number_of_chunks) do
    len = length(list)
    optimal_chunk_size = div(len + number_of_chunks - 1, number_of_chunks)
    overspill = optimal_chunk_size * number_of_chunks - len

    {full_chunks, partial_chunks} =
      list
      |> Enum.split((number_of_chunks - overspill) * optimal_chunk_size)

    Enum.concat(
      full_chunks |> Enum.chunk_every(optimal_chunk_size),
      case partial_chunks do
        [] -> List.duplicate([], overspill)
        ls -> ls |> Enum.chunk_every(optimal_chunk_size - 1)
      end
    )
  end
end
