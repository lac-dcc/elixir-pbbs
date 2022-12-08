defmodule Utils.ConvexHullBenchmarkDriver do
  def run_benchmark() do
    uniform = read_points("data/inputs/convex_hull/uniform.txt")
    kuzmin = read_points("data/inputs/convex_hull/kuzmin.txt")
    perimeter = read_points("data/inputs/convex_hull/perimeter.txt")

    p = System.schedulers_online()

    impl_map = Map.new()
    |> Map.put("serial;uniform", fn () -> Geometry.ConvexHull.ConvexHull.convex_hull(uniform) end)
    |> Map.put("serial;kuzmin", fn () -> Geometry.ConvexHull.ConvexHull.convex_hull(kuzmin) end)
    |> Map.put("serial;perimeter", fn () -> Geometry.ConvexHull.ConvexHull.convex_hull(perimeter) end)
    |> Map.put("parallel;p=#{p};uniform", fn () -> Geometry.ConvexHull.ConvexHull.Parallel.convex_hull(uniform) end)
    |> Map.put("parallel;p=#{p};kuzmin", fn () -> Geometry.ConvexHull.ConvexHull.Parallel.convex_hull(kuzmin) end)
    |> Map.put("parallel;p=#{p};perimeter", fn () -> Geometry.ConvexHull.ConvexHull.Parallel.convex_hull(perimeter) end)

    Benchee.run(
      impl_map,
      time: 60,
      formatters: [
        {Benchee.Formatters.CSV, file: "output_convex_hull.csv"}
      ]
    )
  end

  defp read_points(path) do
    File.read!(path)
    |> String.split("\n")
    |> Enum.drop(1)
    |> Enum.filter(fn line -> String.trim(line) != "" end)
    |> Enum.map(fn line ->
      [x,y] = String.split(line)
      |> Enum.map(&String.to_float/1)

      {x, y}
    end)
  end

end
