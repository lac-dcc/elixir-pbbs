defmodule Geometry.RayCast do
  alias Geometry.Vec3
  def ray_cast(triangles_file_path, rays_file_path) do
    triangles = read_triangles(triangles_file_path)
    rays = read_rays(rays_file_path)

    IO.puts("Read #{length(triangles)} triangles")
    IO.puts("Read #{length(rays)} rays")

    IO.inspect(hd(triangles))
    IO.inspect(hd(rays))

    # TODO implement algorithm
    -1
  end

  defp read_triangles(triangles_file_path) do
    lines =
      File.read!(triangles_file_path)
      |> String.split("\n")
      |> Enum.drop(1)
      |> Enum.filter(fn line -> String.trim(line) != "" end)

    [first | lines] = lines

    [n, _m] =
      String.split(first)
      |> Enum.map(&String.to_integer/1)

    indexed_points =
      Enum.take(lines, n)
      |> Enum.map(fn line -> create_point_from_line(line) end)
      |> Enum.with_index()
      |> Enum.map(fn {k, v} -> {v, k} end)
      |> Map.new()

    Enum.drop(lines, n)
    |> Enum.map(fn line -> create_triangle_from_line(line, indexed_points) end)
  end

  defp read_rays(rays_file_path) do
    lines =
      File.read!(rays_file_path)
      |> String.split("\n")
      |> Enum.drop(1)
      |> Enum.filter(fn line -> String.trim(line) != "" end)

    IO.puts("Length lines read_rays: #{length(lines)}")

    Enum.chunk_every(lines, 2)
    |> Enum.map(fn ([from_line, to_line]) ->
      %Geometry.Ray{
        from: create_point_from_line(from_line),
        to: create_point_from_line(to_line)
      }
    end)
  end

  defp create_point_from_line(line) do
    [x, y, z] =
      String.split(line)
      |> Enum.map(&String.to_float/1)

    %Geometry.Vec3{x: x, y: y, z: z}
  end

  defp create_triangle_from_line(line, indexed_points) do
    points =
      String.split(line)
      |> Enum.map(&String.to_integer/1)
      |> Enum.map(fn index -> indexed_points[index - 1] end)

    %Geometry.Triangle{points: points}
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
