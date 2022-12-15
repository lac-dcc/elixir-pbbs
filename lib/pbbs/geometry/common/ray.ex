defmodule PBBS.Geometry.Common.Ray do
  defstruct from: %PBBS.Geometry.Common.Vec3{x: 0, y: 0, z: 0}, to:  %PBBS.Geometry.Common.Vec3{x: 1, y: 1, z: 1}
end
