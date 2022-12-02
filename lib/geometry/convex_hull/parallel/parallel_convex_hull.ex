defmodule Geometry.ConvexHull.ConvexHull.Parallel do
  def convex_hull(points) do
    indexed_points = Enum.with_index(points)

    :ets.new(:ch, [:public, :named_table])
    :ets.insert(:ch, {:points, indexed_points})

    [min_x, max_x] = Task.await_many([
      Task.async(fn ->
        pts = Keyword.get(:ets.lookup(:ch, :points), :points)
        Enum.min_by(pts, fn ({point, _idx}) -> point.x end)
      end),
      Task.async(fn ->
        pts = Keyword.get(:ets.lookup(:ch, :points), :points)
        Enum.max_by(pts, fn ({point, _idx}) -> point.x end)
      end),
    ])

    [first, second] = Task.await_many([
      Task.async(fn ->
        pts = Keyword.get(:ets.lookup(:ch, :points), :points)
        hsplit(2,pts, min_x, max_x)
      end),
      Task.async(fn ->
        pts = Keyword.get(:ets.lookup(:ch, :points), :points)
        hsplit(3,pts, max_x, min_x)
      end)
    ])

    result = first ++ second

    :ets.delete(:ch)

    result
  end

  def hsplit(index, points, {p1, p1_index}, {p2, p2_index}) do
    zipped = Enum.map(points, fn ({pt, idx}) -> {{pt, idx}, cross_product(pt, p1, p2)} end)

    packed = zipped
    |> Enum.filter(fn ({_point, cross}) -> cross > 0 end)
    |> Enum.map(fn ({point, _cross}) -> point end)

    if length(packed) < 2 do
      [p1_index] ++ Enum.map(packed, fn ({_pt, index}) -> index end)
    else
      pm = Enum.max_by(zipped, fn ({_point, cross}) -> cross end)
      |> elem(0)

      if length(packed) < 1000 do
        hsplit(index*2, packed, {p1, p1_index}, pm) ++ hsplit(index*2 + 1, packed, pm, {p2, p2_index})
      else
        :ets.insert(:ch, {String.to_atom("pts#{index}"), packed})
        [first, second] = Task.await_many([
          Task.async(fn ->
            pts = Keyword.get(:ets.lookup(:ch, String.to_atom("pts#{index}")), String.to_atom("pts#{index}"))
            hsplit(index*2,pts, {p1, p1_index}, pm)
          end),
          Task.async(fn ->
            pts = Keyword.get(:ets.lookup(:ch, String.to_atom("pts#{index}")), String.to_atom("pts#{index}"))
            hsplit(index*2 + 1,pts, pm, {p2, p2_index})
          end)
        ])

        first ++ second
      end
    end
  end

  def cross_product(o, v, w) do
    (v.x - o.x) * (w.y - o.y) - (v.y - o.y) * (w.x - o.x)
  end
end
