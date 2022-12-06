defmodule Geometry.ConvexHull.Parallel.DivideAndConquer do
  def convex_hull(points) do
    sorted_points = Enum.with_index(points)
    |> Enum.map(fn ({{x, y}, idx}) -> {x, y, idx} end)
    |> List.keysort(0)

    :ets.new(:ch, [:public, :named_table])
    :ets.insert(:ch, {:points, sorted_points})

    p = 12
    size = ceil(length(sorted_points) / p)
    parts = (0..p-1)
    |> Enum.map(fn idx -> (idx*size) end)
    |> Enum.map(fn start ->
      Task.async(fn ->
        pts = Keyword.get(:ets.lookup(:ch, :points), :points)
        slice = Enum.slice(pts, start, size)
        |> Enum.map(fn ({x, y, idx}) -> {{x,y}, idx} end)
        Geometry.ConvexHull.ConvexHull.convex_hull(slice)
      end)
    end)
    |> Task.await_many(:infinity)

    result = Enum.reduce(parts, fn el, acc ->
      Geometry.ConvexHull.ConvexHull.merge_hulls(acc, el)
    end)
    |> Enum.map(fn ({_point, index}) -> index end)

    :ets.delete(:ch)

    result
  end
end
