defmodule AdventOfCode.Day15.Solution do

  def run() do
    contents =
      File.read!(__DIR__ <> "/input.txt")
      |> String.split(["\n"])
      |> Enum.map(fn row ->
        Regex.run(~r/Sensor at x=(?<sensor_x>[-]?\d*), y=(?<sensor_y>[-]?\d*): closest beacon is at x=(?<beacon_x>[-]?\d*), y=(?<beacon_y>[-]?\d*)/, row)
        |> Enum.drop(1)
        |> Enum.map(&Integer.parse/1)
        |> Enum.map(&elem(&1, 0))
        |> Enum.chunk_every(2)
        |> Enum.map(fn [x, y] -> {x, y} end)
      end)

    IO.puts("1: #{part1(contents)}")
    IO.puts("2: #{part2(contents)}")
  end

  def part1(contents) do
    consider_y = 2000000

    ranges =
      contents
      |> Enum.map(fn [sensor, {b_x, b_y}] ->
        spread(sensor, {b_x, b_y}, consider_y)
      end)
      |> Enum.filter(fn x -> x != :cont end)

      l = ranges |> Enum.map(&elem(&1, 0)) |> Enum.min()
      r = ranges |> Enum.map(&elem(&1, 1)) |> Enum.max()

    r - l
  end

  def manhattan({x, y}, {a, b}), do: abs(x - a) + abs(y - b)

  def spread({s_x, s_y}, {b_x, b_y}, consider_y \\ 10) do
    distance = manhattan({s_x, s_y}, {b_x, b_y})

    min_y = s_y - distance
    max_y = s_y + distance

    if min_y <= consider_y && consider_y <= max_y do
      cond do
        consider_y < s_y -> {s_x - (distance - (s_y - consider_y)), s_x + (distance - (s_y - consider_y))}
        consider_y == s_y -> {s_x - distance, s_x + distance}
        consider_y > s_y -> {s_x - (distance - (consider_y - s_y)), s_x + (distance - (consider_y - s_y))}
      end
    else
      :cont
    end
  end

  def part2(contents) do
    diamonds =
      contents
      |> Enum.map(fn [sensor, beacon] -> diamond(sensor, beacon) end)

    # Explanation of what we are trying to do:
    #
    # Wiki: https://en.wikipedia.org/wiki/Line%E2%80%93line_intersection#Given_two_points_on_each_line
    #
    # All points outside of a diamond is considered a spot for the un detected beacon
    # But generating all those points takes too long
    # Instead we generate all 4 corner points of a diamond and consider each line
    # from every two corner points. With each paire of those lines we calculate the determinant to
    # find out whether they intersect. From all those intersection points we remove the ones that
    # is within distance from any diamond. Then there is only one left. (keeping in mind the x and y bounds)
    ps = outer_points(diamonds)

    {hidden_x, hidden_y} =
      ps
      |> Enum.reduce([], fn {x, y}, a ->
        reject =
          diamonds
          |> Enum.reduce(false, fn {{a, b}, d}, acc ->
            if manhattan({x, y}, {a, b}) <= d do
              acc || true
            else
              acc
            end
          end)

        if reject do
          a
        else
          [{x, y} | a]
        end
      end)
      |> List.first()

    hidden_x * 4000000 + hidden_y

    # This commented below will also generate the answer, but it can take a minute.
    #
    # diamonds
    # |> Enum.reduce(%{}, fn diamond, acc -> x_ranges(diamond, acc, 0, 4000000, 0, 4000000) end)
    # |> Enum.filter(fn {_y, ranges} -> length(ranges) == 2 end)
    # |> Enum.map(fn {y, [{_a, b}, {_c, _d}]} -> (b + 1) * 4000000 + y end)
    # |> List.first()
  end

  def diamond(sensor, beacon), do: {sensor, manhattan(sensor, beacon)}

  def within_diamond({{a, b}, d} = _diamond, {x, y} = _point), do: manhattan({a, b}, {x, y}) <= d

  def x_ranges({{x, y}, distance}, existing, min_x \\ 0, max_x \\ 20, min_y \\ 0, max_y \\ 20) do
    min_y = max(min_y, y - distance)
    max_y = min(max_y, y + distance)

    new_exisitng =
      min_y..max_y
      |> Enum.reduce(%{}, fn consider_y, acc ->
        range =
          cond do
            consider_y < y -> {max(min_x, x - (distance - (y - consider_y))), min(max_x, x + (distance - (y - consider_y)))}
            consider_y == y -> {max(min_x, x - distance), min(max_x, x + distance)}
            consider_y > y -> {max(min_x, x - (distance - (consider_y - y))), min(max_x, x + (distance - (consider_y - y)))}
          end

        acc |> Map.put(consider_y, [range])
      end)

    existing
    |> Map.merge(new_exisitng, fn _k, v1, v2 -> merge(Enum.sort(v1 ++ v2)) end)
  end
  def merge([{a, b} | []]), do: [{a, b}]

  def merge([{a, b} | [{c, d} | tail]]) do
    if b >= c || b + 1 == c do
      merge([{a, max(b, d)} | tail])
    else
      [{a, b}] ++ merge([{c, d} | tail])
    end
  end

  def outer_points(diamonds) do
    lines =
      diamonds
      |> Enum.map(fn {{x, y}, distance} ->
        [
          {{x - distance - 1, y}, {x, y - distance - 1}},
          {{x - distance - 1, y}, {x, y + distance + 1}},
          {{x, y - distance - 1}, {x + distance + 1, y}},
          {{x, y + distance + 1}, {x + distance + 1, y}}
        ]
      end)
      |> List.flatten()
      |> Enum.reject(fn {{x1, y1}, {x2, y2}} ->
        x1 < 0 || x1 > 4000000 || x2 < 0 || x2 > 4000000 || y1 < 0 || y1 > 4000000 || y2 < 0 || y2 > 4000000
      end)

    lines
    |> Enum.reduce([], fn line_1, acc_og ->
      lines -- [line_1]
      |> Enum.reduce([], fn line_2, acc ->
        intersect = determinant(line_1, line_2)

        if intersect != {-1, -1} do
          [intersect | acc]
        else
          acc
        end
      end)
      |> Kernel.++(acc_og)
    end)
  end

  def determinant({{x1, y1}, {x2, y2}}, {{x3, y3}, {x4, y4}}) do
    denominator = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4)

    if denominator == 0 do
      {-1, -1}
    else
      p_x = ((x1 * y2 - y1 * x2) * (x3 - x4) - (x1 - x2) * (x3 * y4 - y3 * x4)) / denominator
      p_y = ((x1 * y2 - y1 * x2) * (y3 - y4) - (y1 - y2) * (x3 * y4 - y3 * x4)) / denominator

      {p_x, p_y} = {round(p_x), round(p_y)}

      if min(x1, x2) <= p_x && p_x <= max(x1, x2) && min(y1, y2) <= p_y && p_y <= max(y1, y2) && min(x3, x4) <= p_x && p_x <= max(x3, x4) && min(y3, y4) <= p_y && p_y <= max(y3, y4) do
        {p_x, p_y}
      else
        {-1, -1}
      end
    end
  end

end
