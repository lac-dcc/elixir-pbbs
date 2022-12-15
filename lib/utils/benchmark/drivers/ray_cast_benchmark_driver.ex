defmodule Utils.Benchmark.Drivers.RayCast do
  def run_benchmark() do
    {triangles, rays} = PBBS.Geometry.RayCast.ReadInput.read_input("data/inputs/ray_cast/triangles2k", "data/inputs/ray_cast/rays2k")

    plist = [2, 4, 6, 12, 24, 32, 40]

    impl_map = Enum.flat_map(plist, fn p ->
      [
        {"parallel;p=#{p};default", fn () -> PBBS.Geometry.RayCast.Parallel.ray_cast(triangles, rays, p) end},
      ]
    end)
    |> Map.new()
    |> Map.put("serial;default", fn () -> PBBS.Geometry.RayCast.Sequential.ray_cast(triangles, rays) end)

    Benchee.run(
      impl_map,
      time: 60,
      formatters: [
        {Benchee.Formatters.CSV, file: "output_ray_cast.csv"}
      ]
    )
  end
end
