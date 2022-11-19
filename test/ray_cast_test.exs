defmodule RayCastTest do
  use ExUnit.Case

  test "reading input" do
    triangles_file = "data/ray_cast/angelTriangles"
    rays_file = "data/ray_cast/rays"

    Geometry.RayCast.ray_cast(triangles_file, rays_file)
  end
end
