defmodule Geometry.RayCast.Parallel.ParallelRayCast do
  def ray_cast(triangles_file_path, rays_file_path) do
    {triangles, rays} = Geometry.RayCast.ReadInput.read_input(triangles_file_path, rays_file_path)

    :ets.new(:rc, [:public, :named_table])
    indexed_triangles = Enum.with_index(triangles)
    :ets.insert(:rc, {:triangles, indexed_triangles})

    result = Enum.map(rays, fn ray ->
      Task.async(fn ->
        tri = Keyword.get(:ets.lookup(:rc, :triangles), :triangles)
        Enum.map(tri, fn ({triangle, index}) ->
          {Geometry.RayCast.ray_triangle_intersect(ray, triangle), index}
        end)
        |> Enum.filter(fn ({{intersects, _distance}, _index}) -> intersects end)
        |> Enum.min_by(fn ({{_intersects, distance}, _index}) -> distance end, fn -> -1 end)
        |> take_index
      end)
    end)
    |> Task.await_many

    :ets.delete(:rc)
    result
  end

  defp take_index(-1) do
    -1
  end

  defp take_index({{_intersects, _distance}, index}) do
    index
  end

end
