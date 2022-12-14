defmodule AdventOfCode.Day14.Solution do

  def run() do
    contents =
      File.read!(__DIR__ <> "/input.txt")
      |> String.split(["\n"])
      |> Enum.map(fn row ->
        row
        |> String.split(" -> ")
        |> Enum.map(fn coordinate ->
          [x, y] = coordinate |> String.split(",") |> Enum.map(fn a -> Integer.parse(a) |> elem(0) end)
          {x, y}
        end)
      end)
      |> Enum.reduce(%{}, fn coordinates, acc_og ->
        coordinates
        |> Enum.chunk_every(2, 1)
        |> Enum.drop(-1)
        |> Enum.reduce(%{}, fn [{x_a, y_a}, {x_b, y_b}], acc ->
          if x_a == x_b do
            y_a..y_b
            |> Enum.reduce(%{}, fn y, m ->
              m |> Map.put({x_a, y}, "#")
            end)
            |> Map.merge(acc)
          else
            x_a..x_b
            |> Enum.reduce(%{}, fn x, m ->
              m |> Map.put({x, y_a}, "#")
            end)
            |> Map.merge(acc)
          end
        end)
        |> Map.merge(acc_og)
      end)

    IO.puts("1: #{part1(contents)}")
    IO.puts("2: #{part2(contents)}")
  end

  def part1(rocks) do
    max_y =
      rocks
      |> Map.keys()
      |> Enum.map(&elem(&1, 1))
      |> Enum.max()

    {:halt, run} = simulate(rocks, {500, 0}, max_y)
    run
  end

  def simulate(blocked, {x, y}, max_y, run \\ 0) do
    cond do
      y >= max_y -> {:halt, run}
      not Map.has_key?(blocked, {x, y + 1}) -> simulate(blocked, {x, y + 1}, max_y, run)
      not Map.has_key?(blocked, {x - 1, y + 1}) -> simulate(blocked, {x - 1, y + 1}, max_y, run)
      not Map.has_key?(blocked, {x + 1, y + 1}) -> simulate(blocked, {x + 1, y + 1}, max_y, run)
      true -> simulate(blocked |> Map.put({x, y}, "o"), {500, 0}, max_y, run + 1)
    end
  end

  def part2(rocks) do
    max_y =
      rocks
      |> Map.keys()
      |> Enum.map(&elem(&1, 1))
      |> Enum.max()

    {:halt, run, _blocked} = simulate2(rocks, {500, 0}, max_y + 2)
    # draw(blocked)

    run
  end

  def simulate2(blocked, {x, y}, max_y, run \\ 0) do
    if Map.has_key?(blocked, {500, 0}) do
      {:halt, run, blocked}
    else
      cond do
        y == max_y - 1 -> simulate2(blocked |> Map.put({x, y}, "o"), {500, 0}, max_y, run + 1)
        not Map.has_key?(blocked, {x, y + 1}) -> simulate2(blocked, {x, y + 1}, max_y, run)
        not Map.has_key?(blocked, {x - 1, y + 1}) -> simulate2(blocked, {x - 1, y + 1}, max_y, run)
        not Map.has_key?(blocked, {x + 1, y + 1}) -> simulate2(blocked, {x + 1, y + 1}, max_y, run)
        true -> simulate2(blocked |> Map.put({x, y}, "o"), {500, 0}, max_y, run + 1)
      end
    end
  end

  def draw(rocks) do
    max_y = rocks |> Map.keys() |> Enum.map(&elem(&1, 1)) |> Enum.max()
    max_x = rocks |> Map.keys() |> Enum.map(&elem(&1, 0)) |> Enum.max()
    min_x = rocks |> Map.keys() |> Enum.map(&elem(&1, 0)) |> Enum.min()

    0..max_y
    |> Enum.map(fn y ->
      min_x..max_x
      |> Enum.map(fn x ->
        c =
          case Map.get(rocks, {x, y}, ".") do
            "#" -> "🎁"
            "o" -> "🎄"
            _ -> "⛄"
          end

        if {x, y} == {500, 0}, do: "🌟", else: c
      end)
      |> Enum.join()
    end)
    |> Enum.join("\n")
    |> IO.puts()
  end
end
