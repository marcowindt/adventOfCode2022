defmodule AdventOfCode.Day17.Solution do

  def run() do
    steps =
      File.read!(__DIR__ <> "/input.txt")
      |> String.codepoints()

    rocks = [&bar/2, &diamond/2, &stair/2, &snake/2, &square/2]

    IO.puts("1: #{part1(rocks, steps)}")
    IO.puts("2: #{part2(rocks, steps)}")
  end

  def part1(rocks, steps) do
    {_tube, {_x, y}, _seen, _heights} = simulate(MapSet.new([]), rocks |> Enum.with_index(), steps |> Enum.with_index(), {2, 3}, 0, 2022)

    y - 3
  end

  def simulate(tube, [{current_rock, r} | rocks], [{step, s} = current_step | steps], {x, y} \\ {2, 3}, i \\ 0, until \\ 2000, seen \\ %{}, heights \\ %{}) do
    if i == until do
      {tube, {x, y}, seen, heights}
    else
      x =
        case step do
          ">" -> if position_allowed(tube, current_rock.(x + 1, y)), do: x + 1, else: x
          "<" -> if position_allowed(tube, current_rock.(x - 1, y)), do: x - 1, else: x
        end

      if position_allowed(tube, current_rock.(x, y - 1)) do
        simulate(tube, [{current_rock, r} | rocks], steps ++ [current_step], {x, y - 1}, i, until, seen, heights)
      else
        rock = current_rock.(x, y)
        tube = MapSet.union(tube, rock)
        max_y = tube |> Enum.reduce(0, fn {_x, y}, acc -> if y > acc, do: y, else: acc end)

        seen = Map.merge(seen, %{{r, s} => [{i, max_y}]}, fn _k, v1, v2 -> v1 ++ v2 end)

        simulate(tube, rocks ++ [{current_rock, r}], steps ++ [current_step], {2, max_y + 4}, i + 1, until, seen, Map.put(heights, i, max_y))
      end
    end
  end

  def position_allowed(tube, rock) do
    within_bounds = rock |> Enum.reduce(true, fn {x, y}, acc -> acc && (x >= 0 && x <= 6 && y >= 0) end)
    within_bounds && MapSet.disjoint?(tube, rock)
  end

  def draw(tube) do
    max_y = tube |> Enum.reduce(0, fn {_x, y}, acc -> if y > acc, do: y, else: acc end)

    0..max_y
    |> Enum.map(fn y ->
      0..6
      |> Enum.map(fn x ->
        case tube |> MapSet.member?({x, y}) do
          true -> "#"
          false -> "."
        end
      end)
      |> Enum.join()
    end)
    |> Enum.reverse()
    |> Enum.join("\n")
    |> IO.puts()
  end

  defp bar(x, y), do: MapSet.new([{x, y}, {x + 1, y}, {x + 2, y}, {x + 3, y}])
  defp diamond(x, y), do: MapSet.new([{x + 1, y}, {x, y + 1}, {x + 1, y + 1}, {x + 2, y + 1}, {x + 1, y + 2}])
  defp stair(x, y), do: MapSet.new([{x, y}, {x + 1, y}, {x + 2, y}, {x + 2, y + 1}, {x + 2, y + 2}])
  defp snake(x, y), do: MapSet.new([{x, y}, {x, y + 1}, {x, y + 2}, {x, y + 3}])
  defp square(x, y), do: MapSet.new([{x, y}, {x + 1, y}, {x, y + 1}, {x + 1, y + 1}])

  def part2(rocks, steps) do
    {_tube, _position, seen, heights} = simulate(MapSet.new([]), rocks |> Enum.with_index(), steps |> Enum.with_index())

    # bit ugly, but hey :)
    periods =
      seen
      |> Map.filter(fn {{r, _s}, values} -> length(values) == 2 && r == 0 end)
      |> Map.map(fn {{_r, _s}, [{i0, y0}, {i1, y1}]} -> {i0, i1 - i0, y1 - y0} end)
      |> Map.values()
      |> List.flatten()
      |> Enum.sort()

    [{i0, _period0, _height0}, {_i, period, height}] = [hd(periods), periods |> Enum.at(-1)]

    last_bit = rem(1_000_000_000_000 - i0, period)
    height_last_bit = Map.get(heights, i0 + period + last_bit) - height - Map.get(heights, i0)

    Map.get(heights, i0) + Integer.floor_div(1_000_000_000_000 - i0, period) * height + height_last_bit
  end

end
