defmodule AdventOfCode.Day03.Solution do

  @vocab "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ" |> String.codepoints() |> Enum.zip(1..52) |> Enum.into(%{})

  def run() do
    contents = File.read!(__DIR__ <> "/input.txt") |> String.split("\n")

    IO.puts("1: #{part1(contents)}")
    IO.puts("2: #{part2(contents)}")
  end

  def part1(contents) do
    contents
    |> Enum.reduce(0, fn items, x ->
      {left, right} = String.split_at(items, round(String.length(items) / 2))

      left
      |> String.codepoints()
      |> Enum.uniq()
      |> Enum.filter(&String.contains?(right, &1))
      |> Enum.reduce(0, fn c, x -> @vocab[c] + x end)
      |> Kernel.+(x)
    end)
  end

  def part2(contents) do
    contents
    |> Enum.chunk_every(3)
    |> Enum.reduce(0, fn rucksacks, x ->
      rucksacks
      |> Enum.map(&String.codepoints/1)
      |> Enum.map(&Enum.into(&1, MapSet.new()))
      |> Enum.reduce(&MapSet.intersection(&1, &2))
      |> MapSet.to_list()
      |> List.first()
      |> (& @vocab[&1]).()
      |> Kernel.+(x)
    end)
  end

end
