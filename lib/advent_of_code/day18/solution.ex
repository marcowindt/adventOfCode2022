defmodule AdventOfCode.Day18.Solution do

  def run() do
    cubes =
      File.read!(__DIR__ <> "/input.txt")
      |> String.split(["\n"])
      |> Enum.map(fn cuboid ->
        cuboid
        |> String.split(",")
        |> Enum.map(&Integer.parse/1)
        |> Enum.map(&elem(&1, 0))
        |> List.to_tuple()
      end)

    IO.puts("1: #{part1(cubes)}")
    IO.puts("2: #{part2(cubes)}")
  end

  def part1(cubes) do
    length(cubes) * 6 - too_much(cubes)
  end

  def too_much(cubes) do
    cubes
    |> Enum.with_index()
    |> Enum.map(fn {{x0, y0, z0}, i} ->
      cubes
      |> Enum.with_index()
      |> Enum.reduce([], fn {{x1, y1, z1}, j}, acc ->
        {a, b} =
          cond do
            x0 == x1 && y0 == y1 && abs(z0 - z1) == 1 -> {i, j}
            x0 == x1 && z0 == z1 && abs(y0 - y1) == 1 -> {i, j}
            y0 == y1 && z0 == z1 && abs(x0 - x1) == 1 -> {i, j}
            true -> {-1, -1}
          end
        if {a, b} != {-1, -1} && a != b do
          if  b < a do
            [{b, a} | acc ]
          else
            [{a, b} | acc ]
          end
        else
          acc
        end
      end)
    end)
    |> List.flatten()
    |> Enum.uniq()
    |> length()
    # because we eliminate sides of both cubes
    |> Kernel.*(2)
  end

  def part2(cubes) do
    sides = part1(cubes)

    xs = cubes |> Enum.map(fn {x, _y, _z} -> x end)
    ys = cubes |> Enum.map(fn {_x, y, _z} -> y end)
    zs = cubes |> Enum.map(fn {_x, _y, z} -> z end)

    max_x = Enum.max(xs)
    max_y = Enum.max(ys)
    max_z = Enum.max(zs)

    check =
      0..max_x
      |> Enum.map(fn x ->
        0..max_y
        |> Enum.map(fn y ->
          0..max_z
          |> Enum.map(fn z ->
            {x, y, z}
          end)
        end)
      end)
      |> List.flatten()

    check = check -- cubes
    outer = find_outer(check, [{0, 0, 0}], %{})
    inner = check -- outer

    sides - part1(inner)
  end

  def find_outer(_check, [], found), do: Map.keys(found)

  def find_outer(check, [cube | not_met], found) do
    if not Enum.member?(check, cube) do
      find_outer(check, not_met, found)
    else
      {howdy_neighbours, howdy_found} =
        neighbours(cube)
        |> Enum.reduce({[], %{}}, fn m, {acc_l, acc_m} = acc ->
          if not Map.has_key?(found, m) do
            {[m | acc_l], acc_m |> Map.put(m, true)}
          else
            acc
          end
        end)

      find_outer(check, not_met ++ howdy_neighbours, Map.merge(found, howdy_found))
    end
  end

  def neighbours({x0, y0, z0}) do
    [
      {x0 + 1, y0, z0},
      {x0 - 1, y0, z0},
      {x0, y0 + 1, z0},
      {x0, y0 - 1, z0},
      {x0, y0, z0 + 1},
      {x0, y0, z0 - 1}
    ]
  end

end
