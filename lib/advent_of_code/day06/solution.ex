defmodule AdventOfCode.Day06.Solution do

  def run() do
    contents = File.read!(__DIR__ <> "/input.txt") |> String.codepoints()

    IO.puts("1: #{part1(contents)}")
    IO.puts("2: #{part2(contents)}")
  end

  def part1(contents), do: solve(contents)
  def part2(contents), do: solve(contents, 14)

  def solve(contents, num_chars \\ 4) do
    0..length(contents)
    |> Enum.find(fn i ->
      contents
      |> Enum.slice(i..(i + num_chars - 1))
      |> Enum.uniq()
      |> length() == num_chars
    end)
    |> Kernel.+(num_chars)
  end

end
