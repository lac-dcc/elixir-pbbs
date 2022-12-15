defmodule RayCastTest do
  use ExUnit.Case

  test "benchmark input" do
    {triangles, rays} =
      PBBS.Geometry.RayCast.ReadInput.read_input(
        "data/inputs/ray_cast/triangles2k",
        "data/inputs/ray_cast/rays2k"
      )

    result_sequential = PBBS.Geometry.RayCast.Sequential.ray_cast(triangles, rays)
    result_parallel = PBBS.Geometry.RayCast.Parallel.ray_cast(triangles, rays, 12)

    assert result_sequential == result_parallel
  end
end
