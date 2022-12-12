defmodule AdventOfCode.Day10.Solution do

  def run() do
    contents =
      File.read!(__DIR__ <> "/input.txt")
      |> String.split("\n")

    IO.puts("1: #{part1(contents)}")
    IO.puts("2: \n#{part2(contents)}")
  end

  def part1(contents) do
    cycles = cpu(contents)

    20..220
    |> Enum.take_every(40)
    |> Enum.reduce(0, fn x, acc ->
      acc + x * Map.get(cycles, x)
    end)
  end

  def cpu(_instructions \\ [], _x \\ 1,_c \\ 1, _cycles \\ %{})
  def cpu([], _x, _c, cycles), do: cycles
  def cpu(["noop" | instructions], x, c, cycles) do
    cpu(instructions, x, c + 1, cycles |> Map.put(c, x))
  end

  def cpu(["addx " <> v | instructions], x, c, cycles) do
    v = Integer.parse(v) |> elem(0)
    cpu(instructions, x + v, c + 2, cycles |> Map.put(c, x) |> Map.put(c + 1, x))
  end

  def part2(contents) do
    cycles = cpu(contents)

    0..239
    |> Enum.reduce("", fn c, acc ->
      p = cycles |> Map.get(c + 1)
      d = rem(c, 40)

      if d == p || d == p - 1 || d == p + 1 do
        acc <> "#"
      else
        acc <> "."
      end
    end)
    |> String.codepoints
    |> Enum.chunk_every(40)
    |> Enum.map(&Enum.join/1)
    |> Enum.join("\n")
  end
end
