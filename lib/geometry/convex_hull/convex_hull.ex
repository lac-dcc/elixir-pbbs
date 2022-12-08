defmodule Geometry.ConvexHull.ConvexHull do
  def convex_hull(points) do
    indexed_points = Enum.with_index(points)
    min_x = Enum.min_by(indexed_points, fn ({point, _idx}) -> elem(point, 0) end)
    max_x = Enum.max_by(indexed_points, fn ({point, _idx}) -> elem(point, 0) end)

    hsplit(indexed_points, min_x, max_x) ++ hsplit(indexed_points, max_x, min_x)
  end

  def hsplit(points, {p1, p1_index}, {p2, p2_index}) do
    cross = Enum.map(points, fn ({pt, _idx}) -> cross_product(pt, p1, p2) end)

    zipped = Enum.zip(points, cross)
    packed = zipped
    |> Enum.filter(fn ({_point, cross}) -> cross > 0 end)
    |> Enum.map(fn ({point, _cross}) -> point end)

    if length(packed) < 2 do
      [p1_index] ++ Enum.map(packed, fn ({_pt, idx}) -> idx end)
    else
      pm = Enum.max_by(zipped, fn ({_point, cross}) -> cross end)
      |> elem(0)

      hsplit(packed, {p1, p1_index}, pm) ++ hsplit(packed, pm, {p2, p2_index})
    end
  end

  def cross_product({ox, oy}, {vx, vy}, {wx, wy}) do
    (vx - ox) * (wy - oy) - (vy - oy) * (wx - ox)
  end
end
