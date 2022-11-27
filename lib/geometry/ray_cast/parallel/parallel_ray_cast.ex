defmodule Geometry.RayCast.Parallel.ParallelRayCast do
  def ray_cast(triangles_file_path, rays_file_path) do
    p = 11

    {triangles, rays} = Geometry.RayCast.ReadInput.read_input(triangles_file_path, rays_file_path)

    :ets.new(:rc, [:public, :named_table])
    indexed_triangles = Enum.with_index(triangles)
    :ets.insert(:rc, {:triangles, indexed_triangles})
    :ets.insert(:rc, {:rays, rays})

    size = ceil(length(rays) / p)
    result = (0..p)
    |> Enum.map(fn idx -> (idx*size) end)
    |> Enum.map(fn start ->
      Task.async(fn ->
        tri = Keyword.get(:ets.lookup(:rc, :triangles), :triangles)
        Keyword.get(:ets.lookup(:rc, :rays), :rays)
        |> Enum.slice(start, size)
        |> Enum.map(fn ray ->
          Enum.map(tri, fn ({triangle, index}) ->
            {Geometry.RayCast.ray_triangle_intersect(ray, triangle), index}
          end)
          |> Enum.filter(fn ({{intersects, _distance}, _index}) -> intersects end)
          |> Enum.min_by(fn ({{_intersects, distance}, _index}) -> distance end, fn -> -1 end)
          |> take_index
        end)
      end)
    end)
    |> Task.await_many(:infinity)
    |> :lists.append

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
