defmodule Geometry.RayCast do
  alias Geometry.Vec3
  def ray_cast(triangles_file_path, rays_file_path) do
    {triangles, rays} = Geometry.RayCast.ReadInput.read_input(triangles_file_path, rays_file_path)

    indexed_triangles = Enum.with_index(triangles)

    result = Enum.map(rays, fn ray ->
      Enum.map(indexed_triangles, fn ({triangle, index}) ->
        {Geometry.RayCast.ray_triangle_intersect(ray, triangle), index}
      end)
      |> Enum.filter(fn ({{intersects, _distance}, _index}) -> intersects end)
      |> Enum.min_by(fn ({{_intersects, distance}, _index}) -> distance end, fn -> -1 end)
      |> take_index
    end)

    result
  end

  defp take_index(-1) do
    -1
  end

  defp take_index({{_intersects, _distance}, index}) do
    index
  end

  def ray_triangle_intersect(ray, triangle) do
    epsilon = 1.0e-8

    v0v1 = Geometry.Vec3.sub(Enum.at(triangle.points, 1), Enum.at(triangle.points, 0))
    v0v2 = Geometry.Vec3.sub(Enum.at(triangle.points, 2), Enum.at(triangle.points, 0))

    pvec = Geometry.Vec3.cross_product(ray.to, v0v2)
    det = Geometry.Vec3.dot_product(v0v1, pvec)

    if abs(det) < epsilon do
      {false, nil}
    else
      inv_det = 1 / det
      t_vec = Vec3.sub(ray.from, Enum.at(triangle.points, 0))
      u = Vec3.dot_product(t_vec, pvec) * inv_det
      if u < 0 or u > 1 do
        {false, nil}
      else
        q_vec = Vec3.cross_product(t_vec, v0v1)
        v = Vec3.dot_product(ray.to, q_vec) * inv_det

        if v < 0 or u + v > 1 do
          {false, nil}
        else
          dist = Vec3.dot_product(v0v2, q_vec) * inv_det

          {true, dist}
        end
      end
    end
  end
end