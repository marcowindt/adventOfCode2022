defmodule AdventOfCode.Day24.Solution do
  alias PriorityQueue

  def run() do
    blizzards =
      File.read!(__DIR__ <> "/input.txt")
      |> String.split(["\n"])
      |> Enum.drop(1)
      |> Enum.drop(-1)
      |> Enum.with_index()
      |> Enum.map(fn {row, y} ->
        row
        |> String.codepoints()
        |> Enum.drop(1)
        |> Enum.drop(-1)
        |> Enum.with_index()
        |> Enum.reduce([], fn {pos, x}, acc ->
          case pos do
            ">" -> [{{x, y}, { 1, 0}} | acc]
            "<" -> [{{x, y}, {-1, 0}} | acc]
            "^" -> [{{x, y}, { 0,-1}} | acc]
            "v" -> [{{x, y}, { 0, 1}} | acc]
            _ -> acc
          end
        end)
      end)
      |> List.flatten()

    # this might not always give the correct answer (if no blizzard in last row or last column it doesn't work)
    max_x = (blizzards |> Enum.map(fn {{x, _y}, _direction} -> x end) |> Enum.max()) + 1
    max_y = (blizzards |> Enum.map(fn {{_x, y}, _direction} -> y end) |> Enum.max()) + 1

    blizzards_map = pre_compute_blizzards(blizzards, max_x, max_y)

    minute = part1(blizzards_map, max_x, max_y)

    IO.puts("1: #{minute}")
    IO.puts("2: #{part2(blizzards_map, minute, max_x, max_y)}")
  end

  def pre_compute_blizzards(blizzards, max_x, max_y) do
    0..round(lcm(max_x, max_y))
    |> Enum.map(fn i ->
      { i,
        blizzards_coordinates(blizzards, i, max_x, max_y)
        |> Enum.map(fn bliz -> {bliz, true} end)
        |> Enum.into(Map.new)
      }
    end)
    |> Enum.into(Map.new)
  end

  def part1(blizzards_map, max_x, max_y) do
    source = {0, -1}
    sink = {max_x - 1, max_y}

    state = {{manhattan(source, sink), 0}, source}
    {{_dist, minute_forth}, _sink} = shortest_path([state] |> Enum.into(PriorityQueue.new()), blizzards_map, sink, %{}, max_x, max_y)

    minute_forth
  end

  def shortest_path(%PriorityQueue{} = pq, blizzards_map, sink, seen, max_x, max_y) do
    {{{_distance, minute}, {x, y} = _e} = state, pq} = PriorityQueue.pop(pq)

    if {x, y} == sink do
      state
    else
      next_blizzards_coordinates = blizzards_map[rem(minute + 1, round(lcm(max_x, max_y)))]

      moves = [{1, 0}, {-1, 0}, {0, 1}, {0, -1}, {0, 0}]

      {pq, seen} =
        moves
        |> Enum.reduce({pq, seen}, fn {a, b}, {acc, s} ->
          {x, y} = {x + a, y + b}

          distance = manhattan({x, y}, sink) + minute
          new_state = {{distance, minute + 1}, {x, y}}

          cond do
            {x, y} == sink -> {PriorityQueue.put(acc, new_state), s}
            within_bounds({x, y}, max_x, max_y) && not Map.has_key?(next_blizzards_coordinates, {x, y}) && Map.get(s, {{x, y}, minute + 1}, 999999999999999) > distance ->
              s = s |> Map.put({{x, y}, minute + 1}, distance)
              {PriorityQueue.put(acc, new_state), s}
            true -> {acc, s}
          end
        end)

      shortest_path(pq, blizzards_map, sink, seen, max_x, max_y)
    end
  end

  def manhattan({x, y}, {a, b}), do: abs(x - a) + abs(y - b)

  def within_bounds({x, y}, max_x \\ 150, max_y \\ 20) do
    (x >= 0 && y >= 0 && x < max_x && y < max_y) || ({x, y} == {max_x - 1, max_y} || {x, y} == {0, -1})
  end

  defp mod(x, y) when x > 0, do: rem(x, y)
  defp mod(x, y) when x < 0, do: rem(x, y) + y
  defp mod(0,_y), do: 0

  def blizzards_coordinates(blizzards, minute, max_x, max_y) do
    blizzards
    |> Enum.map(fn {{x, y}, {a, b}} -> {mod(x + minute * a, max_x), mod(y + minute * b, max_y)} end)
  end

  def part2(blizzards_map, minute_forth, max_x, max_y) do
    start_distance = manhattan({0, -1}, {max_x - 1, max_y})

    pq = [{{start_distance, minute_forth}, {max_x - 1, max_y}}] |> Enum.into(PriorityQueue.new())
    {{_dist, minute_back}, _sink} = shortest_path(pq, blizzards_map, {0, -1}, %{}, max_x, max_y)

    pq = [{{start_distance, minute_back}, {0, -1}}] |> Enum.into(PriorityQueue.new())
    {{_dist, minute_forth_2}, _sink} = shortest_path(pq, blizzards_map, {max_x - 1, max_y}, %{}, max_x, max_y)

    minute_forth_2
  end

  defp gcd(a, 0), do: a
	defp gcd(0, b), do: b
	defp gcd(a, b), do: gcd(b, rem(a,b))

	defp lcm(0, 0), do: 0
	defp lcm(a, b), do: (a*b)/gcd(a,b)

end
