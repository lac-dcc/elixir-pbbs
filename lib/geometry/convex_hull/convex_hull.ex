defmodule Geometry.ConvexHull.ConvexHull do
  def convex_hull(points) do
    min_x = Enum.min_by(points, fn point -> point.x end)
    max_x = Enum.max_by(points, fn point -> point.x end)

    hsplit(points, min_x, max_x) ++ hsplit(points, max_x, min_x)
  end

  def hsplit(points, p1, p2) do
    cross = Enum.map(points, fn pt -> cross_product(pt, p1, p2) end)

    zipped = Enum.zip(points, cross)
    packed = zipped
    |> Enum.filter(fn ({_point, cross}) -> cross > 0 end)
    |> Enum.map(fn ({point, _cross}) -> point end)

    if length(packed) < 2 do
      [p1] ++ packed
    else
      pm = Enum.max_by(zipped, fn ({_point, cross}) -> cross end)
      |> elem(0)

      hsplit(packed, p1, pm) ++ hsplit(packed, pm, p2)
    end
  end

  def cross_product(o, v, w) do
    (v.x - o.x) * (w.y - o.y) - (v.y - o.y) * (w.x - o.x)
  end
end
