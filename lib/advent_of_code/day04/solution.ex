defmodule AdventOfCode.Day04.Solution do

  def run() do
    contents =
      File.read!(__DIR__ <> "/input.txt")
      |> String.split("\n")
      |> Enum.map(fn ranges ->
        ranges
        |> String.split(",")
        |> Enum.map(fn range ->
          range
          |> String.split("-")
          |> Enum.map(&Integer.parse/1)
          |> Enum.map(&elem(&1, 0))
        end)
      end)

    IO.puts("1: #{part1(contents)}")
    IO.puts("2: #{part2(contents)}")
  end

  def part1(contents) do
    contents
    |> Enum.reduce(0, fn [[l_b, l_e], [r_b, r_e]], x ->
      x + bool_to_int((l_b <= r_b && l_e >= r_e) || (r_b <= l_b && r_e >= l_e))
    end)
  end

  def part2(contents) do
    contents
    |> Enum.reduce(0, fn [[l_b, l_e], [r_b, r_e]], x ->
      x + bool_to_int((l_b <= r_b && r_b <= l_e) || (r_b <= l_b && l_b <= r_e))
    end)
  end

  defp bool_to_int(false), do: 0
  defp bool_to_int(true), do: 1

end
