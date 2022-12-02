defmodule AdventOfCode.Day02.Solution do

  def run() do
    contents = File.read!(__DIR__ <> "/input.txt") |> String.split("\n")

    part1(contents)
    part2(contents)
  end

  def part1(contents) do
    scores = %{
      "A Y" => 2 + 6, "A X" => 1 + 3, "A Z" => 3 + 0,
      "B X" => 1 + 0, "B Y" => 2 + 3, "B Z" => 3 + 6,
      "C X" => 1 + 6, "C Y" => 2 + 0, "C Z" => 3 + 3
    }

    IO.puts("1: #{contents |> Enum.reduce(0, & scores[&1] + &2)}")
  end

  @doc """
  A = Rock     = 1
  B = Paper    = 2
  C = Sciccors = 3

  X = Lose     = 0
  Y = Draw     = 3
  Z = Win      = 6
  """
  def part2(contents) do
    decide = %{
      "A X" => 3 + 0, "A Y" => 1 + 3, "A Z" => 2 + 6,
      "B X" => 1 + 0, "B Y" => 2 + 3, "B Z" => 3 + 6,
      "C X" => 2 + 0, "C Y" => 3 + 3, "C Z" => 1 + 6
    }

    IO.puts("2: #{contents |> Enum.reduce(0, & decide[&1] + &2)}")
  end

end
