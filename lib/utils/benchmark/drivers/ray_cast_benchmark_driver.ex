defmodule Utils.RayCastBenchmarkDriver do
  def run_benchmark() do
    {triangles, rays} = Geometry.RayCast.ReadInput.read_input("data/inputs/ray_cast/angelTrianglesCapped", "data/inputs/ray_cast/rays")

    plist = [2, 4, 6, 12, 24, 32, 40]

    impl_map = Enum.flat_map(plist, fn p ->
      [
        {"parallel;p=#{p};angelTriangles", fn () -> Geometry.RayCast.Parallel.ParallelRayCast.ray_cast(triangles, rays, p) end},
      ]
    end)
    |> Map.new()
    |> Map.put("serial;angelTriangles", fn () -> Geometry.RayCast.ray_cast(triangles, rays) end)

    Benchee.run(
      impl_map,
      time: 60,
      formatters: [
        {Benchee.Formatters.CSV, file: "output_ray_cast.csv"}
      ]
    )
  end
end
