defmodule Geometry.Vec3 do
  alias Geometry.Vec3
  defstruct x: 0, y: 0, z: 0

  def add(first, second) do
    %Vec3{x: first.x + second.x, y: first.y + second.y, z: first.z + second.z}
  end

  def sub(first, second) do
    %Vec3{x: first.x - second.x, y: first.y - second.y, z: first.z - second.z}
  end

  def negate(vector) do
    %Vec3{x: -vector.x, y: -vector.y, z: -vector.z}
  end

  def scale(vector, scalar) do
    %Vec3{x: vector.x * scalar, y: vector.y * scalar, z: vector.z * scalar}
  end

  def multiply(first, second) do
    %Vec3{x: first.x * second.x, y: first.y * second.y, z: first.z * second.z}
  end

  def dot_product(first, second) do
    first.x * second.x + first.y * second.y + first.z * second.z
  end

  def cross_product(first, second) do
    %Vec3{
      x: first.y * second.z - first.z * second.y,
      y: first.z * second.x - first.x * second.z,
      z: first.x * second.y - first.y * second.x
    }
  end

  def norm(vector) do
    vector.x * vector.x + vector.y * vector.y + vector.z * vector.z
  end

  def len(vector) do
    :math.sqrt(norm(vector))
  end

  def normalize(vector) do
    factor = 1 / len(vector)

    %Vec3{x: vector.x * factor, y: vector.y * factor, z: vector.z * factor}
  end
end
