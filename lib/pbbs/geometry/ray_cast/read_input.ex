defmodule PBBS.Geometry.RayCast.ReadInput do
  def read_input(triangles_file_path, rays_file_path) do
    {read_triangles(triangles_file_path), read_rays(rays_file_path)}
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

    Enum.chunk_every(lines, 2)
    |> Enum.map(fn ([from_line, to_line]) ->
      %PBBS.Geometry.Common.Ray{
        from: create_point_from_line(from_line),
        to: create_point_from_line(to_line)
      }
    end)
  end

  defp create_point_from_line(line) do
    [x, y, z] =
      String.split(line)
      |> Enum.map(&String.to_float/1)

    %PBBS.Geometry.Common.Vec3{x: x, y: y, z: z}
  end

  defp create_triangle_from_line(line, indexed_points) do
    points =
      String.split(line)
      |> Enum.map(&String.to_integer/1)
      |> Enum.map(fn index -> indexed_points[index - 1] end)

    %PBBS.Geometry.Common.Triangle{points: points}
  end
end
