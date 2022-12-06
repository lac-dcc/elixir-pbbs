defmodule Geometry.ConvexHull.ConvexHull do
  def convex_hull(indexed_points) do
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
      [{p1, p1_index}] ++ packed
    else
      pm = Enum.max_by(zipped, fn ({_point, cross}) -> cross end)
      |> elem(0)

      hsplit(packed, {p1, p1_index}, pm) ++ hsplit(packed, pm, {p2, p2_index})
    end
  end

  def cross_product({ox, oy}, {vx, vy}, {wx, wy}) do
    (vx - ox) * (wy - oy) - (vy - oy) * (wx - ox)
  end

  def merge_hulls(left_hull, right_hull) do
    indexed_lh = Enum.with_index(left_hull)
    |> Enum.map(fn ({point, index}) -> {index, point} end)

    indexed_rh = Enum.with_index(right_hull)
    |> Enum.map(fn ({point, index}) -> {index, point} end)

    kv_lh = Map.new(indexed_lh)
    kv_rh = Map.new(indexed_rh)

    rightmost_from_left_hull = indexed_lh
    |> Enum.max_by(fn ({_idx, {{x, _y}, _original_idx}}) -> x end)

    leftmost_from_right_hull = indexed_rh
    |> Enum.min_by(fn ({_idx, {{x, _y}, _original_idx}}) -> x end)

    {{ut1, oiut1, ut1i}, {ut2, oiut2, ut2i}} = upper_tangent(kv_lh, kv_rh, rightmost_from_left_hull, leftmost_from_right_hull)
    {{lt1, oilt1, lt1i}, {lt2, oilt2, lt2i}} = lower_tangent(kv_lh, kv_rh, rightmost_from_left_hull, leftmost_from_right_hull)

    start = Enum.filter(indexed_lh, fn ({idx, {_point, _original_idx}}) -> idx < ut1i end)
    |> Enum.map(fn ({_idx, {point, original_idx}}) -> {point, original_idx} end)

    upper_tangent = [{ut1, oiut1}, {ut2, oiut2}]

    middle = Enum.filter(indexed_rh, fn ({idx, {_point, _original_idx}}) -> idx > ut2i and (lt2i == 0 or idx < lt2i) end)
    |> Enum.map(fn ({_idx, {point, original_idx}}) -> {point, original_idx} end)

    lower_tangent = [{lt2, oilt2}, {lt1, oilt1}]

    finish = Enum.filter(indexed_lh, fn ({idx, {_point, _original_idx}}) -> idx > lt1i end)
    |> Enum.map(fn ({_idx, {point, original_idx}}) -> {point, original_idx} end)

    :lists.append([start, upper_tangent, middle, lower_tangent, finish])
  end

  def upper_tangent(ilh, irh, rm, lm) do
    upper_tangent_internal(ilh, irh, rm, lm)
  end

  def upper_tangent_internal(ilh, irh, {a_index, {a, original_index_a}}, {b_index, {b, original_index_b}}) do
    {a_succ, original_index_a_succ} = ilh[a_index - 1]
    {b_succ, original_index_b_succ} = irh[b_index + 1]
    if orientation(a, b, a_succ) > 0 do
      upper_tangent_internal(ilh, irh, {a_index - 1, {a_succ, original_index_a_succ}}, {b_index, {b, original_index_b}})
    else
      if orientation(a, b, b_succ) > 0 do
        upper_tangent_internal(ilh, irh, {a_index, {a, original_index_a}}, {b_index + 1, {b_succ, original_index_b_succ}})
      else
        {{a, original_index_a, a_index}, {b, original_index_b, b_index}}
      end
    end
  end

  def lower_tangent(ilh, irh, rm, lm) do
    lower_tangent_internal(ilh, irh, rm, lm)
  end

  def lower_tangent_internal(ilh, irh, {a_index, {a, original_index_a}}, {b_index, {b, original_index_b}}) do
    {a_succ, original_index_a_succ} = ilh[a_index + 1]
    new_b_index = if b_index == 0 do
      length(Map.values(irh)) - 1
    else
      b_index - 1
    end
    {b_succ, original_index_b_succ} = irh[new_b_index]
    if not is_nil(a_succ) and orientation(a, b, a_succ) < 0 do
      lower_tangent_internal(ilh, irh, {a_index + 1, {a_succ, original_index_a_succ}}, {b_index, {b, original_index_b}})
    else
      if not is_nil(b_succ) and orientation(a, b, b_succ) < 0 do
        lower_tangent_internal(ilh, irh, {a_index, {a, original_index_a}}, {new_b_index, {b_succ, original_index_b_succ}})
      else
        {{a, original_index_a, a_index}, {b, original_index_b, b_index}}
      end
    end
  end

  def orientation({ax, ay}, {bx, by}, {cx, cy}) do
    ((bx - ax) * (cy - ay) - (by - ay) * (cx - ax))
  end
end
