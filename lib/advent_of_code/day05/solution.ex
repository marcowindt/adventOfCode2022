defmodule AdventOfCode.Day05.Solution do

  @doc """
  [T]     [Q]             [S]
  [R]     [M]             [L] [V] [G]
  [D] [V] [V]             [Q] [N] [C]
  [H] [T] [S] [C]         [V] [D] [Z]
  [Q] [J] [D] [M]     [Z] [C] [M] [F]
  [N] [B] [H] [N] [B] [W] [N] [J] [M]
  [P] [G] [R] [Z] [Z] [C] [Z] [G] [P]
  [B] [W] [N] [P] [D] [V] [G] [L] [T]
  1   2   3   4   5   6   7   8   9
  """

  # stacks = %{
  #   1 => ["B", "P", "N", "Q", "H", "D", "R", "T"],
  #   2 => ["W", "G", "B", "J", "T", "V"],
  #   3 => ["N", "R", "H", "D", "S", "V", "M", "Q"],
  #   4 => ["P", "Z", "N", "M", "C"],
  #   5 => ["D", "Z", "B"],
  #   6 => ["V", "C", "W", "Z"],
  #   7 => ["G", "Z", "N", "C", "V", "Q", "L", "S"],
  #   8 => ["L", "G", "J", "M", "D", "N", "V"],
  #   9 => ["T", "P", "M", "F", "Z", "C", "G"],
  # }

  # stacks = %{
  #   1 => ["Z", "N"],
  #   2 => ["M", "C", "D"],
  #   3 => ["P"]
  # }

  def run() do
    contents = File.read!(__DIR__ <> "/input.txt")

    [crates, moves] =
      contents
      |> String.split("\n\n")

    crates =
      crates
      |> String.split("\n")
      |> Enum.drop(-1)

    crates =
      1..(length(crates))
      |> Enum.map(fn stack ->
        current =
          crates
          |> Enum.at(stack - 1)
          |> String.codepoints()

        current
        |> Enum.drop(1)
        |> Enum.take_every(4)
      end)
      |> Enum.zip_with(& &1)
      |> Enum.map(&Enum.reverse/1)
      |> Enum.map(&Enum.filter(&1, fn x -> x != " " end))

    stacks =
      Enum.zip(1..(length(crates)), crates)
      |> Enum.map(fn {stack, crates} -> %{stack => crates} end)
      |> Enum.reduce(fn x, y ->
        Map.merge(x, y, fn _k, v1, v2 -> v2 ++ v1 end)
     end)

    moves =
      moves
      |> String.split("\n")
      |> Enum.map(fn move ->
        move
        |> String.split(" ")
        |> Enum.drop(1)
        |> Enum.take_every(2)
        |> Enum.map(&Integer.parse/1)
        |> Enum.map(&elem(&1, 0))
      end)

    IO.puts("1: #{part1(stacks, moves)}")
    IO.puts("2: #{part2(stacks, moves)}")
  end

  def part1(stacks, moves), do: move9000(stacks, moves)

  defp move9000(stacks, []), do: 1..(Map.keys(stacks) |> length()) |> Enum.map(& stacks[&1]) |> Enum.map(&List.last/1)
  defp move9000(stacks, [[0, _a, _b] | moves]), do: move9000(stacks, moves)

  defp move9000(stacks, [[x, a, b] | moves]) do
    stacks
    |> Map.put(b, stacks[b] ++ [stacks[a] |> List.last()])
    |> Map.put(a, stacks[a] |> Enum.drop(-1))
    |> move9000([[x - 1, a, b] | moves])
  end

  def part2(stacks, moves), do: move9001(stacks, moves)

  defp move9001(stacks, []), do: move9000(stacks, [])

  defp move9001(stacks, [[x, a, b] | moves]) do
    stacks
    |> Map.put(b, stacks[b] ++ (stacks[a] |> Enum.take(-x)))
    |> Map.put(a, stacks[a] |> Enum.drop(-x))
    |> move9001(moves)
  end

end
