defmodule AdventOfCode.Day22.Solution do
  alias AdventOfCode.Day22.MyCubeWrapper

  def run() do
    [tiles, moves] =
      File.read!(__DIR__ <> "/input.txt")
      |> String.split(["\n\n"])

    tiles =
      tiles
      |> String.split("\n")
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {row, y}, acc_og ->
        acc =
          row
          |> String.codepoints()
          |> Enum.with_index()
          |> Enum.reduce(%{}, fn {tile, x}, acc ->
            if tile == "#" || tile == "." do
              acc |> Map.put({x, y}, tile)
            else
              acc
            end
          end)

        Map.merge(acc_og, acc)
      end)

    moves =
      Regex.scan(~r/[R|L]+|[0-9]+(?:\.[0-9]+|)/, moves)
      |> Enum.map(fn [t] ->
        case t do
          "R" -> :r
          "L" -> :l
          _ -> Integer.parse(t) |> elem(0)
        end
      end)

    IO.puts("1: #{part1(tiles, moves)}")
    IO.puts("2: #{part2(tiles, moves, 50)}")
  end

  def part1(tiles, moves) do
    start_x = min_x(tiles, 0)

    {{x, y}, {a, b}} = move(tiles, moves, {start_x, 0}, {1, 0})

    facing = %{
      {1, 0} => 0,
      {0, 1} => 1,
      {-1, 0} => 2,
      {0, -1} => 3,
    }

    1000 * (y + 1) + 4 * (x + 1) + facing[{a, b}]
  end

  def move(_tiles, [], {x, y}, {a, b}), do: {{x, y}, {a, b}}

  def move(tiles, [:r | moves], {x, y}, {a, b}) do
    {a, b} = %{
      {0, 1} => {-1, 0},
      {0, -1} => {1, 0},
      {1, 0} => {0, 1},
      {-1, 0} => {0, -1}
    }[{a, b}]

    move(tiles, moves, {x, y}, {a, b})
  end

  def move(tiles, [:l | moves], {x, y}, {a, b}) do
    {a, b} = %{
      {0, 1} => {1, 0},
      {0, -1} => {-1, 0},
      {1, 0} => {0, -1},
      {-1, 0} => {0, 1}
    }[{a, b}]

    move(tiles, moves, {x, y}, {a, b})
  end

  def move(tiles, [0 | moves], {x, y}, {a, b}) do
    move(tiles, moves, {x, y}, {a, b})
  end

  def move(tiles, [move | moves], {x, y}, {a, b}) when is_integer(move) do
    new_pos = {x + a, y + b}

    case Map.get(tiles, new_pos, :wrap_around) do
      "." -> move(tiles, [move - 1 | moves], new_pos, {a, b})
      "#" -> move(tiles, moves, {x, y}, {a, b})
      :wrap_around ->
        new_pos =
          cond do
            a == 1 -> {min_x(tiles, y), y}
            a == -1 -> {max_x(tiles, y), y}
            b == 1 -> {x, min_y(tiles, x)}
            b == -1 -> {x, max_y(tiles, x)}
        end

        if Map.get(tiles, new_pos) == "." do
          move(tiles, [move - 1 | moves], new_pos, {a, b})
        else
          move(tiles, moves, {x, y}, {a, b})
        end
    end
  end

  def min_x(tiles, y) do
    tiles
    |> Map.keys()
    |> Enum.filter(fn {_c, r} -> r == y end)
    |> Enum.map(fn {c, _r} -> c end)
    |> Enum.min()
  end

  def max_x(tiles, y) do
    tiles
    |> Map.keys()
    |> Enum.filter(fn {_c, r} -> r == y end)
    |> Enum.map(fn {c, _r} -> c end)
    |> Enum.max()
  end

  def min_y(tiles, x) do
    tiles
    |> Map.keys()
    |> Enum.filter(fn {c, _r} -> c == x end)
    |> Enum.map(fn {_c, r} -> r end)
    |> Enum.min()
  end

  def max_y(tiles, x) do
    tiles
    |> Map.keys()
    |> Enum.filter(fn {c, _r} -> c == x end)
    |> Enum.map(fn {_c, r} -> r end)
    |> Enum.max()
  end

  def part2(tiles, moves, side_width \\ 4) do
    cubic_tiles =
      tiles
      |> Enum.map(fn {{x, y}, v} ->
        {{rem(x, side_width), rem(y, side_width), MyCubeWrapper.side({x, y})}, v}
      end)
      |> Enum.into(Map.new)

    reverse_cubic_tiles =
      tiles
      |> Enum.map(fn {{x, y}, _v} ->
        {{rem(x, side_width), rem(y, side_width), MyCubeWrapper.side({x, y})}, {x, y}}
      end)
      |> Enum.into(Map.new)

    {{x, y, c}, {a, b}} = move_cubic(cubic_tiles, moves, {0, 0, 1}, {1, 0})

    {x, y} = reverse_cubic_tiles[{x, y, c}]

    facing = %{
      {1, 0} => 0,
      {0, 1} => 1,
      {-1, 0} => 2,
      {0, -1} => 3,
    }

    1000 * (y + 1) + 4 * (x + 1) + facing[{a, b}]
  end

  def move_cubic(_tiles, [], {x, y, c}, {a, b}), do: {{x, y, c}, {a, b}}

  def move_cubic(tiles, [:r | moves], {x, y, c}, {a, b}) do
    {a, b} = %{
      {0, 1} => {-1, 0},
      {0, -1} => {1, 0},
      {1, 0} => {0, 1},
      {-1, 0} => {0, -1}
    }[{a, b}]

    move_cubic(tiles, moves, {x, y, c}, {a, b})
  end

  def move_cubic(tiles, [:l | moves], {x, y, c}, {a, b}) do
    {a, b} = %{
      {0, 1} => {1, 0},
      {0, -1} => {-1, 0},
      {1, 0} => {0, -1},
      {-1, 0} => {0, 1}
    }[{a, b}]

    move_cubic(tiles, moves, {x, y, c}, {a, b})
  end

  def move_cubic(tiles, [0 | moves], {x, y, c}, {a, b}) do
    move_cubic(tiles, moves, {x, y, c}, {a, b})
  end

  def move_cubic(tiles, [move | moves], {x, y, c}, {a, b}) when is_integer(move) do
    new_pos = {x + a, y + b, c}

    case Map.get(tiles, new_pos, :wrap_around) do
      "." -> move_cubic(tiles, [move - 1 | moves], new_pos, {a, b})
      "#" -> move_cubic(tiles, moves, {x, y, c}, {a, b})
      :wrap_around ->
        {new_pos, new_direction} = MyCubeWrapper.wrap({x, y, c}, {a, b})

        if Map.get(tiles, new_pos) == "." do
          move_cubic(tiles, [move - 1 | moves], new_pos, new_direction)
        else
          move_cubic(tiles, moves, {x, y, c}, {a, b})
        end
    end
  end
end
